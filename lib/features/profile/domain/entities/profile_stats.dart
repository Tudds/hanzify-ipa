class ProfileStats {
  final int streakDays;
  final int dominantHskLevel; // 0 = chưa có dữ liệu
  final int masteredCount;
  final int reviewedCount;

  const ProfileStats({
    required this.streakDays,
    required this.dominantHskLevel,
    required this.masteredCount,
    required this.reviewedCount,
  });

  const ProfileStats.empty()
      : streakDays = 0,
        dominantHskLevel = 0,
        masteredCount = 0,
        reviewedCount = 0;
}
