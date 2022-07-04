import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart';

// En apuntes, está explicado cómo usar la Api.

// Importar de material, no de cupertino
class MoviesProvider extends ChangeNotifier {
  final String _apiKey = '47b9d7290b6f057ee873786df73048b2';
  final String _baseUrl = 'api.themoviedb.org';
  final String _language = 'es-ES';

  List<Movie> onDisplayMovies = [];
  List<Movie> popularMovies = [];

  Map<int, List<Cast>> moviesCast = {};

  int _popularPage = 0;

  MoviesProvider() {
    getOnDisplayMovies();
    getPopularMovies();
    // ignore: avoid_print
    print('MoviesProvider inicializado');

    getOnDisplayMovies();
  }

  // [int page = 1 ] significa que es opcional, pero si no da el dato vale 1
  Future<String> _getJsonData(String endpoint, [int page = 1]) async {
    var url = Uri.https(_baseUrl, endpoint,
        {'api_key': _apiKey, 'language': _language, 'page': '$page'});

    // Await the http get response, then decode the json-formatted response.
    final response = await http.get(url);
    return response.body;
  }

  getOnDisplayMovies() async {
    final jsonData = await _getJsonData('3/movie/now_playing');
    final nowPlayingResponse = NowPlayingResponse.fromJson(jsonData);
    onDisplayMovies = nowPlayingResponse.results;
    notifyListeners();
  }

  getPopularMovies() async {
    _popularPage++;

    final jsonData = await _getJsonData('3/movie/popular', 1);
    final popularResponse = PopularResponse.fromJson(jsonData);

    // Toma las películas actuales y siempre va a ser parte de las popular movies y se concatenan los resultados
    // ... es el spread operator, para separar cada una de las películas
    popularMovies = [...popularMovies, ...popularResponse.results];
    notifyListeners();
  }

  Future<List<Cast>> getMovieCast(int movieId) async {
    if (moviesCast.containsKey(movieId)) return moviesCast[movieId]!;

    print('pidiendo info al servidor');

    final jsonData = await _getJsonData('3/movie/$movieId/credits');
    final creditsResponse = CreditsResponse.fromJson(jsonData);

    moviesCast[movieId] = creditsResponse.cast;

    return creditsResponse.cast;
  }
}
