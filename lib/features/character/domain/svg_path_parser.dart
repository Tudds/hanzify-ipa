import 'dart:ui' as ui;

class SvgPathParser {
  const SvgPathParser();

  static final RegExp _commandSeparator = RegExp(r'([MLQCZmlqczHhVv])');
  static final RegExp _tokenSplit = RegExp(r'[\s,]+');

  ui.Path parse(String d) {
    final spaced = d.replaceAllMapped(
      _commandSeparator,
      (m) => ' ${m.group(0)} ',
    );
    final tokens = spaced
        .split(_tokenSplit)
        .where((s) => s.isNotEmpty)
        .toList();

    final path = ui.Path();
    var i = 0;
    String? cmd;
    var x = 0.0;
    var y = 0.0;
    var startX = 0.0;
    var startY = 0.0;

    while (i < tokens.length) {
      final t = tokens[i];
      if (t.length == 1 && _isCommand(t)) {
        cmd = t;
        i++;
        if (cmd == 'Z' || cmd == 'z') {
          path.close();
          x = startX;
          y = startY;
          cmd = null;
        }
        continue;
      }
      switch (cmd) {
        case 'M':
          x = double.parse(tokens[i++]);
          y = double.parse(tokens[i++]);
          path.moveTo(x, y);
          startX = x;
          startY = y;
          cmd = 'L';
        case 'm':
          x += double.parse(tokens[i++]);
          y += double.parse(tokens[i++]);
          path.moveTo(x, y);
          startX = x;
          startY = y;
          cmd = 'l';
        case 'L':
          x = double.parse(tokens[i++]);
          y = double.parse(tokens[i++]);
          path.lineTo(x, y);
        case 'l':
          x += double.parse(tokens[i++]);
          y += double.parse(tokens[i++]);
          path.lineTo(x, y);
        case 'H':
          x = double.parse(tokens[i++]);
          path.lineTo(x, y);
        case 'h':
          x += double.parse(tokens[i++]);
          path.lineTo(x, y);
        case 'V':
          y = double.parse(tokens[i++]);
          path.lineTo(x, y);
        case 'v':
          y += double.parse(tokens[i++]);
          path.lineTo(x, y);
        case 'Q':
          final x1 = double.parse(tokens[i++]);
          final y1 = double.parse(tokens[i++]);
          x = double.parse(tokens[i++]);
          y = double.parse(tokens[i++]);
          path.quadraticBezierTo(x1, y1, x, y);
        case 'q':
          final x1 = x + double.parse(tokens[i++]);
          final y1 = y + double.parse(tokens[i++]);
          x += double.parse(tokens[i++]);
          y += double.parse(tokens[i++]);
          path.quadraticBezierTo(x1, y1, x, y);
        case 'C':
          final x1 = double.parse(tokens[i++]);
          final y1 = double.parse(tokens[i++]);
          final x2 = double.parse(tokens[i++]);
          final y2 = double.parse(tokens[i++]);
          x = double.parse(tokens[i++]);
          y = double.parse(tokens[i++]);
          path.cubicTo(x1, y1, x2, y2, x, y);
        case 'c':
          final x1 = x + double.parse(tokens[i++]);
          final y1 = y + double.parse(tokens[i++]);
          final x2 = x + double.parse(tokens[i++]);
          final y2 = y + double.parse(tokens[i++]);
          x += double.parse(tokens[i++]);
          y += double.parse(tokens[i++]);
          path.cubicTo(x1, y1, x2, y2, x, y);
        default:
          i++;
      }
    }
    return path;
  }

  bool _isCommand(String s) {
    const commands = {
      'M', 'm', 'L', 'l', 'H', 'h', 'V', 'v', 'Q', 'q', 'C', 'c', 'Z', 'z',
    };
    return commands.contains(s);
  }
}
