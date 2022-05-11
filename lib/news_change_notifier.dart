import 'package:flutter/material.dart';
import 'package:flutter_testing_tutorial/article.dart';
import 'package:flutter_testing_tutorial/news_service.dart';

class NewsChangeNotifier extends ChangeNotifier {
  final NewsService _newsService;

  // we did this because we want to be able to mock a service,
  // we could have initiated it in the line above.
  NewsChangeNotifier(this._newsService);

  List<Article> _articles = [];

  List<Article> get articles => _articles;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> getArticles() async {
    _isLoading = true;
    notifyListeners(); // let the change be propagated to the UI

    _articles = await _newsService.getArticles();
    _isLoading = false;
    notifyListeners(); // let the change be propagated to the UI
  }
}
