// Either test the whole app or an individual pages that makes sense together
// !! You are not testing a single widget in an integration test.
// !! Reserve it only for testing UI flwo alone, WHAT THE USER CAN DO!
// !! Use it Sparingly!!!! Integration Test is slowwwww!!!
// ** Do not put inside the tests folder.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_testing_tutorial/article.dart';
import 'package:flutter_testing_tutorial/article_page.dart';
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

  // !! TODO: Too many code duplication below!

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
    """
    tapping on the first article excerpt open the article page
    where the full article content is displayed.
    """,
    (WidgetTester tester) async {
      arrangeNewsServiceReturns3Articles();
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // tap the first article in the list tile, so find the text in the list tile,
      // and tap on it!

      await tester.tap(find.text("Test 1 Content"));
      await tester.pumpAndSettle(); // wait for all to rebuild

      // ?? Testing Navigation
      // this should not exist again
      expect(find.byType(NewsPage), findsNothing);
      // this should be found!
      expect(find.byType(ArticlePage), findsOneWidget);

      // ?? Testing New Page
      // the title
      expect(find.text('Test 1'), findsOneWidget);
      // the content of the article
      expect(find.text('Test 1 Content'), findsOneWidget);
    },
  );
}
