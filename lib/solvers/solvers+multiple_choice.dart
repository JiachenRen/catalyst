part of 'solvers.dart';

class MultipleChoiceSolver extends Solver {
  @override
  Future<bool> autoSolve(Page page, Document doc) async {
    final responses = doc.querySelectorAll('#responses > li > a');
    responses.shuffle();
    await page.goto(
        'https://learningcatalytics.com/' + responses.first.attributes['href']);
    await page.goto(
        'https://learningcatalytics.com/class_sessions/$sessionId');
    info('answered with response ${responses.first}');
    return true;
  }

  @override
  List<String> get types => [QuestionTypes.multipleChoiceQuestion];
}
