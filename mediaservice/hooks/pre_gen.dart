import 'package:mason/mason.dart';

import 'context_variables.dart';

void run(HookContext context) {
  // TODO: add pre-generation logic.
  context.vars['imagesOrVideos'] = context.images || context.videos;
  context.vars['imagesAndVideos'] = context.images && context.videos;
}
