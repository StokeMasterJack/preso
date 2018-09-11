import 'dart:io';

import 'package:path/path.dart' as p;

typedef dynamic VoidCallback(dynamic);

typedef dynamic MyFunction();

class TT {
  final String prefix;
  final int t1;
  final int t2;

  int get delta => t2 - t1;

  TT({int t1 = 0, int t2, String prefix})
      : this.t1 = t1,
        this.t2 = t2 == null ? cur() : t2,
        this.prefix = prefix;

  static TT t() => TT(t1: 0, t2: cur());

  static int cur() => DateTime.now().millisecondsSinceEpoch;

  TT end([String prefix = null]) => TT(t1: this.t2, t2: cur(), prefix: prefix);

  TT endPr([String prefix = null]) {
    TT dd = end(prefix);
    print(dd.toString());
    return dd;
  }

  @override
  String toString() {
    String p = prefix != null ? "${prefix}: " : "";
    return '${p}${delta}';
  }
}

TT profile(dynamic voidFunction) {
  TT t1 = TT.t();
  voidFunction();
  TT delta = t1.end();
  return delta;
}

String scriptDir() => p.dirname(Platform.script.toFilePath());

String dartUtilsDir() => p.dirname(scriptDir());

String projectDir() => p.dirname(dartUtilsDir());

void indent(int depth, StringBuffer s) {
  for (int i = 0; i < depth; i++) {
    s.write(' ');
  }
}
