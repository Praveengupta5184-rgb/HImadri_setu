package in.gov.moes.ncpor.polarops.service;

import in.gov.moes.ncpor.polarops.model.Notification;
import in.gov.moes.ncpor.polarops.repository.NotificationRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArrayList;

@Service
@RequiredArgsConstructor
@Slf4j
public class NotificationService {
    
    private final NotificationRepository notificationRepository;
    
    // SSE emitters per user
    private final Map<Long, List<SseEmitter>> userEmitters = new ConcurrentHashMap<>();
    
    // Broadcast emitters
    private final List<SseEmitter> broadcastEmitters = new CopyOnWriteArrayList<>();

    public SseEmitter subscribe(Long userId) {
        SseEmitter emitter = new SseEmitter(Long.MAX_VALUE); // Infinite timeout
        
        if (userId != null) {
            userEmitters.computeIfAbsent(userId, k -> new CopyOnWriteArrayList<>()).add(emitter);
            
            emitter.onCompletion(() -> userEmitters.get(userId).remove(emitter));
            emitter.onTimeout(() -> userEmitters.get(userId).remove(emitter));
            emitter.onError((e) -> userEmitters.get(userId).remove(emitter));
        } else {
            broadcastEmitters.add(emitter);
            emitter.onCompletion(() -> broadcastEmitters.remove(emitter));
            emitter.onTimeout(() -> broadcastEmitters.remove(emitter));
            emitter.onError((e) -> broadcastEmitters.remove(emitter));
        }
        
        return emitter;
    }

    public Notification sendNotification(Long userId, String type, String severity, String title, String message, String referenceId) {
        Notification notification = Notification.builder()
                .userId(userId)
                .type(type)
                .severity(severity)
                .title(title)
                .message(message)
                .referenceId(referenceId)
                .createdAt(LocalDateTime.now())
                .isRead(false)
                .build();
                
        notification = notificationRepository.save(notification);
        
        try {
            if (userId != null) {
                List<SseEmitter> emitters = userEmitters.get(userId);
                if (emitters != null) {
                    for (SseEmitter emitter : emitters) {
                        emitter.send(SseEmitter.event().name("notification").data(notification));
                    }
                }
            } else {
                for (SseEmitter emitter : broadcastEmitters) {
                    emitter.send(SseEmitter.event().name("notification").data(notification));
                }
            }
        } catch (Exception e) {
            log.error("Error sending SSE notification", e);
        }
        
        return notification;
    }
    
    public List<Notification> getUserNotifications(Long userId) {
        return notificationRepository.findByUserIdOrderByCreatedAtDesc(userId);
    }
    
    public List<Notification> getUnreadNotifications(Long userId) {
        return notificationRepository.findByUserIdAndIsReadFalseOrderByCreatedAtDesc(userId);
    }
    
    public void markAsRead(Long notificationId) {
        notificationRepository.findById(notificationId).ifPresent(notification -> {
            notification.setIsRead(true);
            notificationRepository.save(notification);
        });
    }
}
