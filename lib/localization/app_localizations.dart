import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  Map<String, String> _localizedStrings = {}; // Khởi tạo với một Map rỗng

  AppLocalizations(this.locale) {
    load(); // Gọi load() trong constructor
  }

  static AppLocalizations of(BuildContext context) {
    final localizations = Localizations.of<AppLocalizations>(context, AppLocalizations);
    if (localizations != null && localizations._localizedStrings.isNotEmpty) {
      return localizations;
    }
    // Nếu không tìm thấy bản địa hóa hoặc bản dịch chưa được tải, trả về bản địa hóa mặc định
    return AppLocalizations(const Locale('en'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  Future<bool> load() async {
    try {
      // Thay đổi đường dẫn nếu cần
      String jsonString = await rootBundle.loadString('assets/lang/${locale.languageCode}.json');
      Map<String, dynamic> jsonMap = json.decode(jsonString);

      _localizedStrings = jsonMap.map((key, value) {
        return MapEntry(key, value.toString());
      });

      return true;
    } catch (e) {
      if (kDebugMode) {
        print("Lỗi khi tải tệp bản địa hóa: $e");
      }
      // Tải tệp ngôn ngữ mặc định nếu không tìm thấy tệp cho ngôn ngữ hiện tại
      try {
        String defaultJsonString = await rootBundle.loadString('assets/lang/en.json');
        Map<String, dynamic> defaultJsonMap = json.decode(defaultJsonString);
        _localizedStrings = defaultJsonMap.map((key, value) {
          return MapEntry(key, value.toString());
        });
        return true;
      } catch (e) {
        if (kDebugMode) {
          print("Lỗi khi tải tệp bản địa hóa mặc định: $e");
        }
        return false;
      }
    }
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    // Kiểm tra nếu ngôn ngữ được hỗ trợ
    return ['en', 'vi'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}
