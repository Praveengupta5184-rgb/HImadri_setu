import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import '../../services/auth/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../layout/app_shell.dart';
import 'register_screen.dart';
import 'widgets/snowfall_particles.dart';
import 'widgets/mission_control_header.dart';
import 'widgets/mission_info_panel.dart';
import 'widgets/judge_demo_section.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocus = FocusNode();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _loadSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('saved_login_email');
      final rememberPref = prefs.getBool('remember_me_pref') ?? true;
      if (mounted) {
        setState(() {
          _rememberMe = rememberPref;
          if (savedEmail != null && savedEmail.isNotEmpty && rememberPref) {
            _emailController.text = savedEmail;
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _persistCredentials(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('remember_me_pref', _rememberMe);
      if (_rememberMe) {
        await prefs.setString('saved_login_email', email.trim());
      } else {
        await prefs.remove('saved_login_email');
      }
    } catch (_) {}
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final result = await AuthService.login(email, password);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result.success && result.token != null) {
      await _persistCredentials(email);
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ShowCaseWidget(
              builder: (context) => const AppShell(),
            ),
          ),
        );
      }
    } else {
      setState(() {
        _errorMessage = result.message.isNotEmpty
            ? result.message
            : 'Authentication failed. Please verify your credentials.';
      });
    }
  }

  void _fillDemoCredentials(String email, String password) {
    setState(() {
      _emailController.text = email;
      _passwordController.text = password;
      _errorMessage = '';
    });
    _formKey.currentState?.validate();
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F1E36),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: AppTheme.accentCyan.withValues(alpha: 0.4),
          ),
        ),
        title: Row(
          children: const [
            Icon(Icons.shield_outlined, color: AppTheme.accentCyan, size: 22),
            SizedBox(width: 10),
            Text(
              'Passcode Recovery Protocol',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Under NCPOR expedition security guidelines, automated public self-service password resets are restricted for mission security.',
              style: TextStyle(
                color: Color(0xFFCBD5E1),
                fontSize: 13,
                height: 1.45,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Please contact your Station Commander, Mission Officer, or the NCPOR System Administrator (admin@polarops.gov.in) with your personnel credentials to reset your access key.',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Acknowledge',
              style: TextStyle(
                color: AppTheme.accentCyan,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030712),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Full-screen Realistic Polar Station & Glacier Landscape
          Image.asset(
            'assets/images/antarctic_station_bg.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF020617),
                      Color(0xFF0A192F),
                      Color(0xFF0F264A),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              );
            },
          ),

          // 2. Deep Navy & Aurora Vignette Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF030A17).withValues(alpha: 0.90),
                  const Color(0xFF07152B).withValues(alpha: 0.78),
                  const Color(0xFF020712).withValues(alpha: 0.92),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // 3. Subtle Animated Polar Snowfall Particles
          const Positioned.fill(
            child: SnowfallParticles(numberOfSnowflakes: 42),
          ),

          // 4. Main Responsive Content Layer
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWideScreen = constraints.maxWidth >= 960;

                return Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 24,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isWideScreen ? 1180 : 480,
                      ),
                      child: isWideScreen
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Left Side: Mission Information Panel
                                const Expanded(
                                  flex: 6,
                                  child: MissionInfoPanel(),
                                ),
                                const SizedBox(width: 32),
                                // Right Side: Glassmorphism Login Card
                                Expanded(
                                  flex: 5,
                                  child: _buildLoginCard(context),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                const MissionControlHeader(compact: true),
                                const SizedBox(height: 24),
                                _buildLoginCard(context),
                              ],
                            ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCard(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF0B1930).withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.accentCyan.withValues(alpha: 0.32),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.55),
                blurRadius: 32,
                spreadRadius: 6,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: AppTheme.accentCyan.withValues(alpha: 0.12),
                blurRadius: 24,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Card Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.accentCyan.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.accentCyan.withValues(alpha: 0.4),
                        ),
                      ),
                      child: const Icon(
                        Icons.lock_person_outlined,
                        color: AppTheme.accentCyan,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Mission Command Access',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Sign in to your expedition command center',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Error Message Alert
                if (_errorMessage.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7F1D1D).withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.statusCritical.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: AppTheme.statusCritical,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(
                              color: Color(0xFFFCA5A5),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Email / Operative ID Field
                const Text(
                  'Email or Operative ID',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFCBD5E1),
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                  decoration: _buildInputDecoration(
                    hintText: 'name@polarops.gov.in',
                    prefixIcon: Icons.alternate_email,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email or Operative ID is required';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // Passcode / Security Key Field
                const Text(
                  'Security Key / Passcode',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFCBD5E1),
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _login(),
                  decoration: _buildInputDecoration(
                    hintText: '••••••••••••',
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: const Color(0xFF94A3B8),
                        size: 18,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Passcode is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Remember Me & Forgot Password Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          _rememberMe = !_rememberMe;
                        });
                      },
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: Checkbox(
                                value: _rememberMe,
                                activeColor: AppTheme.accentCyan,
                                checkColor: AppTheme.primaryNavy,
                                side: const BorderSide(
                                  color: Color(0xFF64748B),
                                  width: 1.4,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    _rememberMe = val ?? false;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Remember me',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _showForgotPasswordDialog,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Forgot Passcode?',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.accentCyan,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // Sign In to Mission Control Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentCyan,
                      foregroundColor: const Color(0xFF0A192F),
                      elevation: 4,
                      shadowColor: AppTheme.accentCyan.withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF0A192F),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Authorizing Mission Clearance...',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: Color(0xFF0A192F),
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.login_rounded, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Sign In to Mission Control',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                // Judge Demo Credentials Section
                JudgeDemoSection(
                  onFillCredentials: _fillDemoCredentials,
                ),

                const SizedBox(height: 18),

                // Register Personnel Account Link
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.person_add_alt_1_outlined,
                      size: 15,
                      color: Color(0xFF94A3B8),
                    ),
                    label: const Text(
                      'Request New Personnel Enrollment',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Color(0xFF475569),
        fontSize: 13,
      ),
      prefixIcon: Icon(
        prefixIcon,
        color: const Color(0xFF64748B),
        size: 18,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFF060F1E).withValues(alpha: 0.7),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: const Color(0xFF1E293B).withValues(alpha: 0.9),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: AppTheme.accentCyan,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: AppTheme.statusCritical.withValues(alpha: 0.8),
          width: 1,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: AppTheme.statusCritical,
          width: 1.5,
        ),
      ),
      errorStyle: const TextStyle(
        color: Color(0xFFFCA5A5),
        fontSize: 11,
      ),
    );
  }
}
