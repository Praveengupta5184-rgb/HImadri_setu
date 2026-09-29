import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../api/api_client.dart';

class SyncService {
  static const String _queueKey = 'offline_sync_queue';
  static bool isOnline = true;
  static bool isSyncing = false;
  static List<Map<String, dynamic>> syncLog = [];
  
  static final Connectivity _connectivity = Connectivity();
  
  // Callbacks for UI updates
  static void Function(bool)? onStatusChange;
  static void Function()? onSyncLogChange;

  static Future<void> initialize() async {
    final results = await _connectivity.checkConnectivity();
    isOnline = !results.contains(ConnectivityResult.none);
    
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final newStatus = !results.contains(ConnectivityResult.none);
      if (newStatus != isOnline) {
        isOnline = newStatus;
        onStatusChange?.call(isOnline);
        if (isOnline) {
          _flushQueue();
        }
      }
    });
  }

  static Future<void> enqueueOperation(String method, String endpoint, Map<String, dynamic> body) async {
    final prefs = await SharedPreferences.getInstance();
    final queueStr = prefs.getString(_queueKey) ?? '[]';
    final List<dynamic> queue = jsonDecode(queueStr);
    
    final operation = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'method': method,
      'endpoint': endpoint,
      'body': body,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    queue.add(operation);
    await prefs.setString(_queueKey, jsonEncode(queue));
    
    _addLog('Queued offline: $method $endpoint');
  }

  static Future<void> _flushQueue() async {
    if (isSyncing || !isOnline) return;
    
    final prefs = await SharedPreferences.getInstance();
    final queueStr = prefs.getString(_queueKey) ?? '[]';
    final List<dynamic> queue = jsonDecode(queueStr);
    
    if (queue.isEmpty) return;

    isSyncing = true;
    onStatusChange?.call(isOnline);
    _addLog('Starting sync of ${queue.length} items...');

    List<dynamic> remainingQueue = [];
    
    for (var item in queue) {
      try {
        final String method = item['method'];
        final String endpoint = item['endpoint'];
        final Map<String, dynamic> body = item['body'];
        
        // Use ApiClient or direct http
        // Since ApiClient encapsulates token, let's use it
        ApiResponse response;
        if (method == 'POST') {
          response = await ApiClient.post(endpoint, body);
        } else if (method == 'PUT') {
          response = await ApiClient.put(endpoint, body);
        } else {
          continue;
        }

        if (response.success) {
          _addLog('Synced: $method $endpoint');
        } else {
          // Conflict or server error, retain for manual review
          _addLog('Sync Failed (Conflict/Error): $method $endpoint - ${response.error}');
          item['error'] = response.error;
          remainingQueue.add(item);
        }
      } catch (e) {
        _addLog('Network Error during sync: $e');
        remainingQueue.add(item);
      }
    }
    
    await prefs.setString(_queueKey, jsonEncode(remainingQueue));
    isSyncing = false;
    onStatusChange?.call(isOnline);
    _addLog('Sync complete. ${remainingQueue.length} items remaining.');
  }

  static void _addLog(String msg) {
    syncLog.insert(0, {
      'time': DateTime.now().toIso8601String(),
      'message': msg
    });
    if (syncLog.length > 50) syncLog.removeLast();
    onSyncLogChange?.call();
    print('SyncService: $msg');
  }
}
