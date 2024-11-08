import 'dart:io' as io;

import 'package:mason/mason.dart';

import 'context_variables.dart';

Future<void> addDependencies(HookContext context) async {
  final dependencies = [
    if (context.hooks) 'hooks_riverpod' else 'flutter_riverpod',
    if (context.hooks) 'flutter_hooks',
    'riverpod_annotation',
    'freezed_annotation',
    'json_annotation',
    'dio',
    if (context.images) 'image_picker',
    if (context.files) 'open_filex',
    if (context.files) 'file_picker',
    'path',
    'path_provider',
    'mime',
  ];

  final devDependencies = [
    if (context.generation) 'build_runner',
    'freezed',
    'json_serializable',
    'riverpod_generator',
  ];

  final _ = await io.Process.run(
    'flutter',
    ['pub', 'add', ...dependencies, ...devDependencies.map((e) => 'dev:$e')],
    workingDirectory: './${context.name}',
  );
}
