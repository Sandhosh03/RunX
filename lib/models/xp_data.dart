class XpData {
  final int currentXp;
  final int totalXp;
  final int level;
  final int xpNeededForNextLevel;
  final double progress;

  XpData({
    required this.currentXp,
    required this.totalXp,
    required this.level,
    required this.xpNeededForNextLevel,
    required this.progress,
  });

  factory XpData.calculate(int totalXp) {
    int level = 1;
    int remainingXp = totalXp;
    
    // Level formula: level 1 needs 500 XP, then it increases by 20% each level
    int xpRequired = 500;
    
    while (remainingXp >= xpRequired) {
      remainingXp -= xpRequired;
      level++;
      xpRequired = (xpRequired * 1.2).round();
    }

    return XpData(
      currentXp: remainingXp,
      totalXp: totalXp,
      level: level,
      xpNeededForNextLevel: xpRequired,
      progress: (remainingXp / xpRequired).clamp(0.0, 1.0),
    );
  }
}
