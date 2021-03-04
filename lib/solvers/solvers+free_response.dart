part of 'solvers.dart';

class FreeResponseSolver extends Solver {
  static final Map<String, String Function()> answerBank = {
    'Approximately how much time did you spend preparing for the exam? Please enter your answer in hours':
        () => '${_random.nextInt(5)}',
    'What do you estimate was your score on this exam? Please provide a numeric answer':
        () => '${70 + _random.nextInt(30)}',
    'What have you changed in your study preparation since the last exam': () =>
        'I have studied harder, spent more time reading the website.',
    'If you used an exam preparation method not listed in the previous two questions':
        () => 'None',
    'Please comment on recitation: did you attend': () =>
        'No. Probably helpful but I was too busy.',
    'How will you change your study practice': () =>
        _choose(['No', 'Study harder']),
    'Is there anything we should STOP/START/CONTINUE': () =>
        _choose(['No', 'Nah']),
    'Have any additional thoughts?': () =>
        _choose(['This class has so much work...', 'Nah.']),
    "Now that you've completed the website reading, videos, and IKE": () =>
        "Sorry, but I don't have any questions.",
    "With respect to today's reading in the online textbook": () => 'All good.',
  };

  @override
  Future<bool> autoSolve(Page page, Document doc) async {
    final prompt = getPrompt(doc);
    var answer;
    for (var key in answerBank.keys) {
      if (prompt.contains(key)) {
        answer = answerBank[key]();
        break;
      }
    }
    if (answer == null) {
      warn('free response solver encountered an unknown prompt - "$prompt"');
      // Fallback to a random answer.
      answer = _choose(['IDK', "I don't know", 'Not sure...']);
    }
    info('answered with $answer');
    await page.type('#response', answer);
    await submit(page);
    return true;
  }

  @override
  List<String> get types => [
        QuestionTypes.numericalQuestion,
        QuestionTypes.shortAnswerQuestion,
        QuestionTypes.longAnswerQuestion
      ];
}
