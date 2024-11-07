class UnsupportedMediaException implements Exception {
  UnsupportedMediaException(this.mimeType);
  final String mimeType;

  @override
  String toString() {
    return 'Unsupported attachment type: $mimeType';
  }
}
