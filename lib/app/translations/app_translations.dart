import 'package:get/get.dart';

/// Cấu trúc dịch thuật tối giản để giữ cho cấu trúc bootstrap sẵn sàng cho i18n trong tương lai.
class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => const {
    'vi_VN': {},
    'en_US': {},
  };
}
