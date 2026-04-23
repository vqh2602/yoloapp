enum YoloModelSourceType { none, asset, localFile, remoteUrl }

/// Mô tả nguồn model hiện tại được sử dụng bởi cả luồng hình ảnh và camera.
class YoloModelDescriptor {
  const YoloModelDescriptor({
    required this.label,
    required this.path,
    required this.sourceType,
  });

  factory YoloModelDescriptor.empty() {
    return const YoloModelDescriptor(
      label: 'Chưa chọn model',
      path: '',
      sourceType: YoloModelSourceType.none,
    );
  }

  factory YoloModelDescriptor.asset({
    required String label,
    required String path,
  }) {
    return YoloModelDescriptor(
      label: label,
      path: path,
      sourceType: YoloModelSourceType.asset,
    );
  }

  factory YoloModelDescriptor.localFile({
    required String label,
    required String path,
  }) {
    return YoloModelDescriptor(
      label: label,
      path: path,
      sourceType: YoloModelSourceType.localFile,
    );
  }

  factory YoloModelDescriptor.remoteUrl({
    required String label,
    required String url,
  }) {
    return YoloModelDescriptor(
      label: label,
      path: url,
      sourceType: YoloModelSourceType.remoteUrl,
    );
  }

  final String label;
  final String path;
  final YoloModelSourceType sourceType;

  bool get isEmpty => path.trim().isEmpty;
  bool get isAsset => sourceType == YoloModelSourceType.asset;
  bool get isRemoteUrl => sourceType == YoloModelSourceType.remoteUrl;

  String get sourceLabel {
    switch (sourceType) {
      case YoloModelSourceType.none:
        return 'Chưa chọn';
      case YoloModelSourceType.asset:
        return 'Assets';
      case YoloModelSourceType.localFile:
        return 'Tệp cục bộ';
      case YoloModelSourceType.remoteUrl:
        return 'URL từ xa';
    }
  }
}
