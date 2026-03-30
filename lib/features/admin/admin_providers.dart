import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'announcements_repository.dart';
import 'mentor_requests_repository.dart';

final announcementsRepositoryProvider = Provider<AnnouncementsRepository>((ref) {
  return const AnnouncementsRepository();
});

final mentorRequestsRepositoryProvider = Provider<MentorRequestsRepository>((ref) {
  return const MentorRequestsRepository();
});

final announcementsListProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
      final repository = ref.watch(announcementsRepositoryProvider);
      return repository.getAnnouncements();
    });

final createAnnouncementProvider =
    Provider<Future<void> Function(String title, String message)>((ref) {
      final repository = ref.watch(announcementsRepositoryProvider);
      return (String title, String message) async {
        await repository.createAnnouncement(title, message);
        ref.invalidate(announcementsListProvider);
      };
    });

final mentorRequestsListProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
      final repository = ref.watch(mentorRequestsRepositoryProvider);
      return repository.getMentorRequests();
    });

final updateMentorRequestStatusProvider =
    Provider<Future<void> Function(dynamic id, String status)>((ref) {
      final repository = ref.watch(mentorRequestsRepositoryProvider);
      return (dynamic id, String status) async {
        await repository.updateMentorRequestStatus(id, status);
        ref.invalidate(mentorRequestsListProvider);
      };
    });
