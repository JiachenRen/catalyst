part of 'solvers.dart';

class SketchQuestionSolver extends Solver {
  @override
  Future<bool> autoSolve(Page page, Document doc) async {
    await page.evaluate('switchToTextResponse()');
    await page.type('#response',
        _choose(["IDK", "Sorry, I don't know.", "I'll answer this later."]));
    await submit(page);
    return true;
  }

  @override
  List<String> get types => [QuestionTypes.sketchQuestion];
}
