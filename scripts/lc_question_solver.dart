import 'package:catalyst/credential.dart';
import 'package:catalyst/learning_catalyst.dart';
import 'package:catalyst/utils.dart';
import 'package:puppeteer/puppeteer.dart';

import 'dart:io';

void main(List<String> args) async {
  final browser = await puppeteer.launch(
      headless: true,
      executablePath:
      '.local-chromium/768783/chrome-mac/Chromium.app/Contents/MacOS/Chromium');
  try {
    await lc(browser, await Credential.load());
  } catch (e, stacktrace) {
    print('Fatal error - $e\n$stacktrace');
  }
  print('Closing browser...');
  await browser.close();
}

Future lc(Browser browser, Credential credential) async {
  // Login
  final lc = LearningCatalyst(browser, credential);
  await lc.login().then((page) async {
    await screenshot(page, 'lc_login');
    await saveHtml(page, 'lc_login');
  });

  // List active sessions
  print('Active sessions:');
  final sessions = await lc.getActiveSessions();
  sessions.forEach((e) => print('\t├── $e'));

  // Join a chosen session
  int sessionId;
  while (sessionId == null) {
    print('Enter session ID:');
    sessionId = int.tryParse(stdin.readLineSync());
    if (sessionId == null || !sessions.map((e) => e.id).contains(sessionId)) {
      print('Invalid session Id');
    }
  }
  await lc.joinSession(sessionId);
  await screenshot(lc.page, '$sessionId');

  // REPL - answer specified questions automatically!
  final qCount = await lc.getQuestionsCount();
  print('Enter question no. to solve ($qCount questions), enter "q" to exit:');
  while (true) {
    final cmd = stdin.readLineSync();
    if (cmd == 'q') {
      break;
    }
    int q = int.tryParse(cmd);
    if (q == null || q > qCount) {
      print('Error - enter a valid question number.');
    } else {
      await lc.answerQuestion(q);
      await screenshot(lc.page, '$sessionId.$q');
    }
  }
}