import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart' show basename;
import 'package:recase/recase.dart';
import 'package:source_gen/source_gen.dart';
import 'package:rosetta/rosetta.dart';

part 'rosetta_consts.dart';

part 'rosetta_helper.dart';

part 'rosetta_utils.dart';

part 'rosetta_keys.dart';

part 'rosetta_delegate.dart';

class RosettaStoneGenerator extends GeneratorForAnnotation<Stone> {
  const RosettaStoneGenerator();

  @override
  Future<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) async {
    String path = element.metadata.first
        .computeConstantValue()
        .getField("path")
        .toStringValue();

    var className = element.name;
    var languages = await getLanguages(path);
    var keyMap = await getKeyMap(path);
    var interceptors = getInterceptors(element as ClassElement);

    final file = Library(
      (lb) => lb
        ..body.addAll([
          generateDelegate(className, languages),
          generateKeysClass(keyMap.keys.toList()),
          generateHelper(className, path, keyMap, interceptors),
        ]),
    );

    final DartEmitter emitter = DartEmitter(Allocator());
    return DartFormatter().format('${file.accept(emitter)}');
  }
}
