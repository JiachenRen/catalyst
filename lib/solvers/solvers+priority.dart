part of 'solvers.dart';

class PriorityQuestionSolver extends Solver {
  @override
  Future<bool> autoSolve(Page page, Document doc) async {
    int choices = doc.querySelectorAll('.move_up:not(.iconic_link)').length;
    for (var i = 0; i < 10; i++) {
      if (_random.nextBool()) {
        int choice = 1 + _random.nextInt(choices - 1);
        await page.evaluate('moveUp($choice)');
        info('moving choice $choice up');
      } else {
        int choice = _random.nextInt(choices - 1);
        await page.evaluate('moveDown($choice)');
        info('moving choice $choice down');
      }
    }
    await submit(page);
    return true;
  }

  @override
  List<String> get types => [QuestionTypes.priorityQuestion];
}
