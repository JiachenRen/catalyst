import 'dart:io';

import 'package:puppeteer/puppeteer.dart';

void main() async {
  // Download the Chromium binaries, launch it and connect to the "DevTools"
  var browser = await puppeteer.launch();

  // Open a new tab
  var myPage = await browser.newPage();

  // Go to a page and wait to be fully loaded
  await myPage.goto('https://www.google.com', wait: Until.networkIdle);

  // Do something... See other examples
  await myPage.screenshot().then((data) {
    return File('./.screenshots/google.png').create().then((file) {
      return file.writeAsBytes(data);
    });
  });

  // Gracefully close the browser's process
  await browser.close();
}
