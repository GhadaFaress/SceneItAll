import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'Movie_details_page.dart';

class WatchlistPage extends StatefulWidget {
  final List<Map<String, dynamic>> watchlist;

  const WatchlistPage({required this.watchlist});

  @override
  _WatchlistPageState createState() => _WatchlistPageState();
}

class _WatchlistPageState extends State<WatchlistPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("WatchList"),
        backgroundColor: Color(0xFF1D1E33),
      ),
      backgroundColor: Color(0xFF0A0E21),
      body: widget.watchlist.isNotEmpty
          ? GridView.builder(
        padding: EdgeInsets.all(8.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // Number of items per row
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 0.6, // Adjust the aspect ratio for item size
        ),
        itemCount: widget.watchlist.length,
        itemBuilder: (context, index) {
          final movie = widget.watchlist[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MovieDetailsPage(id: movie['id']),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Image.network(
                        'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                        padding:const EdgeInsets.all(12),
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.white38),
                          onPressed: () {
                            setState(() {
                              widget.watchlist.remove(movie);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Movie Removed')),
                              );
                            });
                          },

                        )
                    ),
                    SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Text(
                        movie['title'] ?? 'Loading...',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      )
          : Center(
          child: Text(
            'No movies found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white54,
            ),
          )
      ),
    );
  }
}

