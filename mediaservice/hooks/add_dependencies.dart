import 'dart:io' as io;

import 'package:mason/mason.dart';

import 'context_variables.dart';

Future<void> addDependencies(HookContext context) async {
  final dependencies = [
    // TODO(dario): if (hooks) ...
    'hooks_riverpod',
    // TODO(dario): else ...
    'flutter_riverpod',
    'riverpod_annotation',
    'freezed_annotation',
    'json_annotation',
    'dio',
    // TODO(dario): if (images) ...
    'image_picker',
    // TODO(dario): if (files) ...
    'open_filex',
    'path',
    'path_provider',
    'mime',
    'talker_dio_logger', // TODO(dario): ?
    'stack_trace', // TODO(dario): ?
  ];

  final devDependencies = [
    // TODO(dario): if (generation) ...
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
