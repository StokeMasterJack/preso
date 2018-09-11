import 'dart:async';
import 'dart:core';
import 'dart:isolate';

import 'package:dartUtils/outline.dart';
import 'package:quiver/core.dart';
import 'package:xml/xml.dart';

class OutlineParser {
  static final Set<Tag> emptyTagSet = Set.identity();
  static const Pattern sp = " ";

  static Outline parseOpml(String opmlText) {
    return _createOutline(opmlText);
  }

  static Outline _createOutline(String opmlText) {
    Node rootNode = _createNode(opmlText);
    Outline o = Outline(root: rootNode);
    o.initParent();
    return o;
  }

  static Node _createNode(String opmlText) {
    final XmlElement opmlEl = _createXmlElement(opmlText);
    return _parseOpmlElement(opmlEl);
  }

  static XmlElement _createXmlElement(String opmlText) {
    final XmlDocument opmlDoc = parse(opmlText);
    return opmlDoc.rootElement;
  }

  static Node _parseOpmlElement(XmlElement opmlElement) {
    final XmlElement headEl = _elementByName(opmlElement, Name.head).value;
    final XmlElement bodyEl = _elementByName(opmlElement, Name.body).value;

    final String title = _elementText(headEl, Name.title).value;

    Iterable<XmlElement> bodyChildElements = _outlineElements(bodyEl);
    List<Node> bodyChildNodes = _parseOutlineElements(bodyChildElements);
    Set<Tag> bodyTags = _parseTags(bodyEl);

    return Node(text: title, children: bodyChildNodes, tags: bodyTags);
  }

  static List<Node> _parseOutlineElements(Iterable<XmlElement> outlineElements) {
    final nodes = <Node>[];
    for (XmlElement outlineElement in outlineElements) {
      Node node = _parseOutlineElement(outlineElement);
      nodes.add(node);
    }
    return nodes;
  }

  static Node _parseOutlineElement(XmlElement el) {
    final String localName = el.name.local;
    assert(localName == Name.outline.name, "localName[${localName}]");

    final String text = _getAttText(el).value;
    final Set<Tag> tags = _parseTags(el);

    final Iterable<XmlElement> childElements = _outlineElements(el);
    final List<Node> children = _parseOutlineElements(childElements);

    return Node(text: text, children: children, tags: tags);
  }

  static Iterable<XmlElement> _elementsByName(XmlElement el, Name elName) {
    return el.findElements(elName.name);
  }

  static Iterable<XmlElement> _outlineElements(XmlElement el) => _elementsByName(el, Name.outline);

  static Optional<XmlElement> _elementByName(XmlElement el, Name elName) {
    final Iterable<XmlElement> elements = el.findElements(elName.name);
    if (elements.isEmpty) return Optional.absent();
    XmlElement first = elements.first;
    assert(first.name.local == elName.name);
    return Optional.of(first);
  }

  //ignore: unused_element
  static Optional<XmlElement> _elementByTag(XmlElement el, Tag tag) {
    final Iterable<XmlElement> elements = _outlineElements(el);
    if (elements.isEmpty) return Optional.absent();
    for (XmlElement child in elements) {
      assert(child.name.local == Name.outline.name);
      if (_nodeHasTag(child, tag)) {
        return Optional.of(child);
      }
    }
    return Optional.absent();
  }

  static Optional<String> _elementText(XmlElement el, Name name) => _elementByName(el, name).transform((el) => el.text);

  static Optional<String> _getAtt(XmlElement element, Att att) {
    final String value = element.getAttribute(att.name);
    if (value == null) return Optional.absent();
    return Optional.of(value);
  }

  static Optional<String> _getAttType(XmlElement el) {
    return _getAtt(el, Att.type);
  }

  static Optional<String> _getAttTags(XmlElement el) {
    return _getAtt(el, Att.tags);
  }

  static Optional<String> _getAttText(XmlElement el) {
    return _getAtt(el, Att.text);
  }

  static bool _nodeHasTag(XmlElement el, Tag tag) {
    Set<Tag> tags = _parseTags(el);
    return tags.contains(tag);
  }

  static Set<Tag> _parseTags(XmlElement el) {
    final Optional<String> t = _getAttTags(el);
    if (t.isEmpty) return emptyTagSet;

    final String tt = t.value.trim();

    final bool containsSpace = tt.contains(sp);
    Set<Tag> set = new Set();
    if (!containsSpace) {
      set = new Set();
      set.add(Tag.parse(tt));
    } else {
      set = tt.split(sp).map((n) => Tag.parse(n));
    }

    final Optional<String> type = _getAttType(el);
    if (type.isPresent) {
      set.add(Tag.parse(type.value));
    }

    return set;
  }

  static Future<Outline> parseOpmlAsync(String opmlText) async {
    ReceivePort receivePort = new ReceivePort();
    _MsgIn msg = _MsgIn(receivePort.sendPort, opmlText);
    Isolate.spawn<_MsgIn>(_parseIsolate, msg);
    return await receivePort.first;
  }

  static void _parseIsolate(_MsgIn msg) async {
    String opmlText = msg.opmlText;
    SendPort sendPort = msg.sendPort;
    Outline outline = OutlineParser.parseOpml(opmlText);
    sendPort.send(outline);
  }
}

class _MsgIn {
  final SendPort sendPort;
  final String opmlText;

  _MsgIn(this.sendPort, this.opmlText);
}
