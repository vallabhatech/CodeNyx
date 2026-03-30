import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'chat_repository.dart';
import 'message_model.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository();
});

// KeepAlive = true so the stream doesn't die when the widget is temporarily off-screen
final teamMessagesProvider = StreamProvider.family<List<MessageModel>, String>((
  ref,
  teamId,
) {
  ref.keepAlive(); // ← Important for persistent realtime

  final repository = ref.watch(chatRepositoryProvider);
  return repository.watchMessages(teamId);
});
