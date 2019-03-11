part of 'generator.dart';

Stone parseStone(ConstantReader annotation) => Stone(
      path: annotation.peek("path")?.stringValue,
      package: annotation.peek("package")?.stringValue,
    );

//TODO: getLanguage+getKayMap merge => Localization Class (language keys, key)

/// Find all referenced translation files for [Stone.path]
Future<List<String>> getLanguages(BuildStep step, String path) async =>
    await step
        .findAssets(Glob(path, recursive: true))
        .map(_assetIdToLocaleId)
        .toList();

/// All translations grouped by their keys
Future<List<Translation>> getKeyMap(BuildStep step, String path) async {
  var mapping = <String, List<String>>{};

  /// Find all referenced translation files for [Stone.path]
  var assets = await step.findAssets(Glob(path, recursive: true)).toList();

  /// Parse all translations
  for (var entity in assets) {
    Map<String, dynamic> jsonMap = json.decode(await step.readAsString(entity));
    Map<String, String> translationMap = jsonMap
        .map<String, String>((key, value) => MapEntry(key, value as String));

    /// Group translations by key
    translationMap.forEach(
      (key, value) => (mapping[key] ??= <String>[]).add(value),
    );
  }

  /// Convert the map to translation objects
  var translations = List<Translation>();
  mapping.forEach((id, trans) => translations.add(
        Translation(key: id, translations: trans),
      ));

  return translations;
}

Map<MethodElement, List<String>> sortKeysByInterceptors(
  List<Translation> translations,
  List<Interceptor> interceptors,
) {
  List<Translation> remainingTranslations = List.of(translations);

  return Map.fromIterable(
    interceptors,
    key: (interceptor) => interceptor.element,
    value: (interceptor) {
      var matchingKeys = <String>[];
      var filter = interceptor.filter;

      if (filter != null) {
        /// [Intercept] annotation with filter
        remainingTranslations.forEach((trans) {
          if (trans.translations.where(filter.hasMatch).toList().isNotEmpty) {
            matchingKeys.add(trans.key);
          }
        });

        matchingKeys.forEach(remainingTranslations.remove);
      } else {
        /// [Intercept] annotation without filter
        matchingKeys.addAll(keysOf(remainingTranslations));
        remainingTranslations.clear();
      }

      return matchingKeys;
    },
  )

    /// Add the remaining keys as
    ..[null] = keysOf(remainingTranslations);
}

List<Interceptor> getInterceptors(ClassElement classElement) =>
    classElement.methods
        .where((m) => _interceptorTypeChecker.hasAnnotationOfExact(m))
        .map((element) => Interceptor(element: element))
        .toList();

String _assetIdToLocaleId(AssetId assetId) =>
    assetId.uri.pathSegments.last.split(_keyDividerChar).first;

String _stoneAssetsPath(Stone stone) => stone.package != null
    ? "packages/${stone.package}/${stone.path}"
    : stone.path;

Reference _localizationDelegateOf(String className) => TypeReference(
      (trb) => trb
        ..symbol = "LocalizationsDelegate"
        ..types.add(_typeOf(className)),
    );

Reference _futureOf(String className) => TypeReference(
      (trb) => trb
        ..symbol = "Future"
        ..types.add(_typeOf(className)),
    );

Reference _typeOf(String className) => TypeReference(
      (trb) => trb..symbol = className,
    );

Reference _mapOf(Reference keyType, Reference valueType) => TypeReference(
      (trb) => trb
        ..symbol = "Map"
        ..types.addAll([keyType, valueType]),
    );

Reference get boolType => TypeReference(
      (trb) => trb..symbol = "bool",
    );

Reference get dynamicType => TypeReference(
      (trb) => trb..symbol = "dynamic",
    );

Reference get stringType => TypeReference(
      (trb) => trb..symbol = "String",
    );

Reference get localeType => TypeReference(
      (trb) => trb..symbol = "Locale",
    );
