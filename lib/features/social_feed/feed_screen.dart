import 'package:codenyx/features/social_feed/post_detail_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/session_service.dart';
import 'create_post_screen.dart';
import 'feed_repository.dart';
import 'post_state.dart';

class FeedScreen extends StatefulWidget {
  final String teamId;

  const FeedScreen({super.key, required this.teamId});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late Future<List<Map<String, dynamic>>> _postsFuture;
  late ScrollController _scrollController;
  int _currentOffset = 0;
  List<Map<String, dynamic>> _allPosts = [];
  String? _userEmail;
  bool _isLoadingMore = false;
  Map<String, bool> _expandedPosts = {};
  Map<String, List<Map<String, dynamic>>> _postComments = {};
  Map<String, bool> _deletingPosts = {};

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    PostState.changes.addListener(_handlePostStateChange);
    _loadUserEmail();
    _postsFuture = FeedRepository.fetchPosts(offset: _currentOffset);
  }

  void _handlePostStateChange() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _loadUserEmail() async {
    final session = await SessionService.getSession();
    if (mounted) {
      setState(() {
        _userEmail = session['email'];
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMorePosts();
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
      _currentOffset += 20;
    });

    try {
      final newPosts = await FeedRepository.fetchPosts(offset: _currentOffset);
      if (mounted) {
        setState(() {
          _allPosts.addAll(newPosts);
        });
      }
    } catch (e) {
      print('Error loading more posts: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _refreshFeed() async {
    setState(() {
      _currentOffset = 0;
      _allPosts = [];
      _expandedPosts.clear();
      _postComments.clear();
      PostState.clear();
      _postsFuture = FeedRepository.fetchPosts(offset: 0);
    });
  }

  Route<T> _buildSmoothRoute<T>(Widget page, {bool fullscreenDialog = false}) {
    return PageRouteBuilder<T>(
      fullscreenDialog: fullscreenDialog,
      transitionDuration: const Duration(milliseconds: 200),
      reverseTransitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0, 0.02),
          end: Offset.zero,
        ).animate(curvedAnimation);

        return FadeTransition(
          opacity: curvedAnimation,
          child: SlideTransition(position: slideAnimation, child: child),
        );
      },
    );
  }

  void _openCreatePostScreen() {
    Navigator.of(context).push(
      _buildSmoothRoute(
        CreatePostScreen(teamId: widget.teamId, onPostCreated: _refreshFeed),
        fullscreenDialog: true,
      ),
    );
  }

  void _togglePostExpanded(String postId) async {
    setState(() {
      _expandedPosts[postId] = !(_expandedPosts[postId] ?? false);
    });

    if (_expandedPosts[postId]! && !_postComments.containsKey(postId)) {
      try {
        final comments = await FeedRepository.getComments(postId);
        if (mounted) {
          setState(() {
            _postComments[postId] = comments;
          });
        }
      } catch (e) {
        print('Error loading comments: $e');
      }
    }
  }

  void _addComment(String postId) async {
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceLight,
        title: const Text('Add Comment', style: AppTheme.cardTitle),
        content: TextField(
          controller: commentController,
          style: AppTheme.cardBody,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Your comment...',
            hintStyle: AppTheme.metaText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              borderSide: const BorderSide(color: AppTheme.borderColor),
            ),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTheme.cardTitle.copyWith(color: AppTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (commentController.text.isNotEmpty && _userEmail != null) {
                try {
                  await FeedRepository.addComment(
                    postId,
                    _userEmail!,
                    commentController.text,
                  );
                  if (mounted) {
                    Navigator.pop(context);
                    final comments = await FeedRepository.getComments(postId);
                    setState(() {
                      _postComments[postId] = comments;
                    });
                  }
                } catch (e) {
                  print('Error adding comment: $e');
                }
              }
            },
            child: Text(
              'Post',
              style: AppTheme.cardTitle.copyWith(color: AppTheme.accentPrimary),
            ),
          ),
        ],
      ),
    );
  }

  void _deletePost(String postId, String? imageUrl) async {
    if (_userEmail == null) return;

    final isAuthor = await FeedRepository.isPostAuthor(postId, _userEmail!);
    if (!isAuthor) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can only delete your own posts'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceLight,
        title: const Text('Delete Post?', style: AppTheme.cardTitle),
        content: Text(
          'This action cannot be undone.',
          style: AppTheme.cardBody,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTheme.cardTitle.copyWith(color: AppTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performDeletePost(postId, imageUrl);
            },
            child: Text(
              'Delete',
              style: AppTheme.cardTitle.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performDeletePost(String postId, String? imageUrl) async {
    setState(() {
      _deletingPosts[postId] = true;
    });

    try {
      await FeedRepository.deletePost(postId, imageUrl: imageUrl);

      if (mounted) {
        setState(() {
          _allPosts.removeWhere((post) => post['id'] == postId);
          _expandedPosts.remove(postId);
          _postComments.remove(postId);
          _deletingPosts.remove(postId);
        });
        PostState.removePost(postId);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post deleted '),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('❌ Error deleting post: $e');

      if (mounted) {
        setState(() {
          _deletingPosts[postId] = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// TOGGLE LIKE - INSTANT UPDATE
  Future<void> _toggleLike(String postId) async {
    if (_userEmail == null) return;

    final index = _allPosts.indexWhere((p) => p['id'] == postId);
    if (index == -1) return;

    final post = _allPosts[index];
    final currentLikes = post['likes_count'] ?? 0;
    final wasLiked = (post['user_liked'] ?? false) as bool;

    // INSTANT UPDATE UI
    setState(() {
      post['likes_count'] = wasLiked ? currentLikes - 1 : currentLikes + 1;
      post['user_liked'] = !wasLiked;
    });

    // Save to cache
    PostState.updatePostLikes(postId, post['likes_count'], post['user_liked']);

    // Perform actual database operation in background
    try {
      if (wasLiked) {
        final success = await FeedRepository.unlikePost(postId, _userEmail!);
        if (!success && mounted) {
          // Revert on failure
          setState(() {
            post['likes_count'] = currentLikes;
            post['user_liked'] = wasLiked;
          });
          PostState.updatePostLikes(postId, currentLikes, wasLiked);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Failed to unlike')));
        }
      } else {
        final success = await FeedRepository.likePost(postId, _userEmail!);
        if (!success && mounted) {
          // Revert on failure
          setState(() {
            post['likes_count'] = currentLikes;
            post['user_liked'] = wasLiked;
          });
          PostState.updatePostLikes(postId, currentLikes, wasLiked);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Failed to like')));
        }
      }
    } catch (e) {
      print('Error toggling like: $e');
      if (mounted) {
        // Revert on error
        setState(() {
          post['likes_count'] = currentLikes;
          post['user_liked'] = wasLiked;
        });
        PostState.updatePostLikes(postId, currentLikes, wasLiked);
      }
    }
  }

  @override
  void dispose() {
    PostState.changes.removeListener(_handlePostStateChange);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _postsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.accentPrimary,
                ),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading feed: ${snapshot.error}',
                style: AppTheme.cardBody,
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.feed_outlined,
                    size: 48,
                    color: AppTheme.textTertiary,
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                  Text(
                    'No posts yet',
                    style: AppTheme.pageTitle.copyWith(fontSize: 24),
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  Text(
                    'Be the first to share your progress!',
                    style: AppTheme.cardBody,
                  ),
                  const SizedBox(height: AppTheme.spacingXL),
                  GestureDetector(
                    onTap: _openCreatePostScreen,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingL,
                        vertical: AppTheme.spacingM,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusLarge,
                        ),
                        border: Border.all(
                          color: AppTheme.accentPrimary.withOpacity(0.4),
                          width: 1.5,
                        ),
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.accentPrimary.withOpacity(0.2),
                            AppTheme.accentSecondary.withOpacity(0.1),
                          ],
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            color: AppTheme.accentPrimary,
                            size: 20,
                          ),
                          const SizedBox(width: AppTheme.spacingM),
                          Text(
                            'Create First Post',
                            style: AppTheme.cardTitle.copyWith(
                              color: AppTheme.accentPrimary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          _allPosts = snapshot.data!;

          // Cache posts for state management
          for (var post in _allPosts) {
            PostState.addPost(post['id'], post);
          }

          return RefreshIndicator(
            onRefresh: _refreshFeed,
            color: AppTheme.accentPrimary,
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spacingL,
                AppTheme.spacingM,
                AppTheme.spacingL,
                120,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFeedHeader(),
                  const SizedBox(height: AppTheme.spacingL),
                  _buildCreatePostButton(),
                  const SizedBox(height: AppTheme.spacingXL),
                  const Text("RECENT ACTIVITY", style: AppTheme.sectionHeader),
                  const SizedBox(height: AppTheme.spacingL),
                  ..._allPosts.map((post) => _buildPostCard(post)),
                  if (_isLoadingMore)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppTheme.spacingL,
                      ),
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.accentPrimary,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeedHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Social Feed", style: AppTheme.pageTitle),
        const SizedBox(height: AppTheme.spacingS),
        Text("Stay updated with your team", style: AppTheme.cardBody),
      ],
    );
  }

  Widget _buildCreatePostButton() {
    return GestureDetector(
      onTap: _openCreatePostScreen,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        decoration: AppTheme.cardDecoration(borderRadius: AppTheme.radiusLarge),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.accentPrimary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: Center(
                child: Icon(Icons.add, color: AppTheme.accentPrimary, size: 22),
              ),
            ),
            const SizedBox(width: AppTheme.spacingL),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Share your progress', style: AppTheme.cardTitle),
                  const SizedBox(height: 4),
                  Text('Text, image, or both', style: AppTheme.metaText),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    final postId = post['id'];
    final isExpanded = _expandedPosts[postId] ?? false;
    final isHighlighted = (post['likes_count'] ?? 0) > 0;
    final isDeleting = _deletingPosts[postId] ?? false;
    final isPostAuthor = _userEmail == post['user_email'];
    final isLiked = (post['user_liked'] ?? false) as bool;

    return Opacity(
      opacity: isDeleting ? 0.5 : 1.0,
      child: GestureDetector(
        onTap: isDeleting
            ? null
            : () {
                if (_userEmail == null) return;

                Navigator.of(context).push(
                  _buildSmoothRoute(
                    PostDetailScreen(post: post, userEmail: _userEmail!),
                  ),
                );
              },
        child: Container(
          margin: EdgeInsets.only(bottom: kIsWeb ? AppTheme.spacingXL : AppTheme.spacingM),
          padding: const EdgeInsets.all(AppTheme.spacingL),
          decoration: isHighlighted
              ? AppTheme.accentCardDecoration()
              : AppTheme.cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.accentPrimary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(
                        AppTheme.radiusMedium,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        ((post['user_name'] ?? post['user_email']) as String)[0].toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.accentPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post['user_name'] ?? post['user_email'] ?? 'Unknown',
                          style: AppTheme.cardTitle.copyWith(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatTime(post['created_at']),
                          style: AppTheme.metaText,
                        ),
                      ],
                    ),
                  ),
                  if (isPostAuthor)
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert,
                        color: AppTheme.textSecondary,
                        size: 18,
                      ),
                      color: AppTheme.surfaceLight,
                      onSelected: (value) {
                        if (value == 'delete') {
                          _deletePost(postId, post['image_url']);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              const SizedBox(width: AppTheme.spacingM),
                              Text(
                                'Delete',
                                style: AppTheme.cardBody.copyWith(
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingL),
              Text(post['content'] ?? '', style: AppTheme.cardBody),
              const SizedBox(height: AppTheme.spacingL),
              if (post['image_url'] != null &&
                  (post['image_url'] as String).isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacingL),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    child: Image.network(
                      post['image_url'],
                      fit: BoxFit.contain,
                      width: double.infinity,
                      cacheHeight: 360,
                      cacheWidth: 360,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(AppTheme.spacingXL),
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentPrimary),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 180,
                          color: AppTheme.surfaceLight,
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: AppTheme.textTertiary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              Row(
                children: [
                  GestureDetector(
                    onTap: (_userEmail != null && !isDeleting)
                        ? () => _toggleLike(postId)
                        : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingM,
                        vertical: AppTheme.spacingS,
                      ),
                      decoration: BoxDecoration(
                        color: isLiked
                            ? AppTheme.accentPrimary.withOpacity(0.2)
                            : AppTheme.accentPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusSmall,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked
                                ? AppTheme.accentPrimary
                                : AppTheme.accentPrimary.withOpacity(0.7),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${post['likes_count'] ?? 0}',
                            style: AppTheme.metaText.copyWith(
                              color: AppTheme.accentPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  GestureDetector(
                    onTap: !isDeleting
                        ? () => _togglePostExpanded(postId)
                        : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingM,
                        vertical: AppTheme.spacingS,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accentSecondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusSmall,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            color: AppTheme.accentSecondary,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Expand',
                            style: AppTheme.metaText.copyWith(
                              color: AppTheme.accentSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (isExpanded) ...[
                const SizedBox(height: AppTheme.spacingL),
                Divider(color: AppTheme.borderColor),
                const SizedBox(height: AppTheme.spacingL),
                _buildCommentsSection(postId),
                const SizedBox(height: AppTheme.spacingL),
                GestureDetector(
                  onTap: !isDeleting ? () => _addComment(postId) : null,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppTheme.spacingM,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.accentPrimary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_comment_outlined,
                          color: AppTheme.accentPrimary,
                          size: 18,
                        ),
                        const SizedBox(width: AppTheme.spacingS),
                        Text(
                          'Add a comment',
                          style: AppTheme.metaText.copyWith(
                            color: AppTheme.accentPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommentsSection(String postId) {
    final comments = _postComments[postId] ?? [];

    if (comments.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingL),
          child: Text(
            'No comments yet. Be the first!',
            style: AppTheme.metaText,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${comments.length} Comment${comments.length != 1 ? 's' : ''}',
          style: AppTheme.sectionHeader,
        ),
        const SizedBox(height: AppTheme.spacingM),
        ...comments.map((comment) => _buildCommentItem(comment)),
      ],
    );
  }

  Widget _buildCommentItem(Map<String, dynamic> comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppTheme.accentPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Center(
                  child: Text(
                    ((comment['user_name'] ?? comment['user_email']) as String)[0].toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.accentPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Text(
                  comment['user_name'] ?? comment['user_email'] ?? 'Unknown',
                  style: AppTheme.metaText.copyWith(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            comment['comment'] ?? '',
            style: AppTheme.cardBody.copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null) return '';
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inSeconds < 60) {
        return 'just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    } catch (e) {
      return '';
    }
  }
}
