import '../../services/supabase_service.dart';

class FeedRepository {
  /// Create a new post
  static Future<Map<String, dynamic>> createPost({
    required String userEmail,
    required String teamId,
    required String content,
    String? imageUrl,
  }) async {
    try {
      final response = await SupabaseService.client
          .from('posts')
          .insert({
            'user_email': userEmail,
            'team_id': teamId,
            'content': content,
            'image_url': imageUrl,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return response;
    } catch (e) {
      print('Error creating post: $e');
      rethrow;
    }
  }

  /// Fetch all posts WITH likes count + user liked state
  static Future<List<Map<String, dynamic>>> fetchPosts({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final currentUserEmail = SupabaseService.client.auth.currentUser?.email;

      final response = await SupabaseService.client
          .from('posts')
          .select(
            'id, user_email, team_id, content, image_url, created_at, likes(user_email)',
          )
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final posts = List<Map<String, dynamic>>.from(response);

      // Fetch member names
      final uniqueEmails = posts.map((p) => p['user_email'] as String).toSet().toList();
      final emailToName = <String, String>{};

      if (uniqueEmails.isNotEmpty) {
        try {
          final membersRes = await SupabaseService.client
              .from('team_members')
              .select('email, name')
              .filter('email', 'in', uniqueEmails);
          
          for (var member in membersRes) {
            final email = member['email']?.toString();
            final name = member['name']?.toString();
            if (email != null && name != null && name.trim().isNotEmpty) {
              emailToName[email] = name.trim();
            }
          }
        } catch (e) {
          print('Error fetching member names for posts: $e');
        }
      }

      for (var post in posts) {
        final userEmail = post['user_email'] as String;
        final name = emailToName[userEmail] ?? emailToName[userEmail.toLowerCase()];
        
        post['user_name'] = name ?? userEmail.split('@')[0];

        final likes = post['likes'] as List;

        // Total likes
        post['likes_count'] = likes.length;

        // Whether current user liked
        post['user_liked'] = likes.any(
          (like) => like['user_email'] == currentUserEmail,
        );

        // Clean up
        post['likes'] = null;
      }

      return posts;
    } catch (e) {
      print('Error fetching posts: $e');
      return [];
    }
  }

  static Future<void> deleteComment(String commentId) async {
    try {
      await SupabaseService.client
          .from('comments')
          .delete()
          .eq('id', commentId);
    } catch (e) {
      print('Error deleting comment: $e');
    }
  }

  /// Get a single post
  static Future<Map<String, dynamic>> getPost(String postId) async {
    try {
      final currentUserEmail = SupabaseService.client.auth.currentUser?.email;

      final response = await SupabaseService.client
          .from('posts')
          .select(
            'id, user_email, team_id, content, image_url, created_at, likes(user_email)',
          )
          .eq('id', postId)
          .single();

      final likes = response['likes'] as List;

      response['likes_count'] = likes.length;

      response['user_liked'] = likes.any(
        (like) => like['user_email'] == currentUserEmail,
      );

      response['likes'] = null;

      return response;
    } catch (e) {
      print('Error fetching post: $e');
      rethrow;
    }
  }

  /// Like a post
  static Future<bool> likePost(String postId, String userEmail) async {
    try {
      final alreadyLiked = await hasUserLikedPost(postId, userEmail);
      if (alreadyLiked) return false;

      await SupabaseService.client.from('likes').insert({
        'post_id': postId,
        'user_email': userEmail,
        'created_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Error liking post: $e');
      return false;
    }
  }

  /// Unlike a post
  static Future<bool> unlikePost(String postId, String userEmail) async {
    try {
      await SupabaseService.client
          .from('likes')
          .delete()
          .eq('post_id', postId)
          .eq('user_email', userEmail);

      return true;
    } catch (e) {
      print('Error unliking post: $e');
      return false;
    }
  }

  /// Check if user liked post
  static Future<bool> hasUserLikedPost(String postId, String userEmail) async {
    try {
      final response = await SupabaseService.client
          .from('likes')
          .select('id')
          .eq('post_id', postId)
          .eq('user_email', userEmail)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('Error checking like: $e');
      return false;
    }
  }

  /// Get likes count
  static Future<int> getLikesCount(String postId) async {
    try {
      final response = await SupabaseService.client
          .from('likes')
          .select('id')
          .eq('post_id', postId);

      return response.length;
    } catch (e) {
      print('Error getting likes count: $e');
      return 0;
    }
  }

  /// Add comment
  static Future<Map<String, dynamic>> addComment(
    String postId,
    String userEmail,
    String comment,
  ) async {
    try {
      final response = await SupabaseService.client
          .from('comments')
          .insert({
            'post_id': postId,
            'user_email': userEmail,
            'comment': comment,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return response;
    } catch (e) {
      print('Error adding comment: $e');
      rethrow;
    }
  }

  /// Get comments
  static Future<List<Map<String, dynamic>>> getComments(String postId) async {
    try {
      final response = await SupabaseService.client
          .from('comments')
          .select()
          .eq('post_id', postId)
          .order('created_at', ascending: true);

      final comments = List<Map<String, dynamic>>.from(response);

      final uniqueEmails = comments.map((c) => c['user_email'] as String).toSet().toList();
      final emailToName = <String, String>{};

      if (uniqueEmails.isNotEmpty) {
        try {
          final membersRes = await SupabaseService.client
              .from('team_members')
              .select('email, name')
              .filter('email', 'in', uniqueEmails);
          
          for (var member in membersRes) {
            final email = member['email']?.toString();
            final name = member['name']?.toString();
            if (email != null && name != null && name.trim().isNotEmpty) {
              emailToName[email] = name.trim();
            }
          }
        } catch (e) {
          print('Error fetching member names for comments: $e');
        }
      }

      for (var comment in comments) {
        final userEmail = comment['user_email'] as String;
        final name = emailToName[userEmail] ?? emailToName[userEmail.toLowerCase()];
        comment['user_name'] = name ?? userEmail.split('@')[0];
      }

      return comments;
    } catch (e) {
      print('Error fetching comments: $e');
      return [];
    }
  }

  /// Check post author
  static Future<bool> isPostAuthor(String postId, String userEmail) async {
    try {
      final response = await SupabaseService.client
          .from('posts')
          .select('user_email')
          .eq('id', postId)
          .single();

      return response['user_email'] == userEmail;
    } catch (e) {
      print('Error checking post author: $e');
      return false;
    }
  }

  /// Delete image
  static Future<void> deleteImageFromStorage(String imageUrl) async {
    try {
      final fileName = imageUrl.split('/').last;

      await SupabaseService.client.storage.from('feed-images').remove([
        fileName,
      ]);
    } catch (e) {
      print('Error deleting image: $e');
    }
  }

  /// Delete post
  static Future<void> deletePost(String postId, {String? imageUrl}) async {
    try {
      if (imageUrl != null && imageUrl.isNotEmpty) {
        await deleteImageFromStorage(imageUrl);
      }

      await SupabaseService.client.from('likes').delete().eq('post_id', postId);

      await SupabaseService.client
          .from('comments')
          .delete()
          .eq('post_id', postId);

      await SupabaseService.client.from('posts').delete().eq('id', postId);
    } catch (e) {
      print('Error deleting post: $e');
      rethrow;
    }
  }
}
