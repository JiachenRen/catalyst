import 'package:catalyst/credential.dart';
import 'package:catalyst/learning_catalyst.dart';
import 'package:catalyst/utils.dart';
import 'package:puppeteer/puppeteer.dart';


void main() async {
  final _credential = await Credential.load();
  // Instantiate browser & open a new tab
  final browser = await puppeteer.launch(
      headless: false,
      executablePath:
          '.local-chromium/768783/chrome-mac/Chromium.app/Contents/MacOS/Chromium');

  // Login
  final lc = LearningCatalyst(browser, _credential);
  await lc.login().then((page) async {
    await screenshot(page, 'lc_login');
    await saveHtml(page, 'lc_login');
  });

  // List active sessions
  print('Active sessions:');
  final sessions = await lc.getActiveSessions();
  sessions.forEach((e) => print('\t├── $e'));

  // Join first active session and view q1, q2, q3
  if (sessions.isNotEmpty) {
    final session = sessions.first;
    print('Joining session $session...');
    await lc.joinSession(session.id);
    await screenshot(lc.page, '$session');
    print('Getting number of questions...');
    int questionsCount = await lc.getQuestionsCount();
    print('Retrieved $questionsCount questions.');
    print('Going to question 2, 3, 4 and taking screenshots...');
    await lc.gotoQuestion(2);
    await screenshot(lc.page, '$session - q2');
    await lc.gotoQuestion(3);
    await screenshot(lc.page, '$session - q3');
    await lc.gotoQuestion(4);
    await screenshot(lc.page, '$session - q4');
    print('Done.');
  }
  await browser.close();
}
