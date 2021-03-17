import 'dart:math';

import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:catalyst/question_types.dart';
import 'package:catalyst/utils.dart';
import 'package:puppeteer/puppeteer.dart';

part 'solvers+multiple_choice.dart';

part 'solvers+free_response.dart';

part 'solvers+confidence.dart';

part 'solvers+priority.dart';

part 'solvers+many_choice.dart';

part 'solvers+matching.dart';

part 'solvers+ranking.dart';

part 'solvers+region.dart';

part 'solvers+sketch.dart';

Random _random = Random();

String _choose(List<String> list) {
  return list[_random.nextInt(list.length)];
}

abstract class Solver with Diagnostics {
  List<String> get types;

  int sessionId;

  Future<bool> solve(Page page) async {
    final doc = await page.content.then((content) {
      return parse(content);
    });
    return autoSolve(page, doc);
  }

  String getPrompt(Document doc) => doc.querySelector('#item_prompt')?.text;

  Future submit(Page page) async {
    assert(sessionId != null);
    await page.click('input[type=submit]');
    info('submitted');
    await Future.delayed(Duration(seconds: _random.nextInt(4)));
  }

  Future<bool> autoSolve(Page page, Document doc);

  @override
  String get contextHint => 'Solver';
}
