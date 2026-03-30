import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:io';
import '../../services/supabase_service.dart';

class ImageUploadService {
  static const String storageBucket = 'feed-images';
  static const int maxWidth = 1080;
  static const int maxHeight = 1080;
  static const int quality = 70;

  /// Pick image from device and compress it
  static Future<File?> pickAndCompressImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null) return null;

      final compressedFile = await compressImage(File(image.path));
      return compressedFile;
    } catch (e) {
      print('Error picking image: $e');
      rethrow;
    }
  }

  /// Compress image file
  static Future<File?> compressImage(File imageFile) async {
    try {
      final String targetPath = imageFile.absolute.path.replaceAll(
        '.jpg',
        '_compressed.jpg',
      );

      final XFile? compressedFile =
          await FlutterImageCompress.compressAndGetFile(
            imageFile.absolute.path,
            targetPath,
            quality: quality,
            format: CompressFormat.jpeg,
          );

      if (compressedFile == null) return null;

      return File(compressedFile.path);
    } catch (e) {
      print('Error compressing image: $e');
      rethrow;
    }
  }

  /// Upload compressed image to Supabase Storage
  static Future<String> uploadImageToSupabase(
    File imageFile,
    String teamId,
    String userEmail,
  ) async {
    try {
      final String fileName =
          '${teamId}_${userEmail}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      await SupabaseService.client.storage
          .from(storageBucket)
          .upload(fileName, imageFile);
          print("Uploading to bucket: $storageBucket");

      // Get public URL
      final String publicUrl = SupabaseService.client.storage
          .from(storageBucket)
          .getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }

  /// Get file size in KB
  static Future<double> getFileSizeInKB(File file) async {
    final int bytes = await file.length();
    return bytes / 1024;
  }
}
