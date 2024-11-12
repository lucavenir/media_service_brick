import 'dart:convert' as convert;
import 'dart:io' as io;
import 'dart:io';
{{#generation}}
import 'package:riverpod_annotation/riverpod_annotation.dart';
{{/generation}}
{{^generation}}
{{#hooks}}
import 'package:hooks_riverpod/hooks_riverpod.dart';
{{/hooks}}
{{^hooks}}
import 'package:flutter_riverpod/flutter_riverpod.dart';
{{/hooks}}
{{/generation}}

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
{{#imagesOrVideos}}
import 'package:image_picker/image_picker.dart';
{{/imagesOrVideos}}
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path_provider;
{{#files}}
import 'package:open_filex/open_filex.dart';
import 'package:file_picker/file_picker.dart';
{{/files}}


import '../errors/canceled_media_pick.exception.dart';
import '../errors/unsupported_media.exception.dart';
import '../models/attachment.model.dart';


part 'media.service.g.dart';

{{#imagesOrVideos}}
@riverpod
ImagePicker imagePicker(ImagePickerRef ref) {
  return ImagePicker();
}
{{/imagesOrVideos}}

@riverpod
MediaService mediaService(MediaServiceRef ref) {
  final client = ref.watch(authHttpClientProvider);
  {{#imagesOrVideos}}
   final picker = ref.watch(imagePickerProvider);
{{/imagesOrVideos}}
  
  return MediaService(
    
    httpClient: client,
{{#imagesOrVideos}}
    imagePicker: picker,
{{/imagesOrVideos}}
  );
}

class MediaService {
  const MediaService({
    required this.httpClient,
    {{#imagesOrVideos}}
    required this.imagePicker,
    {{/imagesOrVideos}}
  });
  final Dio httpClient;
  {{#imagesOrVideos}}
  final ImagePicker imagePicker;
  {{/imagesOrVideos}}


  {{#imagesAndVideos}}
  Future<LocalAttachment> pickVideosOrImagesFromGallery() async {
    final result = await imagePicker.pickMedia();
    if (result == null) throw const CanceledMediaOperationException();
    final mimeType = mimeTypeLookup(result.path);
    final split = mimeType.split('/');
    final type = split.first;
    final uri = Uri.file(result.path);
    return switch (type) {
      'image' => LocalPictureAttachment(uri),
      'video' => LocalVideoAttachment(uri),
      _ => throw UnsupportedMediaException(mimeType),
    };
  }
  {{/imagesAndVideos}}

  {{#images}}
  Future<LocalPictureAttachment> pickImageFromGallery() async {
    final result = await imagePicker.pickImage(source: ImageSource.gallery);
    if (result == null) throw const CanceledMediaOperationException();
    final uri = Uri.file(result.path);
    return LocalPictureAttachment(uri);
  }
  {{/images}}

  
  {{#images}}
   Future<LocalPictureAttachment> pickImageFromCamera() async {
    final result = await imagePicker.pickImage(source: ImageSource.camera);
    if (result == null) throw const CanceledMediaOperationException();
    final file = Uri.file(result.path);
    return LocalPictureAttachment(file);
  } 
  {{/images}}


  {{#videos}}
  Future<LocalAttachment> pickVideoFromGallery() async {
    final result = await imagePicker.pickVideo(source: ImageSource.gallery);
    if (result == null) throw const CanceledMediaOperationException();
    final uri = Uri.file(result.path);
    return LocalVideoAttachment(uri);
  }
  {{/videos}}

  {{#videos}}
  Future<LocalAttachment> pickVideoFromCamera() async {
    final result = await imagePicker.pickVideo(source: ImageSource.camera);
    if (result == null) throw const CanceledMediaOperationException();
    final uri = Uri.file(result.path);
    return LocalVideoAttachment(uri);
  }
  {{/videos}}
 
 {{#files}}
 Future<LocalAttachment> pickPdf() async {
  final f = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf'], allowMultiple: false);
  if (f == null) throw const CanceledMediaOperationException();
  final uri = Uri.file(f.files.first.path!);
  return LocalPdfAttachment(uri);
 }
 {{/files}}

  {{#files}}
  Future<void> openFile(Uri uri) {
    return OpenFilex.open(uri.path);
  }
  {{/files}}


  Future<Uri> download({required NetworkAttachment attachment}) async {
    final dir = await path_provider.getDownloadsDirectory();
    final filePath = path.join(dir!.path, attachment.uri.pathSegments.last);
    final _ = await httpClient.downloadUri(attachment.uri, filePath);
    final file = Uri.file(filePath);
    return file;
  }

  @protected
  Future<String> base64Encode(io.File file) {
    return compute(encodeToBase64, file);
  }

  @protected
  @visibleForTesting
  String mimeTypeLookup(String path) {
    final mimeType = lookupMimeType(path);
    if (mimeType == null) {
      throw UnsupportedMediaException('Unrecognizable MIME type');
    }

    return mimeType;
  }

  @protected
  @visibleForTesting
  void assertIsImageOrVideo(String mimeType) {
    final split = mimeType.split('/');
    final type = split.first;
    final isMedia = type == 'image' || type == 'video';
    if (!isMedia) throw UnsupportedMediaException(mimeType);
  }
}

@protected
Future<String> encodeToBase64(io.File file) async {
  final bytes = await file.readAsBytes();
  return convert.base64.encode(bytes);
}
