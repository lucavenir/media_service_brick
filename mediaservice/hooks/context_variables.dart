import 'package:mason/mason.dart';

extension RiverpodCoreContextExt on HookContext {
  String get name => extract('name');

  T extract<T>(String varName) {
    if (!vars.containsKey(varName)) throw MissingContextVarException(varName);
    return vars[varName] as T;
  }
}

class MissingContextVarException implements Exception {
  MissingContextVarException(this.varName);
  final String varName;

  @override
  String toString() => 'Context variable $varName not found';
}
