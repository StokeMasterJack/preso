import 'package:dartUtils/outline.dart';
import 'package:dartUtils/util.dart';

class NodeRenderer {
  final StringBuffer s;

  NodeRenderer(this.s);

  void render(Node n) {
    int slideRelativeDepth = n.slideRelativeDepth;
    if (slideRelativeDepth == 0) {
      slide(n);
    } else if (slideRelativeDepth > 0) {
      element(n, slideRelativeDepth);
    } else if (slideRelativeDepth < 0) {
      group(n, slideRelativeDepth);
    } else {
      throw StateError("Bad depth [${slideRelativeDepth}]");
    }
  }

  void slide(Node n) {
    assert(n.isSlide);
    slideTitle(n);
    if (n.isList) {
      list(n);
    } else {}
    s.writeln("---");
  }

  void element(Node n, int slideRelativeDepth) {
    assert(n.isElement);
    if (n.isList) {
      list(n);
    } else {}
  }

  void list(Node n) {
    ListType type = n.listType.value;
    type.renderHeader(s);
    int d = n.slideRelativeDepth;
    for (Node li in n.children) {
      type.renderListItem(d, li, s);
    }
    type.renderFooter(s);
  }

  void slideTitle(Node n) {
    s.writeln("### ${n.text}");
  }

  void childNodes(Node n) {
    for (Node child in n.children) {
      render(child);
    }
  }

  void group(Node n, int slideRelativeDepth) {
    n.children.forEach((child) {
      render(child);
    });
  }
}

class ListType {
  final String name;

  ListType._(this.name) : assert(name != null);

  static final ListType ul = ListType._("ul");
  static final ListType ol = ListType._("ol");
  static final ListType pl = ListType._("pl");

  void renderHeader(StringBuffer s) {
    s.writeln("@${name}");
  }

  void renderFooter(StringBuffer s) {
    s.writeln("@${name}end");
  }

  void renderListItem(int slideRelativeDepth, Node li, StringBuffer s) {
    int indentSize = (slideRelativeDepth - 1) * 4;
    indent(indentSize, s);

    if (this == ul) {
      s.write("- ");
    } else if (this == ol) {
      s.write("- ");
    } else if (this == pl) {
      s.write("");
    } else {
      throw StateError("Bad ListType: $this");
    }

    s.writeln(li.text);
  }
}
