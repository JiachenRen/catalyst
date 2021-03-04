part of 'solvers.dart';

class ManyChoiceSolver extends Solver {
  @override
  Future<bool> autoSolve(Page page, Document doc) async {
    final choices = doc.querySelectorAll('#responses > li').length;
    final active = choices <= 4 ? choices : choices - 1;
    int count = _random.nextInt(choices);
    for (int i = 0; i < count; i++) {
      final choice = _random.nextInt(active);
      await page.evaluate('toggle($choice)');
      info('toggling choice $choice');
    }
    info('selected $count in total');
    await submit(page);
    return true;
  }

  @override
  List<String> get types => [QuestionTypes.manyChoiceQuestion];
}
