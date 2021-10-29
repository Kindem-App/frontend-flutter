import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_stulish/models/category.dart';
import 'package:flutter_app_stulish/services/httpservice.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async';

class CategoriesMain extends StatefulWidget {
  CategoriesMain({
    Key? key,
  }) : super(key: key);

  @override
  _CategoriesMainState createState() => _CategoriesMainState();
}

class _CategoriesMainState extends State<CategoriesMain> {
  final HttpService service = new HttpService();
  List categories = [];

  void getAllCategory() async {
    final String uri =
        "https://stulish-rest-api.herokuapp.com/api/getAllCategories";

    http.Response result = await http.get(Uri.parse(uri));
    if (result.statusCode == HttpStatus.ok) {
      final jsonResponse = json.decode(result.body);
      List categoryMap = jsonResponse['data'];
      List category = categoryMap.map((i) => Category.fromJson(i)).toList();
      setState(() {
        categories = category;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getAllCategory();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            backgroundColor: Color(0xFF007251),
            body: Container(
              child: Padding(
                padding: const EdgeInsets.only(top: 40, right: 20, left: 20),
                child: Column(
                  children: [
                    Hero(
                      tag: "imageStudy",
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Image(
                            width: MediaQuery.of(context).size.width * 0.10,
                            image: AssetImage("assets/images/study.png"),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20, top: 80),
                      child: Text("CATEGORY",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                    ),
                    CarouselSlider(
                      options: CarouselOptions(height: 250.0),
                      items: categories.map((data) {
                        return Builder(
                          builder: (BuildContext context) {
                            return Container(
                                width: MediaQuery.of(context).size.width,
                                margin: EdgeInsets.symmetric(horizontal: 5.0),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20)),
                                child: Column(
                                  children: [
                                    Image(
                                        width: 200,
                                        image: NetworkImage(data.image)),
                                    Text(
                                      data.name,
                                      style: TextStyle(
                                          fontSize: 20.0,
                                          color: Color(0xFF007251),
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ));
                          },
                        );
                      }).toList(),
                    )
                  ],
                ),
              ),
            )));
  }
}
