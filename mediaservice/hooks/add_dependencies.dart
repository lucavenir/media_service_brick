import 'dart:io' as io;

import 'package:mason/mason.dart';

import 'context_variables.dart';

Future<void> addDependencies(HookContext context) async {
  final dependencies = [
    'hooks_riverpod',
    'flutter_riverpod',
    'flutter_hooks',
    'riverpod_annotation',
    'freezed_annotation',
    'json_annotation',
    'dio',
    'image_picker',
    'open_filex',
    'path',
    'path_provider',
    'mime',
    'talker_dio_logger',
    'stack_trace',
  ];

  final devDependencies = [
    'build_runner',
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
