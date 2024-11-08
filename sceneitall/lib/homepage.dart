import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Movie_details_page.dart';
import 'WatchedPage.dart';
import 'WatchlistPage.dart';
import 'searchpage.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0E21),
      body: Center(
        child: Image.asset(
          'assets/images/logo.png',
          height: 300,
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List trendingMovies = [];
  List newReleases = [];

  @override
  void initState() {
    super.initState();
    fetchTrendingMovies();
    fetchNewReleases();
  }

  Future<void> fetchTrendingMovies() async {
    final apiKey = 'ed6a1e5a40c49d00edcd503f4343cdf2';
    final url = 'https://api.themoviedb.org/3/trending/movie/week?api_key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        trendingMovies = data['results'];
      });
    } else {
      throw Exception('Failed to load trending movies');
    }
  }

  Future<void> fetchNewReleases() async {
    final apiKey = 'ed6a1e5a40c49d00edcd503f4343cdf2';
    final url = 'https://api.themoviedb.org/3/movie/now_playing?api_key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        newReleases = data['results'];
      });
    } else {
      throw Exception('Failed to load new releases');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0E21),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/background.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 150,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SearchPage()),
                    );
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: Icon(Icons.search, color: Colors.black54),
                        ),
                        Text(
                          'Search movies...',
                          style: TextStyle(color: Colors.black54, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              buildSection('Trending', trendingMovies),
              SizedBox(height: 20),
              buildSection('New Releases', newReleases),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF1D1E33),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.white),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark, color: Colors.white),
            label: 'Watchlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check, color: Colors.white),
            label: 'Watched',
          ),
        ],
        selectedItemColor: Colors.amber,
          onTap: (index) {
            if (index == 1) { // Watchlist tab
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      WatchlistPage(watchlist: watchlistMovies),
                ),
              );
            } else if (index == 2) { // Watched tab
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WatchedPage(watched: watchedMovies),
                ),
              );
            }
          },
      ),
    );
  }

  Widget buildSection(String title, List movies) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20.0, bottom: 10.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.amber,
            ),
          ),
        ),
        Container(
          height: 200,
          child: movies.isNotEmpty
              ? ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return GestureDetector(
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MovieDetailsPage(id: movie['id']),
                      ),
                    );
                  },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.35,
                margin: EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
                        height: 170,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      movie['title'] ?? 'Loading...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
              )
              );
            },
          )
              : Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ],
    );
  }
}
