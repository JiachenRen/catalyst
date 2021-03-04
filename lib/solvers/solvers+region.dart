part of 'solvers.dart';

class RegionQuestionSolver extends Solver {
  @override
  Future<bool> autoSolve(Page page, Document doc) async {
    final width = await page.evaluate<num>(r'$("#container > img").width()');
    final height =
        await page.evaluate<num>(r'$("#container > img").height()');
    final randomX = _random.nextInt(width);
    final randomY = _random.nextInt(height);
    await page.evaluate(
        "\$('#response')[0].setAttribute('value', '$randomX,$randomY')");
    await page.evaluate(r'$("input[type=submit]").click()');
    return true;
  }

  @override
  List<String> get types => [QuestionTypes.regionQuestion];
}
