// import 'dart:async';

// import 'package:flutter/material.dart';

// import '../auth/login_screen.dart';
// import '../auth/register_screen.dart';
// import '../dashboard/dashboard_screen.dart';

// class OtpScreen extends StatefulWidget {
//   final String email;
//   final String generatedOtp;

//   const OtpScreen({super.key, required this.email, required this.generatedOtp});

//   @override
//   State<OtpScreen> createState() => _OtpScreenState();
// }

// class _OtpScreenState extends State<OtpScreen> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   final List<TextEditingController> _otpControllers = List.generate(
//     6,
//     (_) => TextEditingController(),
//   );

//   final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

//   Timer? _timer;

//   int _remainingSeconds = 60;

//   bool _isVerifying = false;
//   bool _isResending = false;

//   String? _errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     _startTimer();
//   }

//   void _startTimer() {
//     _timer?.cancel();

//     setState(() {
//       _remainingSeconds = 60;
//     });

//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (!mounted) {
//         timer.cancel();
//         return;
//       }

//       if (_remainingSeconds > 0) {
//         setState(() {
//           _remainingSeconds--;
//         });
//       } else {
//         timer.cancel();
//       }
//     });
//   }

//   String _getEnteredOtp() {
//     return _otpControllers.map((controller) => controller.text.trim()).join();
//   }

//   void _handleOtpChanged({required String value, required int index}) {
//     if (value.isNotEmpty && index < 5) {
//       _focusNodes[index + 1].requestFocus();
//     }

//     if (value.isEmpty && index > 0) {
//       _focusNodes[index - 1].requestFocus();
//     }

//     if (_errorMessage != null) {
//       _errorMessage = null;
//     }

//     setState(() {});
//   }

//   void _clearOtpFields() {
//     for (final controller in _otpControllers) {
//       controller.clear();
//     }

//     _focusNodes.first.requestFocus();

//     setState(() {});
//   }

//   Future<void> _verifyOtp() async {
//     FocusScope.of(context).unfocus();

//     final String enteredOtp = _getEnteredOtp();

//     if (enteredOtp.length != 6) {
//       _showMessage(
//         message: 'Please enter the complete 6-digit OTP.',
//         isError: true,
//       );

//       return;
//     }

//     setState(() {
//       _isVerifying = true;
//       _errorMessage = null;
//     });

//     await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

//     if (!mounted) {
//       return;
//     }

//     setState(() {
//       _isVerifying = false;
//     });

//     if (enteredOtp != widget.generatedOtp) {
//       setState(() {
//         _errorMessage = 'Invalid verification code. Please try again.';
//       });
//       _clearOtpFields();
//       return;
//     }

//     // Mark email as registered
//     RegisterScreen.registeredEmails.add(widget.email);

//     _showSuccessDialog();
//   }

//   Future<void> _resendOtp() async {
//     if (_remainingSeconds > 0 || _isResending) {
//       return;
//     }

//     setState(() {
//       _isResending = true;
//     });

//     /*
//       TEMPORARY DELAY

//       In the next step, this section will be replaced with:

//       await AuthService.resendOtp(
//         email: widget.email,
//       );

//       The backend will generate a new OTP and send it
//       to the email address entered during registration.
//     */

//     await Future.delayed(const Duration(seconds: 2));

//     if (!mounted) {
//       return;
//     }

//     setState(() {
//       _isResending = false;
//     });

//     _clearOtpFields();
//     _startTimer();

//     _showMessage(
//       message: 'A new OTP has been sent to ${widget.email}.',
//       isError: false,
//     );
//   }

//   void _showMessage({required String message, required bool isError}) {
//     ScaffoldMessenger.of(context).hideCurrentSnackBar();

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Icon(
//               isError
//                   ? Icons.error_outline_rounded
//                   : Icons.check_circle_outline_rounded,
//               color: Colors.white,
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 message,
//                 style: const TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: isError
//             ? const Color(0xFFE74C3C)
//             : const Color(0xFF21A366),
//         behavior: SnackBarBehavior.floating,
//         margin: const EdgeInsets.all(18),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//       ),
//     );
//   }

//   void _showSuccessDialog() {
//     showDialog<void>(
//       context: context,
//       barrierDismissible: false,
//       builder: (dialogContext) {
//         return Dialog(
//           backgroundColor: Colors.transparent,
//           insetPadding: const EdgeInsets.symmetric(horizontal: 24),
//           child: Container(
//             width: double.infinity,
//             constraints: const BoxConstraints(maxWidth: 420),
//             padding: const EdgeInsets.all(28),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(28),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withValues(alpha: 0.12),
//                   blurRadius: 30,
//                   offset: const Offset(0, 15),
//                 ),
//               ],
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   width: 82,
//                   height: 82,
//                   decoration: const BoxDecoration(
//                     color: Color(0xFFEAF8F0),
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Icon(
//                     Icons.verified_rounded,
//                     color: Color(0xFF21A366),
//                     size: 46,
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 const Text(
//                   'Email verified!',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     color: Color(0xFF241D42),
//                     fontSize: 25,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 const Text(
//                   'Your email address has been verified successfully. You can now sign in to your account.',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     color: Color(0xFF777083),
//                     fontSize: 14,
//                     height: 1.6,
//                   ),
//                 ),
//                 const SizedBox(height: 26),
//                 SizedBox(
//                   width: double.infinity,
//                   height: 54,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       Navigator.of(dialogContext).pop();

//                       Navigator.pushAndRemoveUntil(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => const DashboardScreen(),
//                         ),
//                         (route) => false,
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF6C5CE7),
//                       foregroundColor: Colors.white,
//                       elevation: 0,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(17),
//                       ),
//                     ),
//                     child: const Text(
//                       'Continue to Dashboard',
//                       style: TextStyle(
//                         fontSize: 15,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   String _maskEmail(String email) {
//     final List<String> parts = email.split('@');

//     if (parts.length != 2) {
//       return email;
//     }

//     final String username = parts.first;
//     final String domain = parts.last;

//     if (username.length <= 2) {
//       return '${username.characters.first}***@$domain';
//     }

//     final String firstCharacters = username.substring(0, 2);

//     return '$firstCharacters***@$domain';
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();

//     for (final controller in _otpControllers) {
//       controller.dispose();
//     }

//     for (final focusNode in _focusNodes) {
//       focusNode.dispose();
//     }

//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bool isOtpComplete = _getEnteredOtp().length == 6;

//     return Scaffold(
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [Color(0xFFF3EEFF), Color(0xFFEDE8FF), Color(0xFFF8F6FF)],
//           ),
//         ),
//         child: SafeArea(
//           child: Stack(
//             children: [
//               Positioned(
//                 top: -100,
//                 right: -90,
//                 child: _buildGlowCircle(
//                   size: 280,
//                   color: const Color(0xFF7B61FF),
//                 ),
//               ),
//               Positioned(
//                 bottom: -100,
//                 left: -90,
//                 child: _buildGlowCircle(
//                   size: 290,
//                   color: const Color(0xFFB66DFF),
//                 ),
//               ),
//               SingleChildScrollView(
//                 keyboardDismissBehavior:
//                     ScrollViewKeyboardDismissBehavior.onDrag,
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 20,
//                   vertical: 24,
//                 ),
//                 child: Center(
//                   child: ConstrainedBox(
//                     constraints: const BoxConstraints(maxWidth: 500),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         IconButton(
//                           onPressed: () {
//                             Navigator.pop(context);
//                           },
//                           style: IconButton.styleFrom(
//                             backgroundColor: Colors.white.withValues(
//                               alpha: 0.78,
//                             ),
//                             foregroundColor: const Color(0xFF4C3F91),
//                             minimumSize: const Size(48, 48),
//                           ),
//                           icon: const Icon(Icons.arrow_back_rounded),
//                         ),
//                         const SizedBox(height: 30),
//                         Center(
//                           child: Container(
//                             width: 110,
//                             height: 110,
//                             decoration: BoxDecoration(
//                               gradient: const LinearGradient(
//                                 begin: Alignment.topLeft,
//                                 end: Alignment.bottomRight,
//                                 colors: [Color(0xFF6C5CE7), Color(0xFF9B6CFF)],
//                               ),
//                               borderRadius: BorderRadius.circular(32),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: const Color(
//                                     0xFF6C5CE7,
//                                   ).withValues(alpha: 0.30),
//                                   blurRadius: 28,
//                                   offset: const Offset(0, 15),
//                                 ),
//                               ],
//                             ),
//                             child: const Icon(
//                               Icons.mark_email_read_rounded,
//                               color: Colors.white,
//                               size: 55,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 32),
//                         const Center(
//                           child: Text(
//                             'Verify your email',
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               color: Color(0xFF201A3D),
//                               fontSize: 32,
//                               fontWeight: FontWeight.w800,
//                               height: 1.2,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 12),
//                         Center(
//                           child: Text.rich(
//                             TextSpan(
//                               text: 'We sent a 6-digit verification code to\n',
//                               style: const TextStyle(
//                                 color: Color(0xFF777083),
//                                 fontSize: 15,
//                                 height: 1.6,
//                               ),
//                               children: [
//                                 TextSpan(
//                                   text: _maskEmail(widget.email),
//                                   style: const TextStyle(
//                                     color: Color(0xFF5E4BC7),
//                                     fontWeight: FontWeight.w800,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                         ),
//                         const SizedBox(height: 34),
//                         Container(
//                           width: double.infinity,
//                           padding: const EdgeInsets.fromLTRB(22, 28, 22, 26),
//                           decoration: BoxDecoration(
//                             color: Colors.white.withValues(alpha: 0.90),
//                             borderRadius: BorderRadius.circular(28),
//                             border: Border.all(
//                               color: Colors.white.withValues(alpha: 0.90),
//                             ),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: const Color(
//                                   0xFF5D4BB7,
//                                 ).withValues(alpha: 0.12),
//                                 blurRadius: 35,
//                                 offset: const Offset(0, 20),
//                               ),
//                             ],
//                           ),
//                           child: Form(
//                             key: _formKey,
//                             child: Column(
//                               children: [
//                                 const Text(
//                                   'Enter verification code',
//                                   style: TextStyle(
//                                     color: Color(0xFF332A56),
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w800,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 22),
//                                 Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: List.generate(6, (index) {
//                                     return _buildOtpBox(index);
//                                   }),
//                                 ),
//                                 if (_errorMessage != null)
//                                   Padding(
//                                     padding: const EdgeInsets.only(top: 8.0),
//                                     child: Text(
//                                       _errorMessage!,
//                                       style: const TextStyle(
//                                         color: Color(0xFFE74C3C),
//                                         fontSize: 13,
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                     ),
//                                   ),
//                                 const SizedBox(height: 24),
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     const Icon(
//                                       Icons.timer_outlined,
//                                       color: Color(0xFF81798D),
//                                       size: 19,
//                                     ),
//                                     const SizedBox(width: 7),
//                                     Text(
//                                       _remainingSeconds > 0
//                                           ? 'Code expires in 00:${_remainingSeconds.toString().padLeft(2, '0')}'
//                                           : 'You can request a new code',
//                                       style: TextStyle(
//                                         color: _remainingSeconds > 0
//                                             ? const Color(0xFF81798D)
//                                             : const Color(0xFFE67E22),
//                                         fontSize: 13,
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 26),
//                                 SizedBox(
//                                   width: double.infinity,
//                                   height: 58,
//                                   child: DecoratedBox(
//                                     decoration: BoxDecoration(
//                                       gradient: const LinearGradient(
//                                         colors: [
//                                           Color(0xFF6C5CE7),
//                                           Color(0xFF8E5BEF),
//                                         ],
//                                       ),
//                                       borderRadius: BorderRadius.circular(18),
//                                       boxShadow: [
//                                         BoxShadow(
//                                           color: const Color(
//                                             0xFF6C5CE7,
//                                           ).withValues(alpha: 0.30),
//                                           blurRadius: 18,
//                                           offset: const Offset(0, 10),
//                                         ),
//                                       ],
//                                     ),
//                                     child: ElevatedButton(
//                                       onPressed: _isVerifying || !isOtpComplete
//                                           ? null
//                                           : _verifyOtp,
//                                       style: ElevatedButton.styleFrom(
//                                         backgroundColor: Colors.transparent,
//                                         disabledBackgroundColor:
//                                             Colors.transparent,
//                                         shadowColor: Colors.transparent,
//                                         foregroundColor: Colors.white,
//                                         disabledForegroundColor: Colors.white54,
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius: BorderRadius.circular(
//                                             18,
//                                           ),
//                                         ),
//                                       ),
//                                       child: _isVerifying
//                                           ? const SizedBox(
//                                               width: 24,
//                                               height: 24,
//                                               child: CircularProgressIndicator(
//                                                 strokeWidth: 2.5,
//                                                 color: Colors.white,
//                                               ),
//                                             )
//                                           : const Row(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment.center,
//                                               children: [
//                                                 Icon(
//                                                   Icons.verified_user_outlined,
//                                                   size: 21,
//                                                 ),
//                                                 SizedBox(width: 9),
//                                                 Text(
//                                                   'Verify OTP',
//                                                   style: TextStyle(
//                                                     fontSize: 16,
//                                                     fontWeight: FontWeight.w700,
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(height: 22),
//                                 const Text(
//                                   'Didnâ€™t receive the code?',
//                                   style: TextStyle(
//                                     color: Color(0xFF81798D),
//                                     fontSize: 13,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 5),
//                                 TextButton(
//                                   onPressed:
//                                       _remainingSeconds == 0 && !_isResending
//                                       ? _resendOtp
//                                       : null,
//                                   child: _isResending
//                                       ? const SizedBox(
//                                           width: 19,
//                                           height: 19,
//                                           child: CircularProgressIndicator(
//                                             strokeWidth: 2,
//                                             color: Color(0xFF6C5CE7),
//                                           ),
//                                         )
//                                       : Text(
//                                           _remainingSeconds > 0
//                                               ? 'Resend available after $_remainingSeconds seconds'
//                                               : 'Resend verification code',
//                                           style: TextStyle(
//                                             color: _remainingSeconds == 0
//                                                 ? const Color(0xFF6C5CE7)
//                                                 : const Color(0xFFA29CAB),
//                                             fontSize: 14,
//                                             fontWeight: FontWeight.w700,
//                                           ),
//                                         ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 24),
//                         const Center(
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Icon(
//                                 Icons.lock_outline_rounded,
//                                 color: Color(0xFF898292),
//                                 size: 17,
//                               ),
//                               SizedBox(width: 7),
//                               Text(
//                                 'Your information is secure and encrypted',
//                                 style: TextStyle(
//                                   color: Color(0xFF898292),
//                                   fontSize: 12,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildOtpBox(int index) {
//     final double screenWidth = MediaQuery.sizeOf(context).width;

//     final double boxWidth = screenWidth < 390 ? 43 : 49;

//     return SizedBox(
//       width: boxWidth,
//       height: 58,
//       child: TextFormField(
//         controller: _otpControllers[index],
//         focusNode: _focusNodes[index],
//         keyboardType: TextInputType.number,
//         textAlign: TextAlign.center,
//         maxLength: 1,
//         style: const TextStyle(
//           color: Color(0xFF302650),
//           fontSize: 22,
//           fontWeight: FontWeight.w800,
//         ),
//         decoration: InputDecoration(
//           counterText: '',
//           filled: true,
//           fillColor: _otpControllers[index].text.isNotEmpty
//               ? const Color(0xFFF1EDFF)
//               : const Color(0xFFF9F7FC),
//           contentPadding: const EdgeInsets.symmetric(vertical: 16),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(14),
//             borderSide: BorderSide(
//               color: _otpControllers[index].text.isNotEmpty
//                   ? const Color(0xFF8C74EF)
//                   : const Color(0xFFE2DDEB),
//               width: _otpControllers[index].text.isNotEmpty ? 1.8 : 1,
//             ),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(14),
//             borderSide: const BorderSide(color: Color(0xFF6C5CE7), width: 2),
//           ),
//         ),
//         onChanged: (value) {
//           _handleOtpChanged(value: value, index: index);
//         },
//       ),
//     );
//   }

//   Widget _buildGlowCircle({required double size, required Color color}) {
//     return Container(
//       width: size,
//       height: size,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         color: color.withValues(alpha: 0.12),
//       ),
//     );
//   }
// }

import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/exceptions/api_exception.dart';
import '../../core/services/auth_service.dart';
import '../auth/login_screen.dart';

class OtpScreen extends StatefulWidget {
  final String email;

  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() {
    return _OtpScreenState();
  }
}

class _OtpScreenState extends State<OtpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _otpController = TextEditingController();

  bool _isVerifying = false;
  bool _isResending = false;

  Timer? _timer;
  int _secondsRemaining = 45;

  bool get _canResend {
    return _secondsRemaining == 0 && !_isResending && !_isVerifying;
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();

    setState(() {
      _secondsRemaining = 45;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  String? _validateOtp(String? value) {
    final String otp = value?.trim() ?? '';

    if (otp.isEmpty) {
      return 'Please enter the OTP';
    }

    if (otp.length != 6) {
      return 'OTP must contain exactly 6 digits';
    }

    final RegExp otpPattern = RegExp(r'^\d{6}$');

    if (!otpPattern.hasMatch(otp)) {
      return 'OTP must contain only numbers';
    }

    return null;
  }

  Future<void> _verifyOtp() async {
    FocusScope.of(context).unfocus();

    if (_isVerifying || _isResending) {
      return;
    }

    final bool isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    try {
      final Map<String, dynamic> response = await AuthService.instance
          .verifyOtp(email: widget.email, otp: _otpController.text.trim());

      if (!mounted) {
        return;
      }

      _showMessage(
        message:
            response['message']?.toString() ?? 'Email verified successfully.',
        isError: false,
      );

      await Future<void>.delayed(const Duration(milliseconds: 700));

      if (!mounted) {
        return;
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) {
            return const LoginScreen();
          },
        ),
        (route) => false,
      );
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(message: error.message, isError: true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(
        message: 'OTP verification failed. Please try again.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  Future<void> _resendOtp() async {
    if (!_canResend) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isResending = true;
    });

    try {
      final Map<String, dynamic> response = await AuthService.instance
          .resendOtp(email: widget.email);

      if (!mounted) {
        return;
      }

      _otpController.clear();
      _startTimer();

      _showMessage(
        message: response['message']?.toString() ?? 'A new OTP has been sent.',
        isError: false,
      );
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(message: error.message, isError: true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(
        message: 'Unable to resend OTP. Please try again.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  void _showMessage({required String message, required bool isError}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError
            ? const Color(0xFFE74C3C)
            : const Color(0xFF21A366),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  String _maskedEmail() {
    final List<String> parts = widget.email.split('@');

    if (parts.length != 2) {
      return widget.email;
    }

    final String username = parts.first;
    final String domain = parts.last;

    if (username.length <= 2) {
      return '${username.substring(0, 1)}***@$domain';
    }

    return '${username.substring(0, 2)}***@$domain';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF3EEFF), Color(0xFFEDE8FF), Color(0xFFF8F6FF)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: -80,
                right: -60,
                child: _buildGlowCircle(
                  size: 230,
                  color: const Color(0xFF7B61FF),
                ),
              ),
              Positioned(
                bottom: -100,
                left: -80,
                child: _buildGlowCircle(
                  size: 280,
                  color: const Color(0xFFB66DFF),
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 30,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: Colors.white),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF5D4BB7,
                            ).withValues(alpha: 0.16),
                            blurRadius: 38,
                            offset: const Offset(0, 20),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                onPressed: _isVerifying || _isResending
                                    ? null
                                    : () {
                                        Navigator.pop(context);
                                      },
                                style: IconButton.styleFrom(
                                  backgroundColor: const Color(0xFFF3F0FF),
                                  foregroundColor: const Color(0xFF6C5CE7),
                                ),
                                icon: const Icon(Icons.arrow_back_rounded),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: 76,
                              height: 76,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF6C5CE7),
                                    Color(0xFF9B6CFF),
                                  ],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF6C5CE7,
                                    ).withValues(alpha: 0.28),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.mark_email_read_rounded,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Verify your email',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF201A3D),
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'We sent a 6-digit verification code to',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: const Color(0xFF6F6981),
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _maskedEmail(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF6C5CE7),
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 30),
                            TextFormField(
                              controller: _otpController,
                              enabled: !_isVerifying && !_isResending,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                              maxLength: 6,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF241D42),
                                fontSize: 24,
                                letterSpacing: 10,
                                fontWeight: FontWeight.w700,
                              ),
                              decoration: InputDecoration(
                                counterText: '',
                                hintText: '000000',
                                hintStyle: const TextStyle(
                                  color: Color(0xFFCBC6D4),
                                  letterSpacing: 10,
                                ),
                                prefixIcon: const Icon(
                                  Icons.password_rounded,
                                  color: Color(0xFF7566B4),
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF8F6FC),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                  horizontal: 18,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE5E0EE),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF6C5CE7),
                                    width: 1.8,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE74C3C),
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE74C3C),
                                    width: 1.8,
                                  ),
                                ),
                              ),
                              validator: _validateOtp,
                              onFieldSubmitted: (_) {
                                _verifyOtp();
                              },
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF6C5CE7),
                                      Color(0xFF8E5BEF),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF6C5CE7,
                                      ).withValues(alpha: 0.30),
                                      blurRadius: 18,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _isVerifying || _isResending
                                      ? null
                                      : _verifyOtp,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    disabledBackgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                  child: _isVerifying
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Verify OTP',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            SizedBox(width: 9),
                                            Icon(
                                              Icons.verified_rounded,
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              _secondsRemaining > 0
                                  ? 'You can resend OTP in $_secondsRemaining seconds'
                                  : 'Did not receive the OTP?',
                              style: const TextStyle(
                                color: Color(0xFF6F6981),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: _canResend ? _resendOtp : null,
                              child: _isResending
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFF6C5CE7),
                                      ),
                                    )
                                  : const Text(
                                      'Resend OTP',
                                      style: TextStyle(
                                        color: Color(0xFF6C5CE7),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'The OTP will expire after 5 minutes.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF9B95A7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlowCircle({required double size, required Color color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.12),
      ),
    );
  }
}
