import 'package:flutter/material.dart';
import 'package:flutter_app_stulish/helpers/sizes_helpers.dart';
import 'package:flutter_app_stulish/models/user.dart';
import 'package:flutter_app_stulish/pages/friend_list/components/skeleton-friend-list.dart';
import 'package:flutter_app_stulish/pages/profiles/profile-detail.dart';
import 'package:flutter_app_stulish/services/auth.dart';
import 'package:flutter_app_stulish/services/httpservice.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:skeletons/skeletons.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async';

class FriendList extends StatefulWidget {
  const FriendList({Key? key}) : super(key: key);

  @override
  State<FriendList> createState() => _FriendListState();
}

class _FriendListState extends State<FriendList> {
  final HttpService service = new HttpService();
  TextEditingController searchController = new TextEditingController();
  List users = [];
  bool _isLoadingUser = false;
  bool _isLoading = true;
  List _searchResult = [];

  Future getAllUsers() async {
    setState(() {
      _isLoadingUser = true;
    });

    final String uri = dotenv.get('API_URL') + "/api/v1/getAllUsers";
    String? token =
        await Provider.of<AuthProvider>(context, listen: false).getToken();
    http.Response result = await http.get(Uri.parse(uri), headers: {
      'Authorization': 'Bearer $token',
    });

    // final String uri = dotenv.get('API_URL') + "/api/getAllUsers";
    // http.Response result = await http.get(Uri.parse(uri));
    if (result.statusCode == HttpStatus.ok) {
      final jsonResponse = json.decode(result.body);
      List userMap = jsonResponse['data'];
      List user = userMap.map((i) => User.allUser(i)).toList();

      setState(() {
        users = user;
        _isLoadingUser = false;
      });
      _isLoading = false;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    getAllUsers();
    super.initState();
  }

  void _searchUser(String name) {
    _searchResult.clear();
    if (name.isEmpty) {
      setState(() {});
      return;
    }

    users.forEach((item) {
      if (item.name.toLowerCase().contains(name.toLowerCase())) {
        _searchResult.add(item);
      }
    });

    setState(() {});
  }

  AssetImage getBorder(String level) {
    if (level == "Emperor") {
      return AssetImage("assets/images/1-emperor.png");
    } else if (level == "King") {
      return AssetImage("assets/images/2-king.png");
    } else if (level == "Duke") {
      return AssetImage("assets/images/3-duke.png");
    } else if (level == "Prince") {
      return AssetImage("assets/images/4-prince.png");
    } else if (level == "Knight") {
      return AssetImage("assets/images/5-knight.png");
    } else {
      return AssetImage("assets/images/6-citizen.png");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (users.length == 0 && _searchResult.length == 0) {
      return Center(child: CircularProgressIndicator());
    } else {
      return Scaffold(
        backgroundColor: Color(0xFFF1F1F1),
        body: Column(
          children: [
            Container(
              color: Colors.white,
              margin: EdgeInsets.only(top: 15, bottom: 5),
              child: TextFormField(
                controller: searchController,
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: 'Cari',
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 1.0, horizontal: 1.0),
                  hintStyle: TextStyle(
                    fontWeight: FontWeight.w400,
                  ),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.close, color: Colors.black),
                          onPressed: () {
                            searchController.clear();
                            _searchUser('');
                          },
                        )
                      : null,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Image.asset(
                      'assets/images/search.png',
                      width: 20,
                      height: 20,
                      fit: BoxFit.fill,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(width: 2, color: Color(0xFFF5A720)),
                    borderRadius: BorderRadius.circular(6.0),
                    // borderSide: ,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(width: 3, color: Color(0xFFF5A720)),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                ),
                onChanged: (value) => _searchUser(value),
              ),
            ),
            Expanded(
              child: _searchResult.length != 0 ||
                      searchController.text.isNotEmpty
                  ? ListView.builder(
                      // physics: NeverScrollableScrollPhysics(),
                      itemCount: _searchResult.length,
                      itemBuilder: (context, int index) {
                        if (_searchResult[index].photo == null) {
                          _searchResult[index].photo =
                              "assets/images/user_icon_big.png";
                        }
                        return Builder(
                          builder: (context) {
                            return InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (BuildContext context) {
                                  return ProfileDetail(
                                      user: _searchResult[index]);
                                }));
                              },
                              child: Padding(
                                padding: EdgeInsets.only(
                                    // top: displayHeight(context) * 0.01,
                                    bottom: displayHeight(context) * 0.02),
                                child: Container(
                                  padding: EdgeInsets.only(
                                      left: displayWidth(context) * 0.04),
                                  width: displayWidth(context) * 1,
                                  height: displayHeight(context) * 0.1,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.transparent,
                                        maxRadius: displayWidth(context) * 0.09,
                                        backgroundImage: getBorder(
                                            _searchResult[index].level),
                                        child: CircleAvatar(
                                          backgroundColor: Colors.transparent,
                                          maxRadius:
                                              displayWidth(context) * 0.052,
                                          backgroundImage: AssetImage(
                                              _searchResult[index].photo),
                                        ),
                                      ),

                                      // Image.asset(
                                      //   "assets/images/user_icon.png",
                                      //   width: displayWidth(context) * 0.12,
                                      //   // height: displayHeight(context) * 0.05,
                                      //   fit: BoxFit.fill,
                                      // ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: displayWidth(context) * 0.03,
                                        ),
                                        child: Container(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(_searchResult[index].name,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    top:
                                                        displayHeight(context) *
                                                            0.01),
                                                child: Text(users[index].level,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.normal)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    )
                  : ListView.builder(
                      // physics: NeverScrollableScrollPhysics(),
                      itemCount: users.length,
                      itemBuilder: (context, int index) {
                        return Builder(
                          builder: (context) {
                            if (users[index].photo == null) {
                              users[index].photo =
                                  "assets/images/user_icon_big.png";
                            }
                            return InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (BuildContext context) {
                                  return ProfileDetail(user: users[index]);
                                }));
                              },
                              child: Padding(
                                padding: EdgeInsets.only(
                                    // top: displayHeight(context) * 0.01,
                                    bottom: displayHeight(context) * 0.02),
                                child: Container(
                                  padding: EdgeInsets.only(
                                      left: displayWidth(context) * 0.05),
                                  width: displayWidth(context) * 1,
                                  height: displayHeight(context) * 0.1,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.transparent,
                                        maxRadius: displayWidth(context) * 0.09,
                                        backgroundImage:
                                            getBorder(users[index].level),
                                        child: CircleAvatar(
                                          backgroundColor: Colors.transparent,
                                          maxRadius:
                                              displayWidth(context) * 0.052,
                                          backgroundImage:
                                              AssetImage(users[index].photo),
                                        ),
                                      ),
                                      // CircleAvatar(
                                      //   maxRadius:
                                      //       displayWidth(context) * 0.072,
                                      //   backgroundImage:
                                      //       AssetImage(users[index].photo),
                                      // ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: displayWidth(context) * 0.03,
                                        ),
                                        child: Container(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(users[index].name,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    top:
                                                        displayHeight(context) *
                                                            0.01),
                                                child: Text(users[index].level,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.normal)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            )
          ],
        ),
      );
    }
  }
}
