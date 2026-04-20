import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hanzify/core/theme/typography.dart';
import 'package:hanzify/core/theme/app_theme_helper.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hanzify/core/widgets/hanzify_button.dart';

class OnboardingScreen extends ConsumerWidget {
  final VoidCallback onFinish;

  const OnboardingScreen({super.key, required this.onFinish});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = themeColorsOf(context);
    
    return Scaffold(
      backgroundColor: c.background,
      body: Stack(
        children: [
          // Premium Background Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    c.primary.withValues(alpha: 0.05),
                    c.background,
                    c.secondary.withValues(alpha: 0.05),
                  ],
                ),
              ),
            ),
          ),
          
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),
                  Center(
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        color: c.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: c.primary.withValues(alpha: 0.2),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '漢',
                        style: AppTypography.hanziDisplay(
                          fontSize: 80,
                          color: c.primary,
                        ),
                      ),
                    ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                      .scale(duration: 2.seconds, curve: Curves.easeInOut)
                      .shimmer(duration: 3.seconds, color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'Hanzify',
                    style: AppTypography.headline(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: c.primary,
                      letterSpacing: -2.0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chinh phục Hán tự thông qua trải nghiệm thị giác sống động.',
                    textAlign: TextAlign.center,
                    style: AppTypography.body(
                      fontSize: 18,
                      color: c.text,
                      height: 1.5,
                    ),
                  ),
                  const Spacer(),
                  HanzifyButton(
                    label: 'Bắt đầu ngay',
                    onTap: onFinish,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Học tập hiệu quả với Material 3.',
                    style: AppTypography.label(
                      fontSize: 12,
                      color: c.placeholder,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
