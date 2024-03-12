import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<List<Gymdata>> fetchAlbum() async {
  final response = await http
      .get(Uri.parse('https://api.csdi.gov.hk/apim/dataquery/api/?id=lcsd_rcd_1629267205215_5008&layer=fitness_20220311104235697&limit=10&offset=0'));
  
  if (response.statusCode == 200) {
    var responsejson = json.decode(response.body);
    return (responsejson['features'] as List).map((p) 
    => Gymdata.fromJson(p)).toList();
  }else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

class Gymdata {
  final String addressEn, search02, name;

  Gymdata({
    required this.addressEn,
    required this.search02,
    required this.name,
  });

  factory Gymdata.fromJson(Map<String, dynamic> json) {
    return Gymdata(
      addressEn: json['ADDRESS_EN'].toString(), 
      search02: json['SEARCH02_TC'].toString(), 
      name: json['NAME_TC'].toString()
    ) ;
  }
}

// app starting point
void main() => runApp(const MyApp());

//class MyApp extends StatefulWidget {
//  const MyApp({super.key});
//
//  @override
//  State<MyApp> createState() => _MyAppState();
//}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// homepage class
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

//class _MyAppState extends State<MyApp> {
class _MyHomePageState extends State<MyHomePage> {
  late Future<List<Gymdata>> futureAlbum;

  @override
  void initState() {
    super.initState();
    futureAlbum = fetchAlbum();
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    body: Center(
      child: FutureBuilder<List<Gymdata>>(
        future: futureAlbum,
        builder: (context,AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
            final data = snapshot.data!;
            return buildPosts(data);
          } else {
            return const Text("No data available");
          }
        },
      ),
    ),
  );
  }

Widget buildPosts(List<Gymdata> data) {
  return ListView.builder(
    itemCount: data.length,
    itemBuilder: (context, index) {
      final Gymdata = data[index];
      return Container(
        color: Colors.grey.shade300,
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        height: 100,
        width: double.maxFinite,
        child: Row(
          children: [
            Expanded(flex: 3, child: Text(Gymdata.name)),
          ],
        ),
      );
    },
  );
}
}