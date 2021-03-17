import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
// import 'package:intl/intl.dart';
import 'package:rosetta/rosetta.dart';

import 'package:sprintf/sprintf.dart';

part 'translation.g.dart';

@Stone(path: 'i18n')
class Translation with _$TranslationHelper {
  static LocalizationsDelegate<Translation> delegate = _$TranslationDelegate();

  static Translation of(BuildContext context) {
    return Localizations.of(context, Translation);
  }
}
