import 'package:codenyx/core/theme/app_theme.dart';
import 'package:codenyx/services/session_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'chat_provider.dart';
import 'message_model.dart';
import 'message_bubble.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  String? _teamId;
  String? _currentUserId;
  bool _isResolvingSession = true;
  bool _isSending = false;
  int _lastRenderedMessageCount = 0;

  @override
  void initState() {
    super.initState();
    _loadChatContext();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadChatContext() async {
    final session = await SessionService.getSession();
    final teamId = session['teamId']?.toString();
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    if (!mounted) return;
    setState(() {
      _teamId = teamId;
      _currentUserId = currentUserId;
      _isResolvingSession = false;
    });
  }

  Future<void> _sendMessage() async {
    final teamId = _teamId;
    final text = _messageController.text.trim();
    if (teamId == null || text.isEmpty || _isSending) return;

    setState(() => _isSending = true);

    try {
      final repository = ref.read(chatRepositoryProvider);
      await repository.sendMessage(teamId, text);

      _messageController.clear();
      _scrollToBottom(); // optimistic scroll
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    });
  }

  bool _isNearBottom() {
    if (!_scrollController.hasClients) {
      return true;
    }

    final remainingDistance =
        _scrollController.position.maxScrollExtent -
        _scrollController.position.pixels;
    return remainingDistance < 120;
  }

  void _handleMessagesChanged(List<MessageModel> messages) {
    if (messages.isEmpty) {
      _lastRenderedMessageCount = 0;
      return;
    }

    final hasNewMessage = messages.length > _lastRenderedMessageCount;
    final latestMessage = messages.last;
    final shouldScroll =
        hasNewMessage &&
        (_isNearBottom() || latestMessage.userId == _currentUserId);

    _lastRenderedMessageCount = messages.length;

    if (shouldScroll) {
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isResolvingSession) {
      return const Scaffold(
        backgroundColor: AppTheme.primaryBackground,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentPrimary),
          ),
        ),
      );
    }

    final teamId = _teamId;
    if (teamId == null || teamId.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.primaryBackground,
        appBar: AppBar(
          title: const Text('Team Chat', style: AppTheme.cardTitle),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(AppTheme.spacingL),
            child: Text(
              'No team session found for chat.',
              style: AppTheme.cardBody,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final messagesAsync = ref.watch(teamMessagesProvider(teamId));

    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: AppBar(
        title: const Text('Team Chat', style: AppTheme.cardTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Column(
          children: [
            Expanded(
              child: messagesAsync.when(
                data: (messages) {
                  _handleMessagesChanged(messages);

                  if (messages.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppTheme.spacingL),
                        child: Text(
                          'No messages yet. Start the team conversation.',
                          style: AppTheme.cardBody,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(
                      AppTheme.spacingL,
                      AppTheme.spacingM,
                      AppTheme.spacingL,
                      AppTheme.spacingM,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return MessageBubble(
                        message: message,
                        isCurrentUser: message.userId == _currentUserId,
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.accentPrimary,
                    ),
                  ),
                ),
                error: (error, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingL),
                    child: Text(
                      'Failed to load chat: $error',
                      style: AppTheme.cardBody,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.spacingL,
                  AppTheme.spacingS,
                  AppTheme.spacingL,
                  AppTheme.spacingL,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        minLines: 1,
                        maxLines: 4,
                        textInputAction: TextInputAction.newline,
                        style: const TextStyle(color: AppTheme.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: const TextStyle(
                            color: AppTheme.textTertiary,
                          ),
                          filled: true,
                          fillColor: AppTheme.surfaceLight.withValues(
                            alpha: 0.9,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusLarge,
                            ),
                            borderSide: const BorderSide(
                              color: AppTheme.borderColor,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusLarge,
                            ),
                            borderSide: const BorderSide(
                              color: AppTheme.borderColor,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusLarge,
                            ),
                            borderSide: const BorderSide(
                              color: AppTheme.accentPrimary,
                              width: 1.4,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingM),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSending ? null : _sendMessage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentPrimary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusLarge,
                            ),
                          ),
                        ),
                        child: _isSending
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(Icons.send_rounded),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
