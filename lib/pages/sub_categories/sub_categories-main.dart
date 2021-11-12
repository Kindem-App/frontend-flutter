import 'package:avatar_glow/avatar_glow.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_stulish/models/sub_category.dart';
import 'package:flutter_app_stulish/pages/courses/courses-main.dart';
import 'package:flutter_app_stulish/pages/courses/courses-test.dart';
import 'package:flutter_app_stulish/services/auth.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SubCategoriesMain extends StatefulWidget {
  SubCategoriesMain(
      {Key? key,
      required this.image,
      required this.id_category,
      required this.isTest})
      : super(key: key);
  final bool isTest;
  final String id_category;
  final String image;
  @override
  _SubCategoriesMainState createState() => _SubCategoriesMainState();
}

class _SubCategoriesMainState extends State<SubCategoriesMain> {
  List sub_categories = [];

  void getAllSubCategories() async {
    final String uri =
        "https://stulish-rest-api.herokuapp.com/api/v1/getSubCategoriesById/" +
            widget.id_category;

    String? token =
        await Provider.of<AuthProvider>(context, listen: false).getToken();
    http.Response result = await http.get(Uri.parse(uri), headers: {
      'Authorization': 'Bearer $token',
    });
    if (result.statusCode == HttpStatus.ok) {
      final jsonResponse = json.decode(result.body);
      List subCategoryMap = jsonResponse['data'];
      List subCategory =
          subCategoryMap.map((i) => SubCategory.fromJson(i)).toList();
      setState(() {
        sub_categories = subCategory;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getAllSubCategories();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            backgroundColor: Color(0xFF007251),
            body: Container(
              child: Padding(
                padding: const EdgeInsets.only(top: 40, right: 20, left: 20),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context, true);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        child: ExtendedImage.network(
                          widget.image,
                          width: 80,
                          fit: BoxFit.fill,
                          cache: true,
                          borderRadius: BorderRadius.all(Radius.circular(30.0)),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20, top: 20),
                      child: Text("SUB CATEGORY",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      child: ListView.builder(
                          itemCount: sub_categories.length,
                          itemBuilder: (context, int index) {
                            return InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (BuildContext context) {
                                  return widget.isTest == false
                                      ? CoursesMain(
                                          id_sub_category:
                                              sub_categories[index].id,
                                          image: sub_categories[index].image,
                                          sub_name: sub_categories[index].name,
                                          isTest: widget.isTest)
                                      : CourseTest(
                                          id_sub_category:
                                              sub_categories[index].id,
                                          image: sub_categories[index].image,
                                          sub_name: sub_categories[index].name,
                                          isTest: widget.isTest);
                                }));
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: Container(
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 10, left: 5, right: 5),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 10),
                                        child: ExtendedImage.network(
                                          sub_categories[index].image,
                                          width: 80,
                                          fit: BoxFit.fill,
                                          cache: true,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(30.0)),
                                        ),
                                      ),
                                      Text(
                                        sub_categories[index].name,
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF007251)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                    ),
                  ],
                ),
              ),
            )));
  }
}
