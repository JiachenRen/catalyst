import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:catalyst/class_session.dart';
import 'package:catalyst/credential.dart';
import 'package:catalyst/solvers/solvers.dart';
import 'package:catalyst/utils.dart';
import 'package:catalyst/question_types.dart';
import 'package:puppeteer/puppeteer.dart';

class LearningCatalyst with Diagnostics {
  static final String _apiUrl =
      'https://login.pearson.com/v1/piapi/piui/signin';
  static final String _okUrl = 'https:%2F%2Flearningcatalytics.com%2Flogin';
  static final int _siteId = 252444;
  static final String _questionTypeSelector = '#item_type_header';

  static final _classSessionIdRegex = RegExp(r'class_session_id\=([0-9]+)$');

  String get loginUrl =>
      '$_apiUrl?client_id=${_credential.clientId}&okurl=$_okUrl&siteid=$_siteId';

  bool _loggedIn = false;

  bool get loggedIn => _loggedIn;

  Browser _browser;

  Credential _credential;

  int _currentSessionId;

  Map<int, ClassSession> _sessions = {};

  Map<String, Solver> _solvers = {
    QuestionTypes.shortAnswerQuestion: FreeResponseSolver(),
    QuestionTypes.numericalQuestion: FreeResponseSolver(),
    QuestionTypes.longAnswerQuestion: FreeResponseSolver(),
    QuestionTypes.multipleChoiceQuestion: MultipleChoiceSolver(),
    QuestionTypes.rankingQuestion: RankingQuestionSolver(),
    QuestionTypes.matchingQuestion: MatchingQuestionSolver(),
    QuestionTypes.manyChoiceQuestion: ManyChoiceSolver(),
    QuestionTypes.priorityQuestion: PriorityQuestionSolver(),
    QuestionTypes.confidenceQuestion: ConfidenceQuestionSolver(),
    QuestionTypes.regionQuestion: RegionQuestionSolver(),
  };

  Page page;

  LearningCatalyst(this._browser, this._credential);

  Future<Page> login() async {
    if (page != null) {
      return page;
    }
    info('opening new page for Learning Catalyst');
    page = await _browser.newPage();
    final loginUrl = this.loginUrl;
    info('login into LC @ $loginUrl');
    await page.goto(loginUrl, wait: Until.networkIdle);

    info('authenticating using username & password');
    await page.type('#username', _credential.username);
    await page.type('#password', _credential.password);
    await page.clickAndWaitForNavigation('#mainButton',
        wait: Until.networkIdle);
    info('authenticated... resolving cookies');
    await page.goto('https://learningcatalytics.com/sign_in',
        wait: Until.networkIdle);
    yeah('login successful!');
    _loggedIn = true;
    return page;
  }

  Future<List<ClassSession>> getActiveSessions() async {
    if (!loggedIn) {
      error('not logged in', fatal: true);
    }
    Document doc = await _doc(page);
    final sessions = doc
        .querySelectorAll('.view_all_div > * > * > .join_class_session_link')
        .map((link) {
      final name = link.text;
      final sessionId = int.parse(
          _classSessionIdRegex.firstMatch(link.attributes['href']).group(1));
      return ClassSession(sessionId, name: name);
    }).toList();
    for (var session in sessions) {
      _sessions[session.id] = session;
    }
    return sessions;
  }

  Future<Page> joinSession(int sessionId) async {
    info('joining session $sessionId');
    await page.goto(ClassSession(sessionId).url, wait: Until.networkIdle);
    _currentSessionId = sessionId;
    return page;
  }

  Future<int> getQuestionsCount() {
    return _doc(page).then((doc) {
      return doc.querySelectorAll('.jump.numeric_jump').length;
    });
  }

  Future<Page> gotoQuestion(int questionNo) async {
    if (_currentSessionId == null) {
      error('no current session', fatal: true);
    }
    await page.evaluate('switchItem(${questionNo - 1})');
    await page.waitForResponse(
        'https://learningcatalytics.com/class_sessions/$_currentSessionId/deliver_standalone_item');
    return page;
  }

  Future<bool> answerQuestion(int questionNo) async {
    await gotoQuestion(questionNo);
    final doc = await _doc(page);
    final type = doc.querySelector(_questionTypeSelector)?.text;
    if (type == null) {
      info(
          'question $questionNo already answered ${doc.querySelector('.alert')?.text}');
      return true;
    }
    final solver = _solvers[type];
    if (solver == null) {
      error(
          'unable to solve question $questionNo - unknown question type $type');
      return false;
    }
    info('solving question $questionNo of type $type');
    assert(_currentSessionId != null);
    solver.sessionId = _currentSessionId;
    return solver.solve(page);
  }

  Future<bool> answerAllQuestionsIn(int id) async {
    if (await sessionCompleted(id)) {
      info('session $id completed');
      return true;
    }
    info('answering all questions in session $id');
    int qCount = await getQuestionsCount();
    info('found $qCount questions');
    for (var i = 1; i <= qCount; i++) {
      try {
        await answerQuestion(i);
      } catch (e) {
        error('error answering question $i');
      }
    }
    return await sessionCompleted(id);
  }

  Future<bool> sessionCompleted(int id) {
    return joinSession(id).then((_) {
      return _doc(page).then((value) {
        var block = value.querySelector('#all_done');
        return block != null && block.attributes['style'] == 'display: block;';
      });
    });
  }

  /// Answer all questions in all sessions
  Future<bool> doEverythingForMe() async {
    await login().then((page) async {
      await screenshot(page, 'lc_login');
      await saveHtml(page, 'lc_login');
    });
    final active = await getActiveSessions();
    var activeSessions = 'list of active sessions\n';
    for (var a in active) {
      activeSessions += '\t├── $a\n';
    }
    info(activeSessions);
    bool success = true;
    for (var session in active) {
      var sessionCompleted = await answerAllQuestionsIn(session.id);
      if (sessionCompleted) {
        yeah('successfully completed session $session');
      } else {
        error('failed to complete session $session');
      }
      success = success && sessionCompleted;
    }
    if (success) {
      yeah('successfully completed all sessions');
      return true;
    } else {
      error('failed to complete at least one of the sessions');
      return false;
    }
  }

  Future<Document> _doc(Page page) {
    return page.content.then((content) {
      return parse(content);
    });
  }

  @override
  String get contextHint => 'Learning Catalyst';
}
