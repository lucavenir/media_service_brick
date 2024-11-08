import 'dart:convert' as convert;
import 'dart:io' as io;
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:oneplatform/api/attachments/upload_attachment_request.api.model.dart';
import 'package:oneplatform/api/auth_http_client.dart';
import 'package:oneplatform/src/attachments/errors/canceled_image_pick.exception.dart';
import 'package:oneplatform/src/attachments/errors/unsupported_media.exception.dart';
import 'package:oneplatform/src/attachments/models/attachment.model.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:riverpod_annotation/riverpod_annotation.dart';
{{#files}}
import 'package:file_picker/file_picker.dart';
{{/files}}


import '../errors/canceled_media_pick.exception.dart';
import '../errors/unsupported_media.exception.dart';
import '../models/attachment.model.dart';

class MediaService {
  const MediaService({
    required this.httpClient,
    required this.imagePicker,
  });
  final Dio httpClient;
  final ImagePicker imagePicker;


  {{#videos}}
  {{#images}}
  Future<LocalAttachment> pickMedia() async {
    final result = await imagePicker.pickMedia();
    if (result == null) throw const CanceledMediaOperationException();
    final mimeType = mimeTypeLookup(result.path);
    final split = mimeType.split('/');
    final type = split.first;
    final uri = Uri.file(result.path);
    return switch (type) {
      'image' => LocalPictureAttachment(uri),
      'video' => LocalVideoAttachment(uri),
      'pdf' => LocalPdfAttachment(uri),
      _ => throw UnsupportedMediaException(mimeType),
    };
  }
  {{/videos}}
  {{/images}}


   {{^videos}}
   {{#images}}
  Future<LocalPictureAttachment> pickImageFromGallery() async {
    final result = await imagePicker.pickImage(source: ImageSource.gallery);
    if (result == null) throw const CanceledMediaOperationException();
    final uri = Uri.file(result.path);
    return LocalPictureAttachment(uri);
  }
   {{/videos}}
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
   {{^images}}
  Future<LocalAttachment> pickVideoFromGallery() async {
    final result = await imagePicker.pickVideo(source: ImageSource.gallery);
    if (result == null) throw const CanceledMediaOperationException();
    final uri = Uri.file(result.path);
    return LocalVideoAttachment(uri);
  }
  {{/videos}}
  {{/images}}

  
  {{#videos}}
  Future<LocalAttachment> pickVideoFromCamera() async {
    final result = await imagePicker.pickVideo(source: ImageSource.camera);
    if (result == null) throw const CanceledMediaOperationException();
    final uri = Uri.file(result.path);
    return LocalVideoAttachment(uri);
  }
  {{/videos}}
 
 {{#files}}
 {{^images}}
 {{^videos}}
 Future<LocalAttachment> pickPdf()async{
  final f = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf'], allowMultiple: false);
  if (f == null) throw const CanceledMediaOperationException();
  final uri = Uri.file(f.files.first.path!);
  return LocalPdfAttachment(uri);
    
 }
 {{/files}}
 {{/videos}}
 {{/images}} 


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
