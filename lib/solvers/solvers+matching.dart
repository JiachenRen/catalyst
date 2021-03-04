part of 'solvers.dart';

class MatchingQuestionSolver extends Solver {
  @override
  Future<bool> autoSolve(Page page, Document doc) async {
    final selects =
        doc.querySelectorAll('#response_container > * > * > * > select');
    var optionsSet = <String>{};
    for (var select in selects) {
      var selectOptions = select
          .querySelectorAll('option')
          .map((option) => option.attributes['value']);
      for (var option in selectOptions) {
        if (option.isNotEmpty) {
          optionsSet.add(option);
        }
      }
    }
    final options = optionsSet.toList();
    options.shuffle();
    for (var i = 0; i < selects.length; i++) {
      final value = options.removeLast();
      info('selecting $value for select at index $i');
      await page.select('#response_$i', [value]);
    }
    await submit(page);
    return true;
  }

  @override
  List<String> get types => [QuestionTypes.matchingQuestion];
}
