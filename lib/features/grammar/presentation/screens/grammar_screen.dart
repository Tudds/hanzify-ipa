import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hanzify/core/theme/colors.dart';
import 'package:hanzify/core/theme/typography.dart';
import 'package:hanzify/core/theme/theme_state.dart';
import 'package:hanzify/core/providers/navigation_provider.dart';
import 'package:hanzify/features/grammar/domain/entities/grammar_point.dart';

class GrammarCategory {
  static const basic = 'basic';
  static const particle = 'particle';
  
  static String getEmoji(String category) {
    switch (category) {
      case basic: return '🧱';
      case particle: return '✨';
      default: return '📖';
    }
  }
}

class GrammarScreen extends ConsumerStatefulWidget {
  const GrammarScreen({super.key});

  @override
  ConsumerState<GrammarScreen> createState() => _GrammarScreenState();
}

class _GrammarScreenState extends ConsumerState<GrammarScreen> {
  int _selectedLevel = 1;
  String? _expandedId;

  final List<GrammarPoint> _mockGrammar = [
    GrammarPoint(
      id: 'g1',
      title: '是 (shì) - Động từ "là"',
      structure: 'S + 是 + N',
      explanation: 'Dùng để nối chủ ngữ với danh từ hoặc cụm danh từ, tương đương với "là" trong tiếng Việt.',
      examples: const [
        GrammarExample(zh: '我是学生。', pinyin: 'Wǒ shì xuésheng.', vi: 'Tôi là học sinh.'),
        GrammarExample(zh: '他是老师。', pinyin: 'Tā shì lǎoshī.', vi: 'Anh ấy là giáo viên.'),
        GrammarExample(zh: '这是书。', pinyin: 'Zhè shì shū.', vi: 'Đây là quyển sách.'),
      ],
      level: 1,
      category: GrammarCategory.basic,
    ),
    GrammarPoint(
      id: 'g2',
      title: '的 (de) - Trợ từ sở hữu',
      structure: 'N1 + 的 + N2',
      explanation: 'Dùng để biểu thị quan hệ sở hữu hoặc thuộc tính, tương tự "của" trong tiếng Việt.',
      examples: const [
        GrammarExample(zh: '我的书', pinyin: 'Wǒ de shū', vi: 'Sách của tôi'),
        GrammarExample(zh: '妈妈的朋友', pinyin: 'Māma de péngyǒu', vi: 'Bạn của mẹ'),
        GrammarExample(zh: '很好的老师', pinyin: 'Hěn hǎo de lǎoshī', vi: 'Giáo viên rất tốt'),
      ],
      level: 1,
      category: GrammarCategory.basic,
    ),
    GrammarPoint(
      id: 'g3',
      title: '吗 (ma) - Trợ từ nghi vấn',
      structure: 'Câu trần thuật + 吗？',
      explanation: 'Thêm vào cuối câu để biến câu trần thuật thành câu hỏi yes/no.',
      examples: const [
        GrammarExample(zh: '你是学生吗？', pinyin: 'Nǐ shì xuésheng ma?', vi: 'Bạn là học sinh phải không?'),
        GrammarExample(zh: '这是你的书吗？', pinyin: 'Zhè shì nǐ de shū ma?', vi: 'Đây là sách của bạn phải không?'),
        GrammarExample(zh: '他喜欢中文吗？', pinyin: 'Tā xǐhuān Zhōngwén ma?', vi: 'Anh ấy thích tiếng Trung phải không?'),
      ],
      level: 1,
      category: GrammarCategory.basic,
    ),
  ];

  List<GrammarPoint> get _filteredGrammar {
    return _mockGrammar.where((g) => g.level == _selectedLevel).toList();
  }

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(themeColorsProvider);

    return Scaffold(
      backgroundColor: c.background,
      body: Column(
        children: [
          _buildHeader(c),
          _buildLevelSelector(c),
          Expanded(
            child: _filteredGrammar.isEmpty
                ? _buildEmptyState(c)
                : _buildGrammarList(c),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AppThemeColors c) {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [c.primary.withValues(alpha: 0.08), c.background],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 60,
                child: GestureDetector(
                  onTap: () => ref.read(navigationProvider.notifier).navigate('home'),
                  child: Text(
                    '← Về',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: c.primary,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Ngữ Pháp',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: c.text,
                  ),
                ),
              ),
              const SizedBox(width: 60),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Nắm vững nền tảng ngữ pháp tiếng Trung',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: c.placeholder,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelSelector(AppThemeColors c) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: 6,
        itemBuilder: (context, index) {
          final level = index + 1;
          final isActive = _selectedLevel == level;
          
          return GestureDetector(
            onTap: () => setState(() => _selectedLevel = level),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              width: 70,
              decoration: BoxDecoration(
                gradient: isActive
                    ? LinearGradient(
                        colors: [c.primary, c.accent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isActive ? null : c.surfaceLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isActive ? Colors.transparent : c.disabled.withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: c.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'HSK',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.white.withValues(alpha: 0.9) : c.placeholder,
                    ),
                  ),
                  Text(
                    '$level',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: isActive ? Colors.white : c.text,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGrammarList(AppThemeColors c) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      itemCount: _filteredGrammar.length,
      itemBuilder: (context, index) {
        return _GrammarCard(
          grammar: _filteredGrammar[index],
          colors: c,
          isExpanded: _expandedId == _filteredGrammar[index].id,
          onTap: () {
            setState(() {
              _expandedId = _expandedId == _filteredGrammar[index].id
                  ? null
                  : _filteredGrammar[index].id;
            });
          },
        );
      },
    );
  }

  Widget _buildEmptyState(AppThemeColors c) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    c.primary.withValues(alpha: 0.15),
                    c.accent.withValues(alpha: 0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🏗️', style: TextStyle(fontSize: 48)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Đang xây dựng',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: c.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Nội dung ngữ pháp HSK $_selectedLevel đang được chuẩn bị. Hãy quay lại sau nhé!',
              style: TextStyle(
                fontSize: 15,
                color: c.placeholder,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _GrammarCard extends StatelessWidget {
  final GrammarPoint grammar;
  final AppThemeColors colors;
  final bool isExpanded;
  final VoidCallback onTap;

  const _GrammarCard({
    required this.grammar,
    required this.colors,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(
          color: isExpanded ? colors.primary.withValues(alpha: 0.3) : colors.disabled.withValues(alpha: 0.12),
          width: isExpanded ? 1.5 : 1,
        ),
        boxShadow: [
          if (isExpanded)
            BoxShadow(
              color: colors.primary.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.xl),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colors.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        GrammarCategory.getEmoji(grammar.category),
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text(
                            grammar.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: colors.text,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            grammar.structure,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: colors.primary,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: colors.disabled,
                    ),
                  ],
                ),
                
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: isExpanded
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            Divider(color: colors.disabled.withValues(alpha: 0.2)),
                            const SizedBox(height: 12),
                            
                            Text(
                              'Giải thích:',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: colors.accent,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              grammar.explanation,
                              style: TextStyle(
                                fontSize: 14,
                                color: colors.text,
                                height: 1.5,
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            Text(
                              'Ví dụ:',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: colors.accent,
                              ),
                            ),
                            const SizedBox(height: 8),
                            
                            ...grammar.examples.map(
                              (ex) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: colors.surfaceLowest,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ex.zh,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: colors.text,
                                          height: 1.4,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        ex.vi,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: colors.placeholder,
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


