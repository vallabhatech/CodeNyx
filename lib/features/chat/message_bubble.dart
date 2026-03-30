import 'package:codenyx/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

import 'message_model.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
  });

  final MessageModel message;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    const double bubbleRadius = 20.0;

    final borderRadius = isCurrentUser
        ? const BorderRadius.only(
            topLeft: Radius.circular(bubbleRadius),
            topRight: Radius.circular(bubbleRadius),
            bottomLeft: Radius.circular(bubbleRadius),
            bottomRight: Radius.circular(6),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(bubbleRadius),
            topRight: Radius.circular(bubbleRadius),
            bottomLeft: Radius.circular(6),
            bottomRight: Radius.circular(bubbleRadius),
          );

    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
        child: Column(
          crossAxisAlignment: isCurrentUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            // Name (Outside Bubble - Highlighted)
            Padding(
              padding: EdgeInsets.only(
                left: isCurrentUser ? 0 : 12,
                right: isCurrentUser ? 12 : 0,
                bottom: 5,
              ),
              child: Text(
                isCurrentUser ? 'You' : message.userName,
                style: AppTheme.metaText.copyWith(
                  color: isCurrentUser
                      ? AppTheme.accentPrimary.withOpacity(0.9)
                      : AppTheme.accentPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                ),
              ),
            ),

            // Message Bubble - Improved colors with better contrast
            Container(
              margin: const EdgeInsets.only(bottom: AppTheme.spacingXS),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: isCurrentUser
                    ? AppTheme.accentPrimary.withOpacity(
                        0.85,
                      ) // Softer, better contrast
                    : AppTheme.surfaceLight.withOpacity(
                        0.98,
                      ), // Clean & bright for others
                borderRadius: borderRadius,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.message,
                style: AppTheme.cardBody.copyWith(
                  color: isCurrentUser ? Colors.white : AppTheme.textPrimary,
                  height: 1.45,
                  fontSize: 15.5,
                ),
              ),
            ),

            // Timestamp (Outside Bubble)
            Padding(
              padding: EdgeInsets.only(
                left: isCurrentUser ? 0 : 14,
                right: isCurrentUser ? 14 : 0,
                top: 4,
                bottom: AppTheme.spacingS,
              ),
              child: Text(
                _formatTime(message.createdAt),
                style: AppTheme.metaText.copyWith(
                  fontSize: 11.5,
                  color: AppTheme.textTertiary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
