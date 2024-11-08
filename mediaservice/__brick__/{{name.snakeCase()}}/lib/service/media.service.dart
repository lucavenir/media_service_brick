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

  // TODO(dario): if (image && video) ...
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
      _ => throw UnsupportedMediaException(mimeType),
    };
  }
  // TODO(dario): else if (image && !video) ...
  // TODO(dario): else if (!image && video) ...

  // TODO(dario): if (image) ...
  Future<LocalPictureAttachment> pickImageFromCamera() async {
    final result = await imagePicker.pickImage(source: ImageSource.camera);
    if (result == null) throw const CanceledMediaOperationException();
    final file = io.File(result.path);
    return LocalPictureAttachment(file);
  }

  // TODO(dario): if (video) ...
  // TODO(dario): implement video pick from camera

  // TODO(dario): delete this
  Future<void> downloadAndOpen({
    required NetworkAttachment attachment,
  }) async {
    final file = await download(attachment: attachment);
    await openFile(File(file.path));
  }

  // TODO(dario): if (file_open) ...
  Future<void> openFile(io.File file) {
    return OpenFilex.open(file.path);
  }

  // TODO(dario): if (file_download) ...
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
