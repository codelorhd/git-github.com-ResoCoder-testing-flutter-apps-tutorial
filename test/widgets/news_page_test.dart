// ** This is the Widget Test!!
// ** Easy to Write and Run!
// ** You do not see any interaction though!!!
// ** Less Expensive than the Integration Test

// !! widgets do not rebuilt automatically, you need to instruct it to do it manually!

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_testing_tutorial/article.dart';
import 'package:flutter_testing_tutorial/main.dart';
import 'package:flutter_testing_tutorial/news_change_notifier.dart';
import 'package:flutter_testing_tutorial/news_page.dart';
import 'package:flutter_testing_tutorial/news_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

// ?? Code duplication is allowed here
class MockNewsService extends Mock implements NewsService {}

void main() {
  // ? We do not need the sut here!

  late MockNewsService mockNewsService;

  setUp(() {
    mockNewsService = MockNewsService();
  });

  final articlesFromService = [
    Article(title: 'Test 1', content: 'Test 1 Content'),
    Article(title: 'Test 2', content: 'Test 2 Content'),
    Article(title: 'Test 3', content: 'Test 3 Content'),
  ];

  void arrangeNewsServiceReturns3Articles() {
    when(() => mockNewsService.getArticles()).thenAnswer(
        (_) async => articlesFromService
        // this means the three articles will be populated or used in that function.
        );
  }

  void arrangeNewsServiceReturns3ArticlesAfter2SecondsWait() {
    when(() => mockNewsService.getArticles()).thenAnswer((_) async {
      await Future.delayed(const Duration(seconds: 2));
      return articlesFromService;
    });
  }

  Widget createWidgetUnderTest() {
    return MaterialApp(
      title: 'News App',
      home: ChangeNotifierProvider(
        create: (_) => NewsChangeNotifier(mockNewsService),
        child: const NewsPage(),
      ),
    );
  }

  testWidgets(
    "title is displayed",
    (WidgetTester tester) async {
      // load the articles
      arrangeNewsServiceReturns3Articles();
      // create and build the page you want to test.
      await tester.pumpWidget(createWidgetUnderTest());
      // this applies to static UI, that does not needs loading or has delayed.
      expect(find.text("News"), findsOneWidget);
    },
  );

  testWidgets(
    "loading indicator is displayed while waiting for articles",
    (WidgetTester tester) async {
      arrangeNewsServiceReturns3ArticlesAfter2SecondsWait();

      await tester.pumpWidget(createWidgetUnderTest());
      // force a widget rebuild
      await tester.pump(const Duration(milliseconds: 500));

      // expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // ! incase you have multiple CircularProgressIndicator
      expect(find.byKey(const Key("progress-indicator")), findsOneWidget);

      // wait until there are no more rebuild happening, e.g. animations
      // e.g. the 2seconds delayed must have been passed before the loading widget can be removed.
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    "articles are displayed",
    (WidgetTester tester) async {
      arrangeNewsServiceReturns3Articles();
      await tester.pumpWidget(createWidgetUnderTest());
      await tester
          .pump(); // no need to introduce duration, because we do not care right now, we just want an instant rebuild

      for (final article in articlesFromService) {
        expect(find.text(article.title), findsOneWidget);
        expect(find.text(article.content), findsOneWidget);
      }
    },
  );
}
