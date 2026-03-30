import 'package:flutter/material.dart';
import 'dart:io';
import '../../core/theme/app_theme.dart';
import '../../services/session_service.dart';
import 'feed_repository.dart';
import 'image_upload_service.dart';

class CreatePostScreen extends StatefulWidget {
  final String teamId;
  final VoidCallback onPostCreated;

  const CreatePostScreen({
    super.key,
    required this.teamId,
    required this.onPostCreated,
  });

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _contentController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    final session = await SessionService.getSession();
    setState(() {
      _userEmail = session['email'];
    });
  }

  Future<void> _pickImage() async {
    try {
      final File? compressedImage =
          await ImageUploadService.pickAndCompressImage();

      if (compressedImage != null) {
        final sizeKB = await ImageUploadService.getFileSizeInKB(
          compressedImage,
        );
        print('Compressed image size: ${sizeKB.toStringAsFixed(2)} KB');

        setState(() {
          _selectedImage = compressedImage;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  Future<void> _createPost() async {
    // UPDATED: Allow either text OR image (or both)
    if (_contentController.text.isEmpty && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write something or add an image!'),
        ),
      );
      return;
    }

    if (_userEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: User email not found')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? imageUrl;

      // Upload image if selected
      if (_selectedImage != null) {
        imageUrl = await ImageUploadService.uploadImageToSupabase(
          _selectedImage!,
          widget.teamId,
          _userEmail!,
        );
      }

      // Create post with either text, image, or both
      await FeedRepository.createPost(
        userEmail: _userEmail!,
        teamId: widget.teamId,
        content: _contentController.text.isEmpty
            ? ''
            : _contentController.text, // Allow empty content
        imageUrl: imageUrl,
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Post created! 🎉')));
        _contentController.clear();
        setState(() {
          _selectedImage = null;
        });
        widget.onPostCreated();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error creating post: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBackground,
        elevation: 0,
        title: const Text('Create Post', style: AppTheme.pageTitle),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Content text field
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              decoration: AppTheme.cardDecoration(
                borderRadius: AppTheme.radiusLarge,
              ),
              child: TextField(
                controller: _contentController,
                maxLines: 5,
                minLines: 3,
                style: AppTheme.cardBody,
                decoration: InputDecoration(
                  hintText:
                      'Share your progress, ask for help, or celebrate! 🚀',
                  hintStyle: AppTheme.metaText,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),

            const SizedBox(height: AppTheme.spacingL),

            // Image preview
            if (_selectedImage != null) ...[
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  border: Border.all(color: AppTheme.borderColor, width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  child: Stack(
                    children: [
                      Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                      Positioned(
                        top: AppTheme.spacingM,
                        right: AppTheme.spacingM,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedImage = null;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(AppTheme.spacingS),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusMedium,
                              ),
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingL),
            ],

            // Action buttons
            Row(
              children: [
                // Image picker button
                Expanded(
                  child: GestureDetector(
                    onTap: _isLoading ? null : _pickImage,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppTheme.spacingL,
                      ),
                      decoration: AppTheme.cardDecoration(
                        borderRadius: AppTheme.radiusLarge,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_outlined,
                            color: _isLoading
                                ? AppTheme.textTertiary
                                : AppTheme.accentPrimary,
                            size: 20,
                          ),
                          const SizedBox(width: AppTheme.spacingM),
                          Text(
                            'Add Image',
                            style: AppTheme.cardTitle.copyWith(
                              color: _isLoading
                                  ? AppTheme.textTertiary
                                  : AppTheme.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: AppTheme.spacingM),

                // Post button
                Expanded(
                  child: GestureDetector(
                    onTap: _isLoading ? null : _createPost,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppTheme.spacingL,
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isLoading)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.accentPrimary,
                                ),
                              ),
                            )
                          else
                            Icon(
                              Icons.send_rounded,
                              color: AppTheme.accentPrimary,
                              size: 20,
                            ),
                          const SizedBox(width: AppTheme.spacingM),
                          Text(
                            _isLoading ? 'Posting...' : 'Post',
                            style: AppTheme.cardTitle.copyWith(
                              color: AppTheme.accentPrimary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
