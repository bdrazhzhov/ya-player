class TrackDownloadInfo {
  final String codec;
  final bool gain;
  final bool preview;
  final Uri downloadInfoUrl;
  final bool direct;
  final int bitrateInKbps;

  TrackDownloadInfo(this.codec, this.gain, this.preview,
      this.downloadInfoUrl, this.direct, this.bitrateInKbps);

  factory TrackDownloadInfo.fromJson(Map<String, dynamic> json) {
    return TrackDownloadInfo(json['codec'], json['gain'], json['preview'],
        Uri.parse(json['downloadInfoUrl']), json['direct'], json['bitrateInKbps']);
  }
}

class FileDownloadInfo {
  final String s;
  final String ts;
  final String path;
  final String host;

  FileDownloadInfo(this.s, this.ts, this.path, this.host);

  factory FileDownloadInfo.fromJson(Map<String, dynamic> json) {
    return FileDownloadInfo(json['s'], json['ts'], json['path'], json['host']);
  }
}
