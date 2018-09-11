#!/usr/bin/env dart --preview-dart-2 --strong  --enable-asserts
import 'dart:io';

import 'package:dartUtils/node_renderer.dart';
import 'package:dartUtils/outline.dart';
import 'package:dartUtils/outline_loader.dart';
import 'package:dartUtils/util.dart';
import 'package:path/path.dart' as p;

main(List<String> arguments) async {
  Outline outline = await OutlineLoader.load(Key.flutter);
//  outline.prindent();

  StringBuffer s = StringBuffer();
  NodeRenderer r = NodeRenderer(s);
  r.render(outline.mainNode.value);

  print(s.toString());

  _writeText(s.toString());
}

String _outFile1() {
  String dir = projectDir();
  return p.join(dir, "PITCHME.md");
}

void _writeText(String content) async {
  String outFile = _outFile1();
  var file = File(outFile);
  await file.create(recursive: true);
  final IOSink sink = file.openWrite(mode: FileMode.writeOnly);
  await sink.write(content);
  await sink.flush();
  await sink.close();
}
