import 'dart:io' as io;

import 'package:mason/mason.dart';

import 'context_variables.dart';

Future<void> addDependencies(HookContext context) async {
  final dependencies = [
    'dio',
    if (context.hooks) 'hooks_riverpod' else 'flutter_riverpod',
    if (context.hooks) 'flutter_hooks',
    if (context.imagesOrVideos) 'image_picker',
    if (context.files) 'open_filex',
    if (context.files) 'file_picker',
    if (context.generation) 'riverpod_annotation',
    'path',
    'path_provider',
    'mime',
  ];

  final devDependencies = [
    if (context.generation) 'build_runner',
    if (context.generation) 'riverpod_generator',
    'mocktail',
    'riverpod_lint',
  ];

  final _ = await io.Process.run(
    'flutter',
    ['pub', 'add', ...dependencies, ...devDependencies.map((e) => 'dev:$e')],
    workingDirectory: './${context.name}',
  );
}
