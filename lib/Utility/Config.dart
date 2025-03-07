import 'dart:convert';
import 'dart:io' as io;

import 'package:path/path.dart';

import '../path.dart';
import 'i18n.dart';

class Config {
  static io.Directory _ConfigFolder = configHome;
  static io.File _ConfigFile =
      io.File(join(_ConfigFolder.absolute.path, "config.json"));
  static Map _config = json.decode(_ConfigFile.readAsStringSync());

  static final DefaultConfigObject = {
    "java_path_8": "",
    "java_path_16": "",
    "auto_java": true,
    "java_max_ram": 4096,
    "java_jvm_args": [], //Jvm 參數
    "lang_code": i18n.GetLanguageCode(), //系統預設語言
    "check_assets": true,
    "game_width": 854,
    "game_height": 480,
    "max_log_length": 500,
    "show_log": false,
    "auto_dependencies": true,
    "theme_id": 0,
  };

  static void Change(key, value) {
    _config[key] = value;
    Save();
  }

  static Map Get() {
    return _config;
  }

  static dynamic GetValue(key) {
    if (!_config.containsKey(key)) {
      _config[key] = DefaultConfigObject[key];
      Save();
    }
    return _config[key];
  }

  static void Save() {
    _ConfigFile.writeAsStringSync(json.encode(_config));
  }
}
