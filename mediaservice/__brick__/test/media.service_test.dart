import 'dart:io' as io;
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

import 'package:mocktail/mocktail.dart';

import '../lib/errors/canceled_media_pick.exception.dart';
import '../lib/errors/unsupported_media.exception.dart';
import '../lib/models/attachment.model.dart';
import '../lib/service/media.service.dart';

class MockDio extends Mock implements Dio {}

class MockImagePicker extends Mock implements ImagePicker {}

void main() {
  late MediaService mediaService;
  late MockDio mockDio;
  late MockImagePicker mockImagePicker;

  setUp(() {
    mockDio = MockDio();
    mockImagePicker = MockImagePicker();

    mediaService = MediaService(httpClient: mockDio, imagePicker: mockImagePicker);
  });

  group('MediaService', () {
    const testImagePath = '/path/to/image.jpg';
    const testVideoPath = '/path/to/video.mp4';
    const testNotSupportedPath = '/path/to/file.idontknow';

    group('pickImageFromGallery', () {
      test('returns LocalPictureAttachment if image is picked from gallery', () async {
        when(() => mockImagePicker.pickImage(source: ImageSource.gallery))
            .thenAnswer((_) async => XFile(testImagePath));

        final result = await mediaService.pickImageFromGallery();

        expect(result, isA<LocalPictureAttachment>());
      });

      test('throws CanceledMediaOperationException if image picking is canceled', () async {
        when(() => mockImagePicker.pickImage(source: ImageSource.gallery))
            .thenAnswer((_) async => null);

        expect(
          () => mediaService.pickImageFromGallery(),
          throwsA(isA<CanceledMediaOperationException>()),
        );
      });
    });

    group('pickVideoFromGallery', () {
      test('returns LocalVideoAttachment if video is picked from gallery', () async {
        when(() => mockImagePicker.pickVideo(source: ImageSource.gallery))
            .thenAnswer((_) async => XFile(testVideoPath));

        final result = await mediaService.pickVideoFromGallery();

        expect(result, isA<LocalVideoAttachment>());
      });

      test('throws CanceledMediaOperationException if video picking is canceled', () async {
        when(() => mockImagePicker.pickVideo(source: ImageSource.gallery))
            .thenAnswer((_) async => null);

        expect(
          () => mediaService.pickVideoFromGallery(),
          throwsA(isA<CanceledMediaOperationException>()),
        );
      });
    });

    group('mimeTypeLookup', () {
      test('returns correct MIME type ', () {
        final mimeType = mediaService.mimeTypeLookup(testImagePath);
        expect(mimeType, 'image/jpeg');
      });

      test('throws UnsupportedMediaException if MIME type is not supported', () {
        expect(
          () => mediaService.mimeTypeLookup(testNotSupportedPath),
          throwsA(isA<UnsupportedMediaException>()),
        );
      });
    });
  });
}
