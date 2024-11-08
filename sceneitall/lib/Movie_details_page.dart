import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
List<Map<String, dynamic>> watchlistMovies = [];
List<Map<String, dynamic>> watchedMovies = [];
List<int> heartedMovies = []; // Track hearted movies by ID


class MovieDetailsPage extends StatefulWidget {
  final int id;

  const MovieDetailsPage({required this.id});

  @override
  _MovieDetailsPageState createState() => _MovieDetailsPageState();
}

class _MovieDetailsPageState extends State<MovieDetailsPage> {
  Map<String, dynamic>? moviedata;
  String? releaseDate;
  List<Map<String, dynamic>> moviecast = []; // Initialize as a list


  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
    fetchMovieReleaseDate();
    fetchMovieCast();
  }

  Future<void> _fetchDetails() async {
    final apiKey = 'ed6a1e5a40c49d00edcd503f4343cdf2'; // Replace with your actual TMDb API key
    final url = 'https://api.themoviedb.org/3/movie/${widget
        .id}?api_key=$apiKey&language=en-US';

    final response = await http.get(Uri.parse(url));



    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        moviedata = data;
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load movie');
    }

  }
  Future<void> fetchMovieReleaseDate() async {
    final apiKey = 'ed6a1e5a40c49d00edcd503f4343cdf2'; // Replace with your actual TMDb API key
    final releaseDateUrl = 'https://api.themoviedb.org/3/movie/${widget.id}/release_dates?api_key=$apiKey';

    final response = await http.get(Uri.parse(releaseDateUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final releaseDates = data['results'] as List;

      // Try to find a US release date or take the first available
      final usRelease = releaseDates.firstWhere(
            (item) => item['iso_3166_1'] == 'US',
        orElse: () => releaseDates.isNotEmpty ? releaseDates[0] : null,
      );

      if (usRelease != null && usRelease['release_dates'] != null) {
        setState(() {
          releaseDate = usRelease['release_dates'][0]['release_date'];
        });
      } else {
        setState(() {
          releaseDate = 'No release date available';
        });
      }
    } else {
      throw Exception('Failed to load release date');
    }
  }
  Future<void> fetchMovieCast() async {
    final apiKey = 'ed6a1e5a40c49d00edcd503f4343cdf2'; // Replace with your actual TMDb API key
    final url = 'https://api.themoviedb.org/3/movie/${widget.id}/credits?api_key=$apiKey&language=en-US';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        moviecast = List<Map<String, dynamic>>.from(data['cast']);
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load movie');
    }

  }


  @override
  Widget build(BuildContext context) {
    bool isHearted = heartedMovies.contains(widget.id);
    return Scaffold(
        backgroundColor: Color(0xFF0A0E21),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : moviedata == null
            ? Center(child: Text('No data found'))
            : CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 300.0,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child:Text(
                      moviedata!['title'] ?? 'Title not available',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black.withOpacity(1),
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      maxLines: 1, // Limit to a single line
                      overflow: TextOverflow.ellipsis, // Handle overflow with ellipsis
                    ),
                   ),
                    SizedBox(height: 4,),
                    Flexible(child:Text(
                      moviedata!['tagline'] ?? 'No tagline available',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white38,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1, // Limit to a single line
                      overflow: TextOverflow.ellipsis, // Handle overflow with ellipsis
                    ),
                    )
                  ],
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (moviedata!['backdrop_path'] != null)
                      Image.network(
                        'https://image.tmdb.org/t/p/w500${moviedata!['backdrop_path']}',
                        fit: BoxFit.cover,
                      ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.5),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Expanded Text Widget
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                'Release date: ',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                moviedata!['release_date'] ?? 'N/A',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8,),
                          Row(
                              children: [
                                Text(
                                  'Duration: ',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.amber,
                                    fontWeight: FontWeight.bold,

                                  ),
                                ),
                                Text(
                                  '${moviedata!['runtime'] ?? 'N/A'} min',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ]

                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,  // Aligns contents to the left
                            children: [
                              SizedBox(height: 8),
                              Text(
                                'Overview',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                moviedata!['overview'] ?? 'No overview available',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Rating ',
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                moviedata!['vote_average'] != null
                                    ? '${moviedata!['vote_average']} / 10'
                                    : 'No rating available',
                                style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                              ),
                              ),

                            ],
                          ),

                        ],

                      ),
                    ),

                    Container(
                      width: 170,
                      height: 250,
                      margin: EdgeInsets.only(left: 16.0),
                      // Space between box and text
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          )
                        ],
                        image: DecorationImage(
                          image: NetworkImage(
                              'https://image.tmdb.org/t/p/w500${moviedata!['poster_path']}'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Additional content (e.g., cast, ratings) can go here
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: Icon(Icons.add, color: Colors.blue),
                          onPressed: () {
                            setState(() {
                              if (!watchlistMovies.any((movie) => movie['id'] == moviedata!['id'])) {
                                watchlistMovies.add(moviedata!);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Added to Watchlist')),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Already in Watchlist')),
                                );
                              }
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.check, color: Colors.green),
                          onPressed: () {
                            setState(() {
                              if (!watchedMovies.any((movie) => movie['id'] == moviedata!['id'])) {
                                watchedMovies.add(moviedata!);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Added to SceneIt')),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Already in SceneIt list')),
                                );
                              }
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.favorite, color: isHearted ? Colors.red : Colors.white),
                          onPressed: () {
                            setState(() {
                              if (isHearted) {
                                heartedMovies.remove(widget.id);
                              } else {
                                heartedMovies.add(widget.id);
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    // Other details like synopsis, cast,date,languages,genres etc.
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child:Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cast',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      height: 150, // Adjust height as needed
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: moviecast.length,
                        itemBuilder: (context, index) {
                          final cast = moviecast[index];
                          return Container(
                            width: 140,
                            margin: EdgeInsets.symmetric(horizontal: 10.0),
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: cast['profile_path'] != null
                                      ? Image.network(
                                    'https://image.tmdb.org/t/p/w185${cast['profile_path']}',
                                    height: 100,
                                    fit: BoxFit.cover,
                                  )
                                      : Icon(Icons.person, size: 100, color: Colors.grey), // Default icon
                                ),
                                SizedBox(height: 5),
                                Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          cast['name'] ?? 'No Name',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          cast['character'] ?? '',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white70,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],

                                    ))

                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

          ],
        )
    );
  }
}
