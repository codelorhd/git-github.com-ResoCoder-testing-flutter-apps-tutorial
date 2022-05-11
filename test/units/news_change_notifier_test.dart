import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing_tutorial/article.dart';
import 'package:flutter_testing_tutorial/news_change_notifier.dart';
import 'package:flutter_testing_tutorial/news_service.dart';
import 'package:mocktail/mocktail.dart';

// ** This is a Unit Test

class MockNewsService extends Mock implements NewsService {}

// !! remember to use the t_scaffold VS Code snippet to generate this.
// !!! and aaaTest
void main() {
  late NewsChangeNotifier sut; // system under test
  late MockNewsService mockNewsService;

  setUp(
    () {
      // initialize everything related to the test,
      // this chunk runs before each of the test.
      mockNewsService = MockNewsService();
      sut = NewsChangeNotifier(mockNewsService);
    },
  );

  test(
    "initial values are correct",
    () {
      expect(sut.articles, []);
      expect(sut.isLoading, false);
    },
  );

  group('getArticles', () {
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

    // check if the news service getArticles is called. TDD
    test(
      "get articles using the news NewsService",
      () async {
        // we can now provide an implementation for the particular method right here

        // this will fail unless we have an implementation in the getArticles method.
        // go there and add only this functionality.
        // aaa -> arrange
        arrangeNewsServiceReturns3Articles();
        // aaa-> act
        await sut.getArticles();
        // aaa -> assert, verify
        verify(() => mockNewsService.getArticles()).called(1);
      },
    );

    test(
      """
        indicates loading of data,
        sets articles to the ones from  the service,
        indicates that data is not being loaded anymore.
      """,
      () async {
        arrangeNewsServiceReturns3Articles();
        // !! DO NOT AWAIT HERE, because we want to ensure isLoading is true
        final future = sut.getArticles();
        expect(sut.isLoading, true);
        // ** do the the awaiting now.
        await future;
        expect(sut.articles, articlesFromService);
        expect(sut.isLoading, false);
      },
    );
  });
}
