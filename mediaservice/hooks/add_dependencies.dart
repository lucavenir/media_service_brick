import 'dart:io' as io;

import 'package:mason/mason.dart';

import 'context_variables.dart';

Future<void> addDependencies(HookContext context) async {
  final dependencies = [
    'dio',
    if (context.imagesOrVideos) 'image_picker',
    if (context.files) 'open_filex',
    if (context.files) 'file_picker',
    'path',
    'path_provider',
    'mime',
  ];

  final _ = await io.Process.run(
    'flutter',
    ['pub', 'add', ...dependencies],
    workingDirectory: './${context.name}',
  );
}
