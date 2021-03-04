import 'dart:io';

import 'package:puppeteer/puppeteer.dart';

/// Takes a screenshot of the given page and save as [name].png under screenshots.
Future screenshot(Page page, String name) async {
  await page.screenshot().then((data) {
    return File('./.screenshots/$name.png').create().then((file) {
      return file.writeAsBytes(data);
    });
  });
}

Future saveHtml(Page page, String name) {
  return page.content.then((contents) {
    return File('./.html/$name.html').create().then((file) {
      return file.writeAsString(contents);
    });
  });
}

mixin Diagnostics {
  String get contextHint;

  void warn(String msg) {
    msg = '[Warning - $contextHint] $msg';
    print('\u001b[1;33m$msg\u001b[0m');
    _log(msg);
  }

  void _log(String info) {
    final date = DateTime.now();
    String filename =
        '.logs/catalyst-${date.year}-${date.month}-${date.day}-${date.hour}';
    File file = File(filename);
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }
    file.writeAsStringSync(
        '${date.minute}:${date.second}:${date.millisecond} $info\n',
        mode: FileMode.append);
  }

  void yeah(String msg) {
    msg = '[Success - $contextHint] $msg';
    print('\u001b[1;32m$msg\u001b[0m');
    _log(msg);
  }

  void info(String msg) {
    msg = '[Info - $contextHint] $msg';
    print('\u001b[30m$msg\u001b[0m');
    _log(msg);
  }

  void error(String msg, {bool fatal = false}) {
    msg = '[Error - $contextHint] $msg';
    print('\u001b[1;31m$msg\u001b[0m');
    _log(msg);
    if (fatal) {
      throw msg;
    }
  }
}
