import 'package:mason/mason.dart';

import 'add_dependencies.dart';
import 'execute_and_log.dart';
import 'run_build_runner.dart';
import 'upgrade_dependencies.dart';

Future<void> run(HookContext context) async {
  await executeLogAndWait(
    context: context,
    cb: addDependencies,
    message: 'Adding dependencies..',
  );

  await executeLogAndWait(
    context: context,
    cb: upgradeDependencies,
    message: 'Upgrading dependencies..',
  );

  // TODO(dario): if (generation) ...
  await executeLogAndWait(
    context: context,
    cb: runBuildRunner,
    message: 'Running `build_runner`..',
  );
}
