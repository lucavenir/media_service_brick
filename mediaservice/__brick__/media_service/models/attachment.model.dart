sealed class Attachment {
  const Attachment();
  Uri get uri;
}

sealed class PictureAttachment extends Attachment {
  const PictureAttachment();
}

sealed class VideoAttachment extends Attachment {
  const VideoAttachment();
}

sealed class PdfAttachment extends Attachment {
  const PdfAttachment();
}

sealed class LocalAttachment extends Attachment {
  const LocalAttachment();
}

class LocalPictureAttachment extends LocalAttachment implements PictureAttachment {
  const LocalPictureAttachment(this.uri);
  @override
  final Uri uri;
}

class LocalVideoAttachment extends LocalAttachment implements VideoAttachment {
  const LocalVideoAttachment(this.uri);
  @override
  final Uri uri;
}

class LocalPdfAttachment extends LocalAttachment implements PdfAttachment {
  const LocalPdfAttachment(this.uri);
  @override
  final Uri uri;
}

sealed class NetworkAttachment extends Attachment {
  const NetworkAttachment(this.uri);
  @override
  final Uri uri;
}

class NetworkPictureAttachment extends NetworkAttachment implements PictureAttachment {
  const NetworkPictureAttachment(super.uri);
}

class NetworkVideoAttachment extends NetworkAttachment implements VideoAttachment {
  const NetworkVideoAttachment(super.uri);
}

class NetworkPdfAttachment extends NetworkAttachment implements PdfAttachment {
  const NetworkPdfAttachment(super.uri);
}
