// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const MyHomePage(title: 'Flutter Test App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  int currentPageIndex = 0;
  late Future<List<PictureList>> futurePictureLists;

  @override
  void initState() {
    super.initState();
    futurePictureLists = fetchPictureList();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _decrementCounter() {
    setState(() {
      _counter--;
    });
  }

  Future<List<PictureList>> fetchPictureList() async {
    final response = await http.get(Uri.parse('https://picsum.photos/v2/list'));

    if (response.statusCode == 200) {
      // return PictureList.fromJson(jsonDecode(response.body));
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((e) => PictureList.fromJson(e)).toList();
    } else {
      throw const HttpException('Failed to connect to API!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.add),
            label: 'Counter',
          ),
          NavigationDestination(
            icon: Icon(Icons.image),
            label: 'Pictures',
          ),
        ],
      ),
      body: <Widget>[
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Counter:',
              ),
              Text(
                '$_counter',
                style: Theme.of(context).textTheme.headline4,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                      icon: const Icon(Icons.add),
                      tooltip: 'Plus',
                      onPressed: _incrementCounter),
                  IconButton(
                      icon: const Icon(Icons.backspace),
                      tooltip: 'Verwijder',
                      onPressed: _decrementCounter),
                ],
              ),
            ],
          ),
        ),
        FutureBuilder<List<PictureList>>(
          future: futurePictureLists,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                    itemCount: snapshot.data!.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                    ),
                    itemBuilder: ((context, index) {
                      return Card(
                        child: Container(
                          decoration: BoxDecoration(
                              border:
                                  Border.all(width: 0.5, color: Colors.grey)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Image.network(snapshot.data![index].url, fit: BoxFit.cover,)
                              ],
                            ),
                          ),
                        ),
                      );
                    })),
              );
            } else {
              return Text('${snapshot.error}');
            }
            // ignore: dead_code
            return const CircularProgressIndicator();
          },
        ), 
      ][currentPageIndex],
    );
  }
}

class PictureList {
  final String author;
  final String url;

  const PictureList({required this.author, required this.url});

  factory PictureList.fromJson(Map<String, dynamic> json) {
    return PictureList(author: json['author'], url: json['download_url']);
  }
}
