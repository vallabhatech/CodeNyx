import 'package:flutter/foundation.dart';

class PostState {
  static final Map<String, Map<String, dynamic>> _postCache = {};
  static final ValueNotifier<int> changes = ValueNotifier<int>(0);

  static void updatePostLikes(String postId, int likesCount, bool isLiked) {
    if (_postCache.containsKey(postId)) {
      _postCache[postId]!['likes_count'] = likesCount;
      _postCache[postId]!['user_liked'] = isLiked;
      changes.value++;
    }
  }

  static Map<String, dynamic>? getPost(String postId) {
    return _postCache[postId];
  }

  static void addPost(String postId, Map<String, dynamic> post) {
    final cachedPost = _postCache[postId];
    if (cachedPost != null) {
      post['likes_count'] = cachedPost['likes_count'] ?? post['likes_count'];
      post['user_liked'] = cachedPost['user_liked'] ?? post['user_liked'];
    }
    _postCache[postId] = post;
  }

  static void removePost(String postId) {
    _postCache.remove(postId);
    changes.value++;
  }

  static void clear() {
    _postCache.clear();
    changes.value++;
  }
}
