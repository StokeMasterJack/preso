#!/usr/bin/env dart --preview-dart-2 --strong  --enable-asserts
import 'package:dartUtils/outline.dart';
import 'package:dartUtils/outline_loader.dart';

main(List<String> arguments) {
  OutlineLoader.refreshFromCheckvist(Key.flutter);
}
