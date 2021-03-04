import 'dart:io';

import 'package:catalyst/credential.dart';
import 'package:catalyst/learning_catalyst.dart';
import 'package:catalyst/utils.dart';
import 'package:puppeteer/puppeteer.dart';

class Logger with Diagnostics {
  String get contextHint => 'Main';
}

final _logger = Logger();

void main(List<String> args) async {
  int tries = 0;
  int trials = 3;
  bool success = false;
  while (tries < trials) {
    final browser = await puppeteer.launch(
        headless: true,
        executablePath:
            '.local-chromium/768783/chrome-mac/Chromium.app/Contents/MacOS/Chromium');
    try {
      success = await lc(browser, await Credential.load());
    } catch (e, stacktrace) {
      _logger.error('fatal error - $e\n$stacktrace');
    }
    _logger.info('closing browser...');
    if (!success && tries < trials) {
      _logger.info('retrying...');
    }
    await browser.close();
    if (success) {
      break;
    }
  }
  if (success) {
    await Process.run('osascript', ['-e', 'set volume 3']).then((result) {
      stdout.write(result.stdout);
      stderr.write(result.stderr);
    });
    await Process.run(
        'say', ['"学習触媒を無事に完了"']);
  } else {
    await Process.run('osascript', ['-e', 'set volume 10']);
    for (var i = 0; i < 10; i++) {
      for (var i = 0; i < 3; i++) {
        await Process.run('osascript', ['-e', 'beep']);
      }
      await Process.run(
          'say', ['"起きてください、学習触媒を完了できませんでした"']);
      for (var i = 0; i < 3; i++) {
        await Process.run('osascript', ['-e', 'beep']);
      }
      await Future.delayed(Duration(seconds: 3));
    }
  }
}

Future lc(Browser browser, Credential credential) async {
  // Login
  final lc = LearningCatalyst(browser, credential);
  return await lc.doEverythingForMe();
}
