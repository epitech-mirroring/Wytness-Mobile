class ApiModel {
  final String name;
  final String imageUrl;
  final String description;
  final List<String> actions;
  final List<String> reactions;

  ApiModel({
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.actions,
    required this.reactions,
  });

  factory ApiModel.fromJson(Map<String, dynamic> json) {
    return ApiModel(
      name: json['name'],
      imageUrl: json['imageUrl'],
      description: json['description'],
      actions:
          (json['actions'] as List).map((action) => action.toString()).toList(),
      reactions: (json['reactions'] as List)
          .map((reaction) => reaction.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'description': description,
      'actions': actions,
      'reactions': reactions,
    };
  }
}
