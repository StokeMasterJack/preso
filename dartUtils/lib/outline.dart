import 'dart:core';

import 'package:dartUtils/node_renderer.dart';
import 'package:meta/meta.dart';
import 'package:quiver/core.dart';

class OutlineMessage {
  final Key key;
  final String opmlText;

  const OutlineMessage(this.key, this.opmlText);
}

class Key {
  final String id;
  final String name;

  const Key({@required this.id, @required this.name});

  static const Key flutter = Key(id: "687220", name: "flutter");

  static final List<Key> all = [flutter];
}

class Outline {
  final Node root;

  const Outline({@required this.root});

  Optional<Node> node(Tag tag) => root.node(tag);

  Optional<Node> get mainNode => root.mainNode;

  Optional<Node> get internalNode => root.internalNode;

  void prindent() {
    mainNode.value.prindent();
  }

  void initParent() {
    root._initParent(null);
  }
}

class Tag {
  final String name;

  const Tag._(this.name);

  static const String slideSuffix = "-slide";

  static const Tag none = Tag._("none");
  static const Tag main = Tag._("main");
  static const Tag internal = Tag._("internal");

  static const Tag ulSlide = Tag._("ul-slide");
  static const Tag olSlide = Tag._("ol-slide");
  static const Tag plSlide = Tag._("pl-slide");

  static const Tag olElement = Tag._("ol");
  static const Tag ulElement = Tag._("ul");
  static const Tag plElement = Tag._("pl"); //plain list - no bullets

  static const Tag section = Tag._("section");
  static const Tag note = Tag._("note");

  static final List<Tag> all = [main, internal, section, olSlide, ulSlide, note, none];
  static final List<Tag> slideTags = all.where((t) => t.isSlide);

  bool get isList => isUl || isOl || isPl;

  bool get isUl => name.startsWith("ul");

  bool get isOl => name.startsWith("ol");

  bool get isPl => name.startsWith("pl");

  Optional<ListType> get listType {
    if (isUl) return Optional.of(ListType.ul);
    if (isOl) return Optional.of(ListType.ol);
    if (isPl) return Optional.of(ListType.pl);
    return Optional.absent();
  }

  static Tag parse(String tagName) {
    String tn = tagName.trim().toLowerCase();
    for (Tag tag in all) {
      if (tag.name == tn) return tag;
    }
    throw StateError("Bad tagName[$tagName]");
  }

  @override
  bool operator ==(Object other) => identical(this, other);

  @override
  int get hashCode => name.hashCode;

  static String ser(Set<Tag> tags) {
    if (tags.isEmpty) return "";
    final String sep = ": ";
    return tags.length == 1 ? "${sep}${tags.single.name}" : "${sep}${tags.map((t) => t.name).join("|")}";
  }

  bool get isSlide => name.endsWith(slideSuffix);
}

class Name {
  final String name;

  const Name._(this.name);

  static const Name opml = Name._("opml");
  static const Name head = Name._("head");
  static const Name body = Name._("body");
  static const Name title = Name._("title");
  static const Name outline = Name._("outline");

  static final List<Name> all = [opml, head, body, title, outline];

  static Name parse(String name) {
    String tn = name.trim().toLowerCase();
    for (Name n in all) {
      if (n.name == tn) return n;
    }
    throw StateError("Bad tagName[$name]");
  }

  @override
  bool operator ==(Object other) => identical(this, other);

  @override
  int get hashCode => name.hashCode;
}

class Att {
  final String name;

  const Att._(this.name);

  static const Att text = Att._("text");
  static const Att type = Att._("type");
  static const Att tags = Att._("tags");

  static final List<Att> all = [text, type, tags];

  static Att parse(String name) {
    String tn = name.trim().toLowerCase();
    for (Att n in all) {
      if (n.name == tn) return n;
    }
    throw StateError("Bad attName[$name]");
  }

  @override
  bool operator ==(Object other) => identical(this, other);

  @override
  int get hashCode => name.hashCode;
}

class Node {
  final String text;
  final List<Node> children;
  final Tag tag;

  Node _parent;

  Node({@required this.text, @required this.children, @required Iterable<Tag> tags})
      : assert(tags.length <= 1),
        this.tag = tagFromTags(tags);

  bool get isNote => hasTag(Tag.note);

  bool get isSection => hasTag(Tag.section);

  bool get isMain => hasTag(Tag.main);

  bool get isInternal => hasTag(Tag.internal);

  bool get isLeaf => children.length == 0;

  bool hasTag(Tag t) => tag == t;

  bool get isSlide => tag != null && tag.isSlide;

  static Tag tagFromTags(Iterable<Tag> tags) {
    return tags.isEmpty ? Tag.none : tags.first;
  }

  void prindent([String prefix = ""]) {
    String t = tag == null ? "" : ": ${tag.name}";
    print("${prefix} ${text}${t} ${slideRelativeDepth}");
    prindentInner(prefix);
  }

  void prindentInner([String prefix = ""]) {
    for (Node child in children) {
      if (child.isNote) continue;
      child.prindent(prefix + "  ");
    }
  }

  Optional<Node> node(Tag tag) {
    for (Node child in children) {
      if (child.hasTag(tag)) return Optional.of(child);
    }
    return Optional.absent();
  }

  Optional<Node> get mainNode => node(Tag.main);

  Optional<Node> get internalNode => node(Tag.internal);

  bool get isUlSlide => hasTag(Tag.ulSlide);

  bool get isOlSlide => hasTag(Tag.olSlide);

  bool get isPlSlide => hasTag(Tag.plSlide);

  //isElement defined as slide content element slideRelativeDepth > 0
  bool get isElement => slideRelativeDepth > 0;

  bool get isListElement => isElement && tag.isList;

  bool get isListSlide => isSlide && tag.isList;

  bool get isList => isListElement || isListSlide;

  bool get parentIsSlide => _parent != null && _parent.isSlide;

  /**
   * -1: not a slice of slide-descendant
   *  0: slide
   *  1: slide-list-item level 1
   *  2: slide-list-item level 2
   */
  int get slideRelativeDepth {
    if (isSlide) return 0;
    if (isRoot) return -1;

    if (parentIsSlide) return 1;
    if (_parent.slideRelativeDepth == -1) {
      return -1;
    } else {
      return _parent.slideRelativeDepth + 1;
    }
  }

  int get depth => isRoot ? 0 : _parent.depth + 1;

  void _initParent(Node p) {
    _parent = p;
    for (Node child in children) {
      child._initParent(this);
    }
  }

  bool get isRoot => _parent == null;

  Optional<ListType> get listType => tag.listType;
}

enum Level {
  group, //higher than slide
  slide, //slide
  element //lower than slide
}
