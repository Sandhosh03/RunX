class Community {
  final String id;
  final String name;
  final String description;
  final int members;
  final String category;
  final String image;
  final bool isJoined;

  Community({
    required this.id,
    required this.name,
    required this.description,
    required this.members,
    required this.category,
    required this.image,
    this.isJoined = false,
  });
}

class CommunityRun {
  final String id;
  final String title;
  final String date;
  final String time;
  final String location;
  final int participants;

  CommunityRun({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.location,
    required this.participants,
  });
}
