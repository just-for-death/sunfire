import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:html/dom.dart';
import 'package:pseudom/pseudom.dart' as pseudom;
import 'package:xpath_selector_html_parser/xpath_selector_html_parser.dart';

String regHrefMatcher(String input) {
  final exp = RegExp(r'''href\s*=\s*["']([^"']+)["']''', caseSensitive: false);
  final matches = exp.allMatches(input);
  if (matches.isEmpty) return '';
  return matches.first.group(1)?.trim() ?? '';
}

String regDataSrcMatcher(String input) {
  final exp = RegExp(r'''(?:data-src|data-url|data-lazy-src|data-original)\s*=\s*["']([^"']+)["']''', caseSensitive: false);
  final matches = exp.allMatches(input);
  if (matches.isEmpty) return '';
  return matches.first.group(1)?.trim() ?? '';
}

String regSrcMatcher(String input) {
  final exp = RegExp(r'''src\s*=\s*["']([^"']+)["']''', caseSensitive: false);
  final matches = exp.allMatches(input);
  if (matches.isEmpty) return '';
  return matches.first.group(1)?.trim() ?? '';
}

String regImgMatcher(String input) {
  final exp = RegExp(r'''(?:img|image)\s*=\s*["']([^"']+)["']''', caseSensitive: false);
  final matches = exp.allMatches(input);
  if (matches.isEmpty) return '';
  return matches.first.group(1)?.trim() ?? '';
}

void _initPseudoSelector() {
  (int, int) parseNth(String arg) {
    arg = arg.toLowerCase().replaceAll(' ', '');
    if (arg == 'odd') return (2, 1);
    if (arg == 'even') return (2, 0);
    final reg = RegExp(r'^(\d*)n([+-]?\d+)?$');
    final match = reg.firstMatch(arg);
    if (match != null) {
      final aStr = match.group(1);
      final a = aStr == null || aStr.isEmpty ? 1 : int.parse(aStr);
      final bStr = match.group(2);
      final b = bStr == null ? 0 : int.parse(bStr);
      return (a, b);
    }
    final n = int.tryParse(arg);
    if (n != null) return (0, n);
    return (0, 0);
  }

  bool matchesNth(int index, int a, int b) {
    if (a == 0) return index == b;
    final diff = index - b;
    return diff % a == 0 && diff ~/ a >= 0;
  }

  String getWholeText(Element element) {
    return element.nodes.map((node) {
      if (node is Text) return node.text;
      if (node is Element) return getWholeText(node);
      return '';
    }).join();
  }

  String getWholeOwnText(Element element) {
    return element.nodes.whereType<Text>().map((t) => t.text).join();
  }

  bool nthChild(Element element, String? args) {
    if (args == null) return false;
    final parent = element.parent;
    if (parent == null) return false;
    final siblings = parent.children;
    final index = siblings.indexOf(element) + 1;
    final (a, b) = parseNth(args);
    return matchesNth(index, a, b);
  }

  bool nthLastChild(Element element, String? args) {
    if (args == null) return false;
    final parent = element.parent;
    if (parent == null) return false;
    final siblings = parent.children;
    final index = siblings.length - siblings.indexOf(element);
    final (a, b) = parseNth(args);
    return matchesNth(index, a, b);
  }

  bool nthOfType(Element element, String? args) {
    if (args == null) return false;
    final parent = element.parent;
    if (parent == null) return false;
    final siblings = parent.children.where((e) => e.localName == element.localName).toList();
    final index = siblings.indexOf(element) + 1;
    final (a, b) = parseNth(args);
    return matchesNth(index, a, b);
  }

  bool nthLastOfType(Element element, String? args) {
    if (args == null) return false;
    final parent = element.parent;
    if (parent == null) return false;
    final siblings = parent.children.where((e) => e.localName == element.localName).toList();
    final index = siblings.length - siblings.indexOf(element);
    final (a, b) = parseNth(args);
    return matchesNth(index, a, b);
  }

  bool has(Element element, String? args) {
    if (args == null || args.trim().isEmpty) return false;
    return pseudom.parse(_fixSelector(args)).selectFirst(element) != null;
  }

  bool inot(Element element, String? args) {
    if (args == null || args.trim().isEmpty) return false;
    final parent = element.parent ?? element;
    final matches = pseudom.parse(_fixSelector(args)).select(parent);
    return !matches.contains(element);
  }

  bool contains(Element element, String? args) {
    final text = args ?? '';
    return element.text.toLowerCase().contains(text.toLowerCase());
  }

  bool containsOwn(Element element, String? args) {
    final text = args ?? '';
    final ownText = element.nodes.whereType<Text>().map((t) => t.text).join();
    return ownText.toLowerCase().contains(text.toLowerCase());
  }

  bool matches(Element element, String? args) {
    if (args == null) return false;
    try {
      final reg = RegExp(args, caseSensitive: false);
      return reg.hasMatch(element.text);
    } catch (_) {
      return false;
    }
  }

  bool containsData(Element element, String? args) {
    final data = args ?? '';
    if (element.localName == 'script' || element.localName == 'style') {
      return element.text.toLowerCase().contains(data.toLowerCase());
    }
    return false;
  }

  bool containsWholeText(Element element, String? args) {
    final text = args ?? '';
    return getWholeText(element).contains(text);
  }

  bool containsWholeOwnText(Element element, String? args) {
    final text = args ?? '';
    return getWholeOwnText(element).contains(text);
  }

  bool matchesWholeText(Element element, String? args) {
    if (args == null) return false;
    try {
      final reg = RegExp(args);
      return reg.hasMatch(getWholeText(element));
    } catch (_) {
      return false;
    }
  }

  bool matchesWholeOwnText(Element element, String? args) {
    if (args == null) return false;
    try {
      final reg = RegExp(args);
      return reg.hasMatch(getWholeOwnText(element));
    } catch (_) {
      return false;
    }
  }

  bool isSelector(Element element, String? args) {
    if (args == null) return false;
    final selectors = splitTopLevelSelectors(args);
    for (final sel in selectors) {
      try {
        final parsed = pseudom.parse(sel);
        if (parsed.selectFirst(element) != null) return true;
      } catch (ignoredError) { if (kDebugMode) debugPrint('[dom_extensions] ignored error: $ignoredError'); }
    }
    return false;
  }

  bool firstChild(Element element, String? args) => element.previousElementSibling == null;
  bool lastChild(Element element, String? args) => element.nextElementSibling == null;

  bool firstOfType(Element element, String? args) {
    final parent = element.parent;
    if (parent == null) return false;
    final siblings = parent.children.where((e) => e.localName == element.localName);
    return siblings.first == element;
  }

  bool lastOfType(Element element, String? args) {
    final parent = element.parent;
    if (parent == null) return false;
    final siblings = parent.children.where((e) => e.localName == element.localName);
    return siblings.last == element;
  }

  bool onlyChild(Element element, String? args) =>
      element.previousElementSibling == null && element.nextElementSibling == null;

  bool onlyOfType(Element element, String? args) {
    final parent = element.parent;
    if (parent == null) return false;
    final siblings = parent.children.where((e) => e.localName == element.localName);
    return siblings.length == 1;
  }

  bool empty(Element element, String? args) =>
      element.children.isEmpty && element.text.trim().isEmpty;

  bool root(Element element, String? args) => element.parent == null;

  bool lt(Element element, String? args) {
    if (args == null) return false;
    final n = int.tryParse(args);
    if (n == null) return false;
    final parent = element.parent;
    if (parent == null) return false;
    return parent.children.indexOf(element) < n;
  }

  bool gt(Element element, String? args) {
    if (args == null) return false;
    final n = int.tryParse(args);
    if (n == null) return false;
    final parent = element.parent;
    if (parent == null) return false;
    return parent.children.indexOf(element) > n;
  }

  bool eq(Element element, String? args) {
    if (args == null) return false;
    final n = int.tryParse(args);
    if (n == null) return false;
    final parent = element.parent;
    if (parent == null) return false;
    return parent.children.indexOf(element) == n;
  }

  pseudom.PseudoSelector.handlers['nth-child'] = nthChild;
  pseudom.PseudoSelector.handlers['nth-last-child'] = nthLastChild;
  pseudom.PseudoSelector.handlers['nth-of-type'] = nthOfType;
  pseudom.PseudoSelector.handlers['nth-last-of-type'] = nthLastOfType;
  pseudom.PseudoSelector.handlers['has'] = has;
  pseudom.PseudoSelector.handlers['inot'] = inot;
  pseudom.PseudoSelector.handlers['contains'] = contains;
  pseudom.PseudoSelector.handlers['containsOwn'] = containsOwn;
  pseudom.PseudoSelector.handlers['containsData'] = containsData;
  pseudom.PseudoSelector.handlers['containsWholeText'] = containsWholeText;
  pseudom.PseudoSelector.handlers['containsWholeOwnText'] = containsWholeOwnText;
  pseudom.PseudoSelector.handlers['matches'] = matches;
  pseudom.PseudoSelector.handlers['matchesWholeText'] = matchesWholeText;
  pseudom.PseudoSelector.handlers['matchesWholeOwnText'] = matchesWholeOwnText;
  pseudom.PseudoSelector.handlers['is'] = isSelector;
  pseudom.PseudoSelector.handlers['last-child'] = lastChild;
  pseudom.PseudoSelector.handlers['first-child'] = firstChild;
  pseudom.PseudoSelector.handlers['first-of-type'] = firstOfType;
  pseudom.PseudoSelector.handlers['last-of-type'] = lastOfType;
  pseudom.PseudoSelector.handlers['only-child'] = onlyChild;
  pseudom.PseudoSelector.handlers['only-of-type'] = onlyOfType;
  pseudom.PseudoSelector.handlers['empty'] = empty;
  pseudom.PseudoSelector.handlers['root'] = root;
  pseudom.PseudoSelector.handlers['lt'] = lt;
  pseudom.PseudoSelector.handlers['gt'] = gt;
  pseudom.PseudoSelector.handlers['eq'] = eq;
}

String _fixSelector(String selector) {
  return selector.replaceAll(':not', ':inot');
}

/// Splits a selector list on top-level commas only. Commas inside parentheses
/// (`:is(a, b)`, `:has(a, b)`, `:nth-child(2n + 1)`), square brackets
/// (`[data-x="a,b"]`) or quotes are kept intact, so real selectors are not
/// torn apart. Returns trimmed, non-empty parts.
List<String> splitTopLevelSelectors(String selector) {
  final parts = <String>[];
  final buf = StringBuffer();
  var paren = 0;
  var bracket = 0;
  String? quote;
  for (var i = 0; i < selector.length; i++) {
    final ch = selector[i];
    if (quote != null) {
      buf.write(ch);
      if (ch == '\\' && i + 1 < selector.length) {
        buf.write(selector[++i]);
      } else if (ch == quote) {
        quote = null;
      }
      continue;
    }
    if (ch == '"' || ch == "'") {
      quote = ch;
      buf.write(ch);
    } else if (ch == '(') {
      paren++;
      buf.write(ch);
    } else if (ch == ')') {
      if (paren > 0) paren--;
      buf.write(ch);
    } else if (ch == '[') {
      bracket++;
      buf.write(ch);
    } else if (ch == ']') {
      if (bracket > 0) bracket--;
      buf.write(ch);
    } else if (ch == ',' && paren == 0 && bracket == 0) {
      final t = buf.toString().trim();
      if (t.isNotEmpty) parts.add(t);
      buf.clear();
    } else {
      buf.write(ch);
    }
  }
  final last = buf.toString().trim();
  if (last.isNotEmpty) parts.add(last);
  return parts;
}

/// Runs each selector part against [root] and returns the union in document
/// order (what a real comma-separated CSS selector returns), de-duplicated.
List<Element> _selectUnionInDocumentOrder(Element root, List<String> parts) {
  final found = <Element>{};
  for (final part in parts) {
    try {
      found.addAll(pseudom.parse(_fixSelector(part)).select(root));
    } catch (_) {
      // A part the engine cannot parse contributes nothing.
    }
  }
  if (found.length < 2) return found.toList();
  final ordered = <Element>[];
  final stack = <Element>[root];
  while (stack.isNotEmpty && ordered.length < found.length) {
    final el = stack.removeLast();
    if (found.contains(el)) ordered.add(el);
    for (var i = el.children.length - 1; i >= 0; i--) {
      stack.add(el.children[i]);
    }
  }
  return ordered;
}

extension DocumentExtension on Document? {
  List<Element>? select(String selector) {
    try {
      _initPseudoSelector();
      final dom = this?.documentElement;
      if (dom == null) return null;
      final parts = splitTopLevelSelectors(selector);
      if (parts.length > 1) {
        return _selectUnionInDocumentOrder(dom, parts);
      }
      return pseudom.parse(_fixSelector(selector)).select(dom).toList();
    } catch (_) {
      return null;
    }
  }

  Element? selectFirst(String selector) {
    try {
      _initPseudoSelector();
      final dom = this?.documentElement;
      if (dom == null) return null;
      final parts = splitTopLevelSelectors(selector);
      if (parts.length > 1) {
        final all = _selectUnionInDocumentOrder(dom, parts);
        return all.isEmpty ? null : all.first;
      }
      return pseudom.parse(_fixSelector(selector)).selectFirst(dom);
    } catch (_) {
      return null;
    }
  }

  bool hasAtr(String attribute) {
    return attr(attribute) != null;
  }

  String? xpathFirst(String xpath) {
    final dom = this?.documentElement;
    if (dom == null) return null;
    final htmlXPath = HtmlXPath.node(dom);
    final query = htmlXPath.query(xpath);
    return query.attr;
  }

  List<String> xpath(String xpath) {
    final dom = this?.documentElement;
    if (dom == null) return [];
    final htmlXPath = HtmlXPath.node(dom);
    final query = htmlXPath.query(xpath);
    if (query.nodes.isNotEmpty) {
      return query.attrs.whereType<String>().map((e) => e.trim()).toList();
    }
    return [];
  }

  String? attr(String attribute) {
    try {
      return this?.attributes[attribute];
    } catch (_) {
      return null;
    }
  }
}

extension ElementExtension on Element {
  List<Element>? select(String selector) {
    try {
      _initPseudoSelector();
      final parts = splitTopLevelSelectors(selector);
      if (parts.length > 1) {
        return _selectUnionInDocumentOrder(this, parts);
      }
      return pseudom.parse(_fixSelector(selector)).select(this).toList();
    } catch (_) {
      try {
        if (parent != null) {
          final target = parent!.nodes.firstWhere((e) => e == this) as Element;
          return pseudom.parse(_fixSelector(selector)).select(target).toList();
        }
      } catch (ignoredError) { if (kDebugMode) debugPrint('[dom_extensions] ignored error: $ignoredError'); }
      return null;
    }
  }

  Element? selectFirst(String selector) {
    try {
      _initPseudoSelector();
      final parts = splitTopLevelSelectors(selector);
      if (parts.length > 1) {
        final all = _selectUnionInDocumentOrder(this, parts);
        return all.isEmpty ? null : all.first;
      }
      return pseudom.parse(_fixSelector(selector)).selectFirst(this);
    } catch (_) {
      try {
        if (parent != null) {
          final target = parent!.nodes.firstWhere((e) => e == this) as Element;
          return pseudom.parse(_fixSelector(selector)).selectFirst(target);
        }
      } catch (ignoredError) { if (kDebugMode) debugPrint('[dom_extensions] ignored error: $ignoredError'); }
      return null;
    }
  }

  String? xpathFirst(String xpath) {
    final htmlXPath = HtmlXPath.node(this);
    final query = htmlXPath.query(xpath);
    return query.attr;
  }

  List<String> xpath(String xpath) {
    final htmlXPath = HtmlXPath.node(this);
    final query = htmlXPath.query(xpath);
    if (query.nodes.isNotEmpty) {
      return query.attrs.whereType<String>().map((e) => e.trim()).toList();
    }
    return [];
  }

  String? attr(String attribute) {
    try {
      if (attributes.containsKey(attribute)) return attributes[attribute];
      final keyLower = attribute.toLowerCase();
      for (final entry in attributes.entries) {
        if (entry.key.toString().toLowerCase() == keyLower) {
          return entry.value;
        }
      }
      final openTagEnd = outerHtml.indexOf('>');
      final openTag = openTagEnd != -1 ? outerHtml.substring(0, openTagEnd + 1) : outerHtml;
      final exp = RegExp('''(?:^|\\s)${RegExp.escape(attribute)}\\s*=\\s*["']([^"']+)["']''', caseSensitive: false);
      final m = exp.firstMatch(openTag);
      if (m != null) return m.group(1)?.trim();
      return null;
    } catch (_) {
      return null;
    }
  }

  bool hasAtr(String attribute) {
    return attr(attribute) != null;
  }

  String? get getSrc {
    try {
      final val = attr('src') ?? attr('data-src') ?? attr('data-url') ?? attr('data-lazy-src') ?? attr('data-original');
      if (val != null && val.isNotEmpty) return val;
      return regSrcMatcher(outerHtml);
    } catch (_) {
      return null;
    }
  }

  String? get getImg {
    try {
      final val = attr('img') ?? attr('image') ?? attr('src');
      if (val != null && val.isNotEmpty) return val;
      return regImgMatcher(outerHtml);
    } catch (_) {
      return null;
    }
  }

  String? get getHref {
    try {
      final val = attr('href') ?? attr('data-href');
      if (val != null && val.isNotEmpty) return val;
      return regHrefMatcher(outerHtml);
    } catch (_) {
      return null;
    }
  }

  String? get getDataSrc {
    try {
      final val = attr('data-src') ?? attr('data-url') ?? attr('data-lazy-src') ?? attr('data-original') ?? attr('src');
      if (val != null && val.isNotEmpty) return val;
      return regDataSrcMatcher(outerHtml);
    } catch (_) {
      return null;
    }
  }
}
