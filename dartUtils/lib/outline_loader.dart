import 'dart:async';
import 'dart:core';
import 'dart:io';

import 'package:dartUtils/outline.dart';
import 'package:dartUtils/outline_parser.dart';
import 'package:dartUtils/util.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

class OutlineLoader {
  final Key key;

  const OutlineLoader({@required this.key});

  String _opmlUrl(Key key, {bool includeNotes = true}) {
    return "https://checkvist.com/checklists/${key.id}/export.opml?${includeNotes ? '&export_notes=true' : ''}";
  }

  //ignore: unused_element
  String _tasksUrl({bool includeNotes = true}) {
    return "https://checkvist.com/checklists/${key.id}/tasks.xml?${includeNotes ? '&with_notes=true' : ''}";
  }

  Future<String> _fetchOpml() {
    var url = _opmlUrl(key);
    return http.read(url);
  }



  String _opmlFile() => p.join(projectDir(), "opml", "${key.name}.opml.xml");

  void _writeOpmlText(String content) async {
    String outFile = _opmlFile();
    var opmlFile = File(outFile);
    await opmlFile.create(recursive: true);
    final IOSink sink = opmlFile.openWrite(mode: FileMode.writeOnly);
    await sink.write(content);
    await sink.flush();
    await sink.close();
  }

  void refreshOpmlFromCheckvist() async {
    String content = await _fetchOpml();
    _writeOpmlText(content);
  }

  Future<String> loadOpmlText() async {
    String outFile = _opmlFile();
    File opmlFile = File(outFile);
    return opmlFile.readAsString();
  }

  Future<Outline> loadOpml({bool parseAsync: false}) async {
    final String opmlText = await loadOpmlText();
    if (parseAsync) {
      return OutlineParser.parseOpmlAsync(opmlText);
    } else {
      return OutlineParser.parseOpml(opmlText);
    }
  }

  static Future<Outline> loadOutline(Key key, {bool parseAsync: false}) async {
    OutlineLoader loader = OutlineLoader(key: key);
    return loader.loadOpml(parseAsync: parseAsync);
  }

  static Future<Outline> load(Key key) async {
    return OutlineLoader.loadOutline(key);
  }

  static void refreshFromCheckvist(Key key) {
    OutlineLoader loader = OutlineLoader(key: key);
    loader.refreshOpmlFromCheckvist();
  }
}
