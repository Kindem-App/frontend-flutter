import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_stulish/helpers/sizes_helpers.dart';
import 'package:flutter_app_stulish/models/user.dart';
import 'package:flutter_app_stulish/pages/login/login-main.dart';
import 'package:flutter_app_stulish/pages/profiles/change-avatar.dart';
import 'package:flutter_app_stulish/services/auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class ProfileSetting extends StatefulWidget {
  const ProfileSetting({Key? key}) : super(key: key);
  @override
  _ProfileSettingState createState() => _ProfileSettingState();
}

class _ProfileSettingState extends State<ProfileSetting> {
  PageController pageController = new PageController();

  TextEditingController usernameController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  TextEditingController confirmPasswordController = new TextEditingController();
  String _errorMessage = "";
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();

  User user = new User();

  @override
  void initState() {
    super.initState();
    pageController = PageController(viewportFraction: 6.0);
    getUser();
  }

  void getUser() async {
    final String uri = dotenv.get('API_URL') + "/api/v1/user";
    String? token =
        await Provider.of<AuthProvider>(context, listen: false).getToken();
    http.Response result = await http.get(Uri.parse(uri), headers: {
      'Authorization': 'Bearer $token',
    });
    if (result.statusCode == HttpStatus.ok) {
      final jsonResponse = json.decode(result.body);
      var users = User.toString(jsonResponse);
      setState(() {
        user = users;
      });
    }
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

  Future updateName(String name) async {
    final String uri = dotenv.get('API_URL') + "/api/v1/updateProfile";
    String? token =
        await Provider.of<AuthProvider>(context, listen: false).getToken();
    http.Response result = await http.post(Uri.parse(uri), headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    }, body: {
      'name': name,
    });
    if (result.statusCode == HttpStatus.ok) {
      setState(() {
        getUser();
      });
    }
  }

  bool _isPasswordValid = false;
  void changePasswordValidation(String password, String confirmPassword) {
    setState(() {
      if (password != confirmPassword ||
          password.isEmpty ||
          confirmPassword.isEmpty) {
        _isPasswordValid = false;
        // _errorMessage = "tes";
      } else {
        _isPasswordValid = true;
      }
    });
  }

  Future updatePassword(String password) async {
    final String uri = dotenv.get('API_URL') + "/api/v1/updateProfile";
    String? token =
        await Provider.of<AuthProvider>(context, listen: false).getToken();
    http.Response result = await http.post(Uri.parse(uri), headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    }, body: {
      'password': password,
    });
    if (result.statusCode == HttpStatus.ok) {
      setState(() {
        getUser();
      });
    }
  }

  Widget build(BuildContext context) {
    usernameController.text = user.name;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/images/bg-rounded.png"),
                  fit: BoxFit.cover)),
          child: Center(
            child: SingleChildScrollView(
              // physics: NeverScrollableScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 30),
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 55),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.transparent,
                            maxRadius: displayWidth(context) * 0.122,
                            backgroundImage: getBorder(user.level),
                            child: CircleAvatar(
                              backgroundColor: Colors.transparent,
                              maxRadius: displayHeight(context) * 0.04,
                              backgroundImage: user.photo == null
                                  ? AssetImage(
                                      "assets/images/user_icon_big.png")
                                  : AssetImage(user.photo.toString()),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.only(left: 5),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.name,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 25.0,
                                      ),
                                    ),
                                    Text(
                                      "CITIZEN/RAKYAT BIASA (LVL1)",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15.0,
                                      ),
                                    ),
                                  ]),
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 15.0),
                      width: displayWidth(context) * 40,
                      height: displayHeight(context) * 0.67,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              offset: Offset(0, 9),
                              blurRadius: 10,
                              spreadRadius: 1),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: 18.0,
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: displayHeight(context) * 0.033),
                          // color: Colors.red,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ResultDetail(),
                              // Container(
                              //   child: ResultDetail(),
                              // ),

                              Container(
                                margin: EdgeInsets.only(top: 27),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: Colors.grey[400],
                                ),
                                child: TextFormField(
                                  // controller: ,
                                  obscureText: true,
                                  enabled: false,
                                  decoration: InputDecoration(
                                    hintText: '123456789',
                                    hintStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 1.0, horizontal: 1.0),
                                    prefixIcon: Icon(Icons.person_outline,
                                        color: Colors.black),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      // borderSide: ,
                                    ),
                                  ),
                                ),
                              ),

                              Container(
                                margin: EdgeInsets.only(
                                    top: displayHeight(context) * 0.015),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Color(0xFFF5A720),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: TextFormField(
                                  // controller: ,
                                  controller: usernameController,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500),

                                  decoration: InputDecoration(
                                    hintText: 'Nama User',
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 1.0, horizontal: 1.0),
                                    hintStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    prefixIcon: Icon(Icons.text_fields,
                                        color: Colors.black),
                                    suffixIcon: Container(
                                        color: Color(0xFFF5A720),
                                        child: IconButton(
                                          icon: Icon(Icons.edit,
                                              color: Colors.white),
                                          onPressed: () async {
                                            print(usernameController.text);
                                            await updateName(
                                                usernameController.text);

                                            MotionToast(
                                                    icon: Icons
                                                        .check_circle_outline_outlined,
                                                    primaryColor:
                                                        Color(0xFFBBDDFB),
                                                    height:
                                                        displayHeight(context) *
                                                            0.07,
                                                    width:
                                                        displayWidth(context) *
                                                            0.8,
                                                    description: Text(
                                                        "Nama berhasil diubah"))
                                                .show(context);
                                          },
                                        )),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          width: 1, color: Color(0xFFF5A720)),
                                      borderRadius: BorderRadius.circular(6.0),
                                      // borderSide: ,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          width: 1, color: Color(0xFFF5A720)),
                                      borderRadius: BorderRadius.circular(6.0),
                                    ),
                                  ),
                                ),
                              ),
                              // Padding(
                              //   padding: EdgeInsets.fromLTRB(
                              //       0.0,
                              //       displayHeight(context) * 0.02,
                              //       0.0,
                              //       displayHeight(context) * 0.001),
                              //   child: Text(
                              //     _errorMessage,
                              //     style: TextStyle(color: Colors.red),
                              //   ),
                              // ),
                              //button
                              Container(
                                margin: EdgeInsets.only(
                                    top: displayHeight(context) * 0.03),
                                child: Button(context),
                              ),

                              //button logout
                              Container(
                                margin: EdgeInsets.only(
                                    top: displayHeight(context) * 0.03),
                                child: Center(
                                  child: BouncingWidget(
                                      duration: Duration(milliseconds: 90),
                                      scaleFactor: 2.0,
                                      child: Container(
                                        width: displayWidth(context) * 0.26,
                                        padding: EdgeInsets.symmetric(
                                            vertical:
                                                displayHeight(context) * 0.02),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.20),
                                                offset: Offset(2, 6),
                                                blurRadius: 7,
                                                spreadRadius: 2),
                                          ],
                                        ),
                                        child: Text(
                                          "LOGOUT",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text(
                                                  "Kamu yakin ingin Logout ?"),
                                              actions: [
                                                //BUTTON "Yes"
                                                MaterialButton(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: Text(
                                                    "YA",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  onPressed: () async {
                                                    await Provider.of<
                                                                AuthProvider>(
                                                            context,
                                                            listen: false)
                                                        .logout()
                                                        .then((value) => Navigator
                                                                .of(context)
                                                            .pushAndRemoveUntil(
                                                                PageRouteBuilder(
                                                                  transitionDuration:
                                                                      Duration(
                                                                          milliseconds:
                                                                              500),
                                                                  pageBuilder: (BuildContext context,
                                                                      Animation<
                                                                              double>
                                                                          animation,
                                                                      Animation<
                                                                              double>
                                                                          secondaryAnimation) {
                                                                    return LoginMain();
                                                                  },
                                                                  transitionsBuilder: (BuildContext context,
                                                                      Animation<
                                                                              double>
                                                                          animation,
                                                                      Animation<
                                                                              double>
                                                                          secondaryAnimation,
                                                                      Widget
                                                                          child) {
                                                                    return Align(
                                                                      child:
                                                                          FadeTransition(
                                                                        opacity:
                                                                            animation,
                                                                        child:
                                                                            child,
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                                (route) =>
                                                                    false));
                                                  },
                                                  color: Colors.red,
                                                ),

                                                //BUTTON "Cancel"
                                                MaterialButton(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: Text(
                                                    "Batal",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  color: Color(0xFFF5A720),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget ResultDetail() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: displayWidth(context) * 0.35,
          height: displayHeight(context) * 0.19,
          padding: EdgeInsets.symmetric(
              horizontal: displayWidth(context) * 0.04,
              vertical: displayHeight(context) * 0.01),
          decoration: BoxDecoration(
            color: Color(0xFFF5A720),
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.09),
                  offset: Offset(0, 9),
                  blurRadius: 8,
                  spreadRadius: 1),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                user.complete_sub_category.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 36.2,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: displayHeight(context) * 0.015),
                child: Text(
                  "Materi yang diselesaikan",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    // fontWeight: FontWeight.bold,
                    // fontSize: 36.4,
                  ),
                ),
              ),
            ],
          ),
          // Text("25"),
        ),
        Container(
          width: displayWidth(context) * 0.35,
          height: displayHeight(context) * 0.19,
          padding: EdgeInsets.symmetric(
              horizontal: displayWidth(context) * 0.04,
              vertical: displayHeight(context) * 0.01),
          decoration: BoxDecoration(
            color: Color(0xFFF5A720),
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.09),
                  offset: Offset(0, 9),
                  blurRadius: 8,
                  spreadRadius: 1),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                user.point.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 36.2,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: displayHeight(context) * 0.015),
                child: Text(
                  "Exp yang didapatkan",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    // fontWeight: FontWeight.bold,
                    // fontSize: 36.4,
                  ),
                ),
              ),
            ],
          ),
          // Text("25"),
        ),
      ],
    );
  }

  Widget Button(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        BouncingWidget(
          duration: Duration(milliseconds: 90),
          scaleFactor: 2.0,
          onPressed: () {
            BuildContext dialogContext;
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  dialogContext = context;
                  return Dialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0)),
                    child: Container(
                      constraints: BoxConstraints(
                          maxHeight: displayHeight(context) * 0.4),
                      child: Form(
                        key: _formKey,
                        // autovalidate: true,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: displayWidth(context) * 0.06),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                margin: EdgeInsets.only(bottom: 22),
                                child: Text(
                                  "Ubah Password",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 20),
                                ),
                              ),
                              Container(
                                child: TextFormField(
                                  controller: passwordController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    hintText: 'Password Baru',
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 1.0, horizontal: 10.0),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          width: 2, color: Color(0xFFF5A720)),
                                      borderRadius: BorderRadius.circular(6.0),
                                      // borderSide: ,
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          width: 3, color: Color(0xFFF5A720)),
                                      borderRadius: BorderRadius.circular(6.0),
                                      // borderSide: ,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          width: 2, color: Color(0xFFF5A720)),
                                      borderRadius: BorderRadius.circular(6.0),
                                      // borderSide: ,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          width: 3, color: Color(0xFFF5A720)),
                                      borderRadius: BorderRadius.circular(6.0),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Password tidak boleh kosong';
                                    } else if (value.length < 8) {
                                      return 'Password harus berisi min. 8 karakter';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 20),
                                child: TextFormField(
                                  controller: confirmPasswordController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    // labelText: 'Konfirmasi Password Baru',
                                    hintText: 'Konfirmasi Ulang Password Baru',
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 1.0, horizontal: 10.0),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          width: 2, color: Color(0xFFF5A720)),
                                      borderRadius: BorderRadius.circular(6.0),
                                      // borderSide: ,
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          width: 3, color: Color(0xFFF5A720)),
                                      borderRadius: BorderRadius.circular(6.0),
                                      // borderSide: ,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          width: 2, color: Color(0xFFF5A720)),
                                      borderRadius: BorderRadius.circular(6.0),
                                      // borderSide: ,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          width: 3, color: Color(0xFFF5A720)),
                                      borderRadius: BorderRadius.circular(6.0),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Konfirmasi password tidak boleh kosong';
                                    } else if (value !=
                                        passwordController.text) {
                                      return 'Konfirmasi password tidak sesuai';
                                    } else if (value.length < 8) {
                                      return 'Password harus berisi min. 8 karakter';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              BouncingWidget(
                                duration: Duration(milliseconds: 90),
                                scaleFactor: 2.0,
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    updatePassword(passwordController.text);
                                    Navigator.pop(context);
                                    MotionToast(
                                            icon: Icons
                                                .check_circle_outline_outlined,
                                            primaryColor: Color(0xFFBBDDFB),
                                            height:
                                                displayHeight(context) * 0.07,
                                            width: displayWidth(context) * 0.8,
                                            description: Text(
                                                "Password berhasil diubah"))
                                        .show(context);
                                  }

                                  // bool result
                                },
                                child: Container(
                                  margin: EdgeInsets.only(top: 30),
                                  width: displayWidth(context) * 0.33,
                                  padding: EdgeInsets.symmetric(
                                      vertical: displayHeight(context) * 0.02),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFF5A720),
                                    borderRadius: BorderRadius.circular(15.0),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black.withOpacity(0.20),
                                          offset: Offset(2, 6),
                                          blurRadius: 7,
                                          spreadRadius: 2),
                                    ],
                                  ),
                                  child: Text(
                                    "UBAH",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                });
          },
          child: Container(
            width: displayWidth(context) * 0.35,
            padding:
                EdgeInsets.symmetric(vertical: displayHeight(context) * 0.02),
            decoration: BoxDecoration(
              color: Color(0xFFF5A720),
              borderRadius: BorderRadius.circular(15.0),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.20),
                    offset: Offset(2, 6),
                    blurRadius: 7,
                    spreadRadius: 2),
              ],
            ),
            child: Text(
              "UBAH PASSWORD",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        BouncingWidget(
          duration: Duration(milliseconds: 90),
          scaleFactor: 2.0,
          onPressed: () {
            Navigator.push(context,
                    MaterialPageRoute(builder: (context) => new ChangeAvatar()))
                .then((_) {
              getUser();
            });
          },
          child: Container(
            width: displayWidth(context) * 0.35,
            // margin: EdgeInsets.symmetric(horizontal: 6),
            padding:
                EdgeInsets.symmetric(vertical: displayHeight(context) * 0.02),
            decoration: BoxDecoration(
              color: Color(0xFFF5A720),
              borderRadius: BorderRadius.circular(15.0),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.20),
                    offset: Offset(2, 6),
                    blurRadius: 7,
                    spreadRadius: 2),
              ],
            ),
            child: Text(
              "GANTI FOTO",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
