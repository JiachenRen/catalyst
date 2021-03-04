part of 'solvers.dart';

class RankingQuestionSolver extends Solver {
  @override
  Future<bool> autoSolve(Page page, Document doc) async {
    int currChoice = 0;
    List<String> options;
    Set<String> operatorSet;
    var choiceSelector = '#choice_$currChoice';
    var operatorSelector = '#operator_${currChoice + 1}';
    var choice = doc.querySelector(choiceSelector);
    var operator = doc.querySelector(operatorSelector);
    while (choice != null || operator != null) {
      if (options == null) {
        options =
            choice.querySelectorAll('option').where((a) => a.text != '?' &&
                a.text != '=')
                .map((a) => a.attributes['value'])
                .toList();
        options.shuffle();
      }
      if (operatorSet == null) {
        operatorSet =
            operator.querySelectorAll('option').where((a) => a.text != '?')
                .map((a) => a.attributes['value'])
                .toSet();
      }
      final option = options.removeLast();
      final op = operatorSet.first;
      if (choice != null) {
        info('selecting $option for choice $currChoice');
        await page.select(choiceSelector, [option]);
      }
      if (operator != null) {
        info('selecting $op for operator choice ${currChoice + 1}');
        await page.select(operatorSelector, [op]);
      }
      currChoice++;
      choiceSelector = '#choice_$currChoice';
      operatorSelector = '#operator_${currChoice + 1}';
      choice = doc.querySelector(choiceSelector);
      operator = doc.querySelector(operatorSelector);
    }
    await submit(page);
    return true;
  }

  @override
  List<String> get types => [QuestionTypes.rankingQuestion];

}