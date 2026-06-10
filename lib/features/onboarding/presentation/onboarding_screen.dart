import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/hsk_levels.dart';
import '../../../core/profile/user_profile.dart';
import '../../../core/providers/performance_provider.dart';
import '../../../core/providers/tab_provider.dart';
import '../../../core/providers/user_profile_provider.dart';
import '../../../core/widgets/hanzify_haptic.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  static const path = '/onboarding';

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  var _step = 0;

  // 0 = "Mới bắt đầu" (học từ HSK1), 1..4 = HSK tương ứng.
  var _levelChoice = 3;
  var _dailyMinutes = 10;
  var _priority = LearningPriority.vocabulary;

  static const _stepCount = 3;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    HanzifyHaptic.light();
    if (_step < _stepCount - 1) {
      _pageController.animateToPage(
        _step + 1,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
      return;
    }
    ref
        .read(userProfileProvider.notifier)
        .completeOnboarding(
          activeLevel: _levelChoice == 0 ? kMinHskLevel : _levelChoice,
          dailyMinutes: _dailyMinutes,
          priority: _priority,
        );
    context.go(AppTab.shorts.path);
  }

  void _back() {
    HanzifyHaptic.selection();
    _pageController.animateToPage(
      _step - 1,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final performance = readPerformance(ref);
    final isLastStep = _step == _stepCount - 1;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  if (_step > 0)
                    IconButton(
                      onPressed: _back,
                      icon: const Icon(Icons.arrow_back_rounded),
                      tooltip: 'Quay lại',
                    )
                  else
                    const SizedBox(width: 48),
                  Expanded(
                    child: Center(
                      child: _StepDots(step: _step, count: _stepCount),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (page) => setState(() => _step = page),
                  children: [
                    _OnboardingStep(
                      title: 'Bạn đang ở trình độ nào?',
                      subtitle:
                          'Hanzify sẽ mở nội dung Shorts, Quiz và Flashcard '
                          'theo cấp độ này. Bạn có thể đổi sau.',
                      performance: performance,
                      children: [
                        _ChoiceTile(
                          label: 'Mới bắt đầu',
                          description: 'Học từ đầu với HSK 1',
                          selected: _levelChoice == 0,
                          onTap: () => setState(() => _levelChoice = 0),
                        ),
                        for (final level in kHskLevels)
                          _ChoiceTile(
                            label: 'HSK $level',
                            description: switch (level) {
                              1 => 'Khoảng 500 từ cơ bản',
                              2 => 'Giao tiếp đơn giản hằng ngày',
                              3 => 'Tự tin trong tình huống quen thuộc',
                              _ => 'Đọc hiểu và trao đổi chủ đề rộng',
                            },
                            selected: _levelChoice == level,
                            onTap: () => setState(() => _levelChoice = level),
                          ),
                      ],
                    ),
                    _OnboardingStep(
                      title: 'Mỗi ngày bạn muốn học bao lâu?',
                      subtitle:
                          'Thời lượng này quyết định số thẻ trong mỗi phiên '
                          'ôn tập.',
                      performance: performance,
                      children: [
                        for (final (minutes, description) in [
                          (5, 'Nhẹ nhàng · khoảng 10 thẻ mỗi phiên'),
                          (10, 'Đều đặn · khoảng 20 thẻ mỗi phiên'),
                          (20, 'Tăng tốc · khoảng 35 thẻ mỗi phiên'),
                        ])
                          _ChoiceTile(
                            label: '$minutes phút',
                            description: description,
                            selected: _dailyMinutes == minutes,
                            onTap: () => setState(() => _dailyMinutes = minutes),
                          ),
                      ],
                    ),
                    _OnboardingStep(
                      title: 'Bạn muốn ưu tiên điều gì?',
                      subtitle:
                          'Hanzify sẽ gợi ý bài luyện phù hợp với mục tiêu '
                          'của bạn.',
                      performance: performance,
                      children: [
                        for (final priority in LearningPriority.values)
                          _ChoiceTile(
                            label: priority.labelVi,
                            description: switch (priority) {
                              LearningPriority.listening =>
                                'Nghe hội thoại và chép chính tả',
                              LearningPriority.vocabulary =>
                                'Mở rộng vốn từ với quiz và flashcard',
                              LearningPriority.conversation =>
                                'Luyện mẫu câu giao tiếp thực tế',
                              LearningPriority.writing =>
                                'Viết chữ Hán và dịch Việt-Trung',
                            },
                            selected: _priority == priority,
                            onTap: () => setState(() => _priority = priority),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _next,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(isLastStep ? 'Bắt đầu học' : 'Tiếp tục'),
              ),
              if (!isLastStep) ...[
                const SizedBox(height: 4),
                TextButton(
                  onPressed: () {
                    HanzifyHaptic.selection();
                    ref
                        .read(userProfileProvider.notifier)
                        .completeOnboarding(
                          activeLevel: _levelChoice == 0
                              ? kMinHskLevel
                              : _levelChoice,
                          dailyMinutes: _dailyMinutes,
                          priority: _priority,
                        );
                    context.go(AppTab.shorts.path);
                  },
                  child: Text(
                    'Bỏ qua, dùng lựa chọn hiện tại',
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingStep extends StatelessWidget {
  const _OnboardingStep({
    required this.title,
    required this.subtitle,
    required this.performance,
    required this.children,
  });

  final String title;
  final String subtitle;
  final bool performance;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    Widget content = ListView(
      children: [
        const SizedBox(height: 12),
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 20),
        ...children,
      ],
    );
    if (!performance) {
      content = content
          .animate()
          .fadeIn(duration: 240.ms)
          .moveY(begin: 12, end: 0, duration: 240.ms, curve: Curves.easeOut);
    }
    return content;
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.label,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: selected ? colors.primaryContainer : colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            HanzifyHaptic.selection();
            onTap();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? colors.primary : colors.outlineVariant,
                width: selected ? 1.6 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? colors.onPrimaryContainer
                              : colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: selected
                              ? colors.onPrimaryContainer.withValues(alpha: 0.8)
                              : colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.circle_outlined,
                  color: selected ? colors.primary : colors.outlineVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepDots extends StatelessWidget {
  const _StepDots({required this.step, required this.count});

  final int step;
  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == step ? 22 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == step ? colors.primary : colors.outlineVariant,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}
