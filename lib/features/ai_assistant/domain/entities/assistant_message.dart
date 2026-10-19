enum AssistantMessageRole { user, assistant }

class AssistantMessage {
  const AssistantMessage({
    required this.id,
    required this.text,
    required this.role,
    required this.createdAt,
  });

  final String id;
  final String text;
  final AssistantMessageRole role;
  final DateTime createdAt;

  bool get isUser => role == AssistantMessageRole.user;
}
