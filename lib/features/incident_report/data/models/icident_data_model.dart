/// Demo model — replace with the real API model when the backend is wired up.
class IncidentDataModel {
  final String userName;
  final String name;
  final String location;
  final int deathCount;
  final int injuredCount;
  final String? imageUrl;
  final String description;

  const IncidentDataModel({
    required this.userName,
    required this.name,
    required this.location,
    required this.deathCount,
    required this.injuredCount,
    required this.description,
    this.imageUrl,
  });
}