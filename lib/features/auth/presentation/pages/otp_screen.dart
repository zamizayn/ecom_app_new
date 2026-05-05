import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';

// ─────────────────────────────────────────────────────────────────────────────
// OTP Screen
// ─────────────────────────────────────────────────────────────────────────────

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  const OtpScreen({super.key, required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
    with SingleTickerProviderStateMixin {
  static const int _otpLength = 6;
  static const int _resendSeconds = 30;
  static const int _maxResendAttempts = 3;

  // ── OTP fields ──────────────────────────────────────────────────────────────
  final List<TextEditingController> _controllers =
      List.generate(_otpLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(_otpLength, (_) => FocusNode());

  // ── State ───────────────────────────────────────────────────────────────────
  bool _hasError = false;
  String _errorMessage = '';
  bool _isVerifying = false;
  int _resendCountdown = _resendSeconds;
  int _resendAttempts = 0;
  Timer? _timer;

  // ── Shake animation ─────────────────────────────────────────────────────────
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  // ── Helpers ─────────────────────────────────────────────────────────────────
  String get _maskedPhone {
    final raw = widget.phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (raw.length < 4) return widget.phoneNumber;
    final visible = raw.substring(raw.length - 4);
    return '+91 ****$visible';
  }

  String get _otp => _controllers.map((c) => c.text).join();

  bool get _isComplete => _otp.length == _otpLength;

  // ── Lifecycle ────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();

    // Shake animation
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -12), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -12, end: 12), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 12, end: -8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: 0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeInOut,
    ));

    _startTimer();

    // Auto-focus first box after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _shakeController.dispose();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _focusNodes) {
      n.dispose();
    }
    super.dispose();
  }

  // ── Timer ───────────────────────────────────────────────────────────────────
  void _startTimer() {
    _timer?.cancel();
    setState(() => _resendCountdown = _resendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendCountdown == 0) {
        t.cancel();
      } else {
        setState(() => _resendCountdown--);
      }
    });
  }

  // ── OTP input handling ──────────────────────────────────────────────────────
  void _onDigitChanged(String value, int index) {
    if (_hasError) setState(() => _hasError = false);

    // Handle paste of full OTP
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < _otpLength && i < digits.length; i++) {
        _controllers[i].text = digits[i];
      }
      _focusNodes[(_otpLength - 1).clamp(0, _otpLength - 1)].requestFocus();
      setState(() {});
      return;
    }

    if (value.isNotEmpty && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    setState(() {});
  }

  void _onKeyEvent(KeyEvent event, int index) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
      setState(() {});
    }
  }

  // ── Verify ──────────────────────────────────────────────────────────────────
  void _verify() {
    if (!_isComplete || _isVerifying) return;
    setState(() => _isVerifying = true);
    context.read<AuthBloc>().add(VerifyOtpRequested(_otp));
  }

  // ── Resend ──────────────────────────────────────────────────────────────────
  void _resend() {
    if (_resendCountdown > 0 || _resendAttempts >= _maxResendAttempts) return;
    setState(() {
      _resendAttempts++;
      _hasError = false;
      _errorMessage = '';
      _isVerifying = false;
      for (final c in _controllers) {
        c.clear();
      }
    });
    _startTimer();
    _focusNodes[0].requestFocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('New OTP sent successfully'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Error shake ─────────────────────────────────────────────────────────────
  void _triggerError(String message) {
    setState(() {
      _hasError = true;
      _errorMessage = message;
      _isVerifying = false;
      for (final c in _controllers) {
        c.clear();
      }
    });
    _shakeController.forward(from: 0);
    _focusNodes[0].requestFocus();
    HapticFeedback.mediumImpact();
  }

  // ── Build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          context.go('/home');
        } else if (state is AuthError) {
          _triggerError('Incorrect code. Please try again.');
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 48),

                  // ── Illustration ─────────────────────────────────────────
                  _OtpIllustration(primary: primary, isDark: isDark),
                  const SizedBox(height: 32),

                  // ── Title ────────────────────────────────────────────────
                  Text(
                    'Verify Your Number',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                  ),
                  const SizedBox(height: 10),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                          color: Colors.grey[500], fontSize: 14, height: 1.5),
                      children: [
                        const TextSpan(text: 'Enter the 6-digit code sent to\n'),
                        TextSpan(
                          text: _maskedPhone,
                          style: TextStyle(
                              color: primary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // ── OTP boxes ────────────────────────────────────────────
                  AnimatedBuilder(
                    animation: _shakeAnimation,
                    builder: (_, child) => Transform.translate(
                      offset: Offset(_shakeAnimation.value, 0),
                      child: child,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        _otpLength,
                        (i) => _OtpBox(
                          controller: _controllers[i],
                          focusNode: _focusNodes[i],
                          hasError: _hasError,
                          primary: primary,
                          isDark: isDark,
                          onChanged: (v) => _onDigitChanged(v, i),
                          onKeyEvent: (e) => _onKeyEvent(e, i),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Inline error ─────────────────────────────────────────
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 250),
                    crossFadeState: _hasError
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    firstChild: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.red, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            _errorMessage,
                            style: const TextStyle(
                                color: Colors.red,
                                fontSize: 13,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    secondChild: const SizedBox(height: 20),
                  ),
                  const SizedBox(height: 28),

                  // ── Verify button ────────────────────────────────────────
                  _VerifyButton(
                    isComplete: _isComplete,
                    isVerifying: _isVerifying || state is AuthLoading,
                    primary: primary,
                    onTap: _verify,
                  ),
                  const SizedBox(height: 28),

                  // ── Resend / Timer ───────────────────────────────────────
                  _ResendRow(
                    countdown: _resendCountdown,
                    attemptsLeft: _maxResendAttempts - _resendAttempts,
                    onResend: _resend,
                    primary: primary,
                  ),
                  const SizedBox(height: 16),

                  // ── Change number ────────────────────────────────────────
                  TextButton.icon(
                    onPressed: () => context.go('/login'),
                    icon: Icon(Icons.arrow_back,
                        size: 14, color: Colors.grey[500]),
                    label: Text(
                      'Change phone number',
                      style: TextStyle(color: Colors.grey[500], fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// OTP Illustration
// ─────────────────────────────────────────────────────────────────────────────

class _OtpIllustration extends StatelessWidget {
  final Color primary;
  final bool isDark;
  const _OtpIllustration({required this.primary, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: primary.withOpacity(0.08),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.lock_outline_rounded, size: 52, color: primary),
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, size: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Single OTP digit box
// ─────────────────────────────────────────────────────────────────────────────

class _OtpBox extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasError;
  final Color primary;
  final bool isDark;
  final ValueChanged<String> onChanged;
  final ValueChanged<KeyEvent> onKeyEvent;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.hasError,
    required this.primary,
    required this.isDark,
    required this.onChanged,
    required this.onKeyEvent,
  });

  @override
  State<_OtpBox> createState() => _OtpBoxState();
}

class _OtpBoxState extends State<_OtpBox> {
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final isFocused = widget.focusNode.hasFocus;
    final isFilled = widget.controller.text.isNotEmpty;

    Color borderColor;
    Color bgColor;
    if (widget.hasError) {
      borderColor = Colors.red;
      bgColor = Colors.red.withOpacity(0.05);
    } else if (isFocused) {
      borderColor = widget.primary;
      bgColor = widget.primary.withOpacity(0.05);
    } else if (isFilled) {
      borderColor = widget.primary.withOpacity(0.4);
      bgColor = widget.isDark ? const Color(0xFF1E293B) : Colors.grey[50]!;
    } else {
      borderColor = Colors.grey[300]!;
      bgColor = widget.isDark ? const Color(0xFF1E293B) : Colors.grey[50]!;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 46,
      height: 56,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: isFocused ? 2 : 1.5),
        boxShadow: isFocused
            ? [
                BoxShadow(
                    color: widget.primary.withOpacity(0.15),
                    blurRadius: 8,
                    spreadRadius: 1),
              ]
            : [],
      ),
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: widget.onKeyEvent,
        child: TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: widget.hasError ? Colors.red : null,
          ),
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
          onChanged: widget.onChanged,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Verify CTA button
// ─────────────────────────────────────────────────────────────────────────────

class _VerifyButton extends StatelessWidget {
  final bool isComplete;
  final bool isVerifying;
  final Color primary;
  final VoidCallback onTap;

  const _VerifyButton({
    required this.isComplete,
    required this.isVerifying,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: isComplete
            ? LinearGradient(
                colors: [primary, primary.withBlue(220)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isComplete ? null : Colors.grey[200],
        boxShadow: isComplete
            ? [
                BoxShadow(
                    color: primary.withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6)),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isComplete && !isVerifying ? onTap : null,
          borderRadius: BorderRadius.circular(28),
          child: Center(
            child: isVerifying
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5),
                  )
                : Text(
                    'Verify OTP',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isComplete ? Colors.white : Colors.grey[400],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Timer + Resend row
// ─────────────────────────────────────────────────────────────────────────────

class _ResendRow extends StatelessWidget {
  final int countdown;
  final int attemptsLeft;
  final VoidCallback onResend;
  final Color primary;

  const _ResendRow({
    required this.countdown,
    required this.attemptsLeft,
    required this.onResend,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final canResend = countdown == 0 && attemptsLeft > 0;
    final exhausted = attemptsLeft <= 0;

    return Column(
      children: [
        if (!exhausted) ...[
          Text(
            'Didn\'t receive the code?',
            style: TextStyle(color: Colors.grey[500], fontSize: 13),
          ),
          const SizedBox(height: 8),
          if (countdown > 0)
            // Countdown
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timer_outlined, size: 16, color: Colors.grey[400]),
                const SizedBox(width: 6),
                Text(
                  'Resend code in ',
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
                Text(
                  '00:${countdown.toString().padLeft(2, '0')}',
                  style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                ),
              ],
            )
          else
            // Resend button
            GestureDetector(
              onTap: canResend ? onResend : null,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded, size: 16, color: primary),
                    const SizedBox(width: 6),
                    Text(
                      'Resend OTP',
                      style: TextStyle(
                          color: primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                    if (attemptsLeft < 3) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$attemptsLeft left',
                          style: const TextStyle(
                              color: Colors.orange,
                              fontSize: 11,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ] else
          // Max attempts
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.07),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.block, color: Colors.red, size: 16),
                SizedBox(width: 8),
                Text(
                  'Max resend attempts reached',
                  style: TextStyle(color: Colors.red, fontSize: 13),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
