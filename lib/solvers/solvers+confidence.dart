part of 'solvers.dart';

class ConfidenceQuestionSolver extends Solver {
  static final regex = RegExp(r'([0-9]+)\svotes.+([0-9]+)\schoices');

  @override
  Future<bool> autoSolve(Page page, Document doc) async {
    final msg = doc.querySelector('#alertMessage').text;
    final match = regex.firstMatch(msg);
    if (match == null) {
      error('failed to find votes/choices', fatal: true);
    }
    final votes = int.parse(match.group(1));
    final choices = int.parse(match.group(2));
    for (var i = 0; i < votes; i++) {
      final choice = _random.nextInt(choices);
      await page.click('#plusonebtn$choice');
      info('clicking button $i');
    }
    await submit(page);
    return true;
  }

  @override
  List<String> get types => [QuestionTypes.confidenceQuestion];
}