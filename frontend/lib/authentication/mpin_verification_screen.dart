import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../providers/user_provider.dart';
import '../bottomnavigation/bottomnavigation.dart';
import '../start_subscription.dart';
import '../utils/first_login_helper.dart';
import 'signup/verifyotp.dart';
import 'package:reva/authentication/signup/CompleteProfileScreen.dart';
import '../utils/navigation_helper.dart';

class MpinVerificationScreen extends StatefulWidget {
  const MpinVerificationScreen({super.key});

  @override
  State<MpinVerificationScreen> createState() => _MpinVerificationScreenState();
}

class _MpinVerificationScreenState extends State<MpinVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;
  String? _username;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _setupControllers();
  }

  void _loadUserData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.loadUserData();
    setState(() {
      _username = userProvider.userName;
    });
  }

  void _setupControllers() {
    for (int i = 0; i < 6; i++) {
      _controllers[i].addListener(() {
        if (_controllers[i].text.length == 1 && i < 5) {
          _focusNodes[i + 1].requestFocus();
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  String _getMpin() {
    return _controllers.map((controller) => controller.text).join();
  }

  void _clearMpin() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  Future<void> _verifyMpin() async {
    final mpin = _getMpin();
    if (mpin.length != 6) {
      setState(() {
        _errorMessage = 'Please enter 6-digit MPIN';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _authService.verifyMpin(mpin);

      if (response['success'] == true) {
        // Set hasLoggedInBefore flag
        await FirstLoginHelper.setHasLoggedIn();
        // Update username from response if available
        if (response['data'] != null && response['data']['user'] != null) {
          setState(() {
            _username = response['data']['user']['fullName'];
          });
        }

        // Check OTP and KYC verification status
        final verifications = response['data']?['verifications'];
        final otpVerified =
            verifications != null && verifications['otp'] == true;
        final kycVerified =
            verifications != null && verifications['kyc'] == true;
        if (!otpVerified) {
          // Get mobile number from secure storage
          final mobileNumber = await _authService.getToken('userMobileNumber');
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => VerifyOtp(prefillPhone: mobileNumber),
            ),
          );
          return;
        }

        // OTP is verified, now check KYC
        if (!kycVerified) {
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => const CompleteProfileScreen(),
            ),
          );
          return;
        }

        // KYC is verified, now check subscription
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.loadUserData();
        await userProvider.checkSubscription();

        if (!mounted) return;

        if (userProvider.isSubscribed == true) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const BottomNavigation()),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const StartSubscriptionPage()),
          );
        }
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Invalid MPIN';
          _clearMpin();
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to verify MPIN. Please try again.';
        _clearMpin();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF22252A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF22252A),
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => _showLogoutDialog(),
            icon: const Icon(
              Icons.logout_rounded,
              color: Colors.white,
              size: 24,
            ),
            tooltip: 'Sign Out',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bottomInset = MediaQuery.of(context).viewInsets.bottom;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - bottomInset,
                ),
                child: IntrinsicHeight(
                  child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Welcome message
              Text(
                'Welcome! ${_username ?? 'User'}',
                style: GoogleFonts.dmSans(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your MPIN to continue',
                style: GoogleFonts.dmSans(
                  color: const Color(0xFFDFDFDF),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // MPIN input fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  6,
                  (index) => SizedBox(
                    width: 45,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color.fromARGB(
                            255, 88, 86, 86), // lighter background
                        border: OutlineInputBorder(
                            // borderRadius: BorderRadius.circular(8),
                            // borderSide: const BorderSide(
                            //   color: Color(0xFFB0B0B0), // subtle border
                            //   width: 1.2,
                            // ),
                            ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFB0B0B0),
                            width: 1.2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF0262AB),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 8,
                        ),
                      ),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(1),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: (value) {
                        if (value.length == 1 && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        }
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Error message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: GoogleFonts.dmSans(
                      color: Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Verify button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyMpin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0262AB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Verify MPIN',
                          style: GoogleFonts.dmSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // Forgot MPIN option
              TextButton(
                onPressed: () {
                  // Navigate to forgot MPIN screen or logout
                  _showLogoutDialog();
                },
                child: Text(
                  'Forgot MPIN?',
                  style: GoogleFonts.dmSans(
                    color: const Color(0xFFB2C2D9),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A2E35),
          title: Text(
            'Logout',
            style: GoogleFonts.dmSans(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          content: Text(
            'Are you sure you want to logout? You will need to login again.',
            style: GoogleFonts.dmSans(
              color: const Color(0xFFDFDFDF),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.dmSans(
                  color: const Color(0xFFB2C2D9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await AuthService.performCompleteLogout();
                await FirstLoginHelper.clearHasLoggedIn();
                NavigationHelper.navigateToWelcomeScreen();
              },
              child: Text(
                'Logout',
                style: GoogleFonts.dmSans(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _navigateToWelcome() {
    // Use a post-frame callback to ensure navigation happens after the current frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/welcome', (route) => false);
        } catch (e) {
          // If that fails, try going to root
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        }
      }
    });
  }
}