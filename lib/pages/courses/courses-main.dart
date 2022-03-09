import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_stulish/helpers/sizes_helpers.dart';
import 'package:flutter_app_stulish/models/course.dart';
import 'package:flutter_app_stulish/pages/components/choach-maker.dart';
import 'package:flutter_app_stulish/pages/courses/courses-test.dart';
import 'package:flutter_app_stulish/services/auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter_tts/flutter_tts.dart';

import 'components/dialog-message.dart';
import 'components/image-course.dart';
import 'components/next-button.dart';
import 'components/prev-button.dart';
import 'components/text-course.dart';
import 'package:coachmaker/coachmaker.dart';

class CoursesMain extends StatefulWidget {
  CoursesMain({Key? key, required this.id_sub_category}) : super(key: key);
  final String id_sub_category;
  @override
  _CoursesMainState createState() => _CoursesMainState();
}

enum TtsState { playing, stopped, paused, continued }

class _CoursesMainState extends State<CoursesMain> {
  List courses = [];
  int indexCourses = 0;

  late FlutterTts flutterTts;
  String? language;
  String? engine;
  double volume = 1.2;
  double pitchIn = 1.54;
  double rateIn = 0.5;
  double pitchEn = 1.2;
  double rateEn = 0.35;

  String? text;
  bool _isComplete = false;
  bool _isPauseIn = false;
  bool _isPauseEn = false;
  bool _isStartPage = false;

  TtsState ttsState = TtsState.stopped;

  get isPlaying => ttsState == TtsState.playing;

  bool get isIOS => !kIsWeb && Platform.isIOS;
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  List<CoachModel> listCoachModel = [];

  late BuildContext myContext;
  @override
  initState() {
    super.initState();
    getCourses();
    initTts();
    initTutorial();
  }

  // Text To Speech

  initTts() {
    flutterTts = FlutterTts();

    if (isAndroid) {
      _getDefaultEngine();
    }

    flutterTts.setStartHandler(() {
      setState(() {
        print("Playing");
        ttsState = TtsState.playing;
      });
    });
  }

  Future _getDefaultEngine() async {
    var engine = "com.google.android.tts";
  }

  Future _speak(String lang) async {
    flutterTts.setLanguage(lang);

    await flutterTts.setVolume(volume);
    if (lang == 'id-ID') {
      if (_isStartPage == false) {
        await flutterTts.setSpeechRate(rateIn);
        await flutterTts.setPitch(pitchIn);
      } else {
        await flutterTts.setSpeechRate(rateIn);
        await flutterTts.setPitch(pitchIn);
        _isPauseIn = true;
      }
    } else {
      await flutterTts.setSpeechRate(rateEn);
      await flutterTts.setPitch(pitchEn);
      _isPauseEn = true;
    }

    await flutterTts.awaitSpeakCompletion(true);
    await flutterTts.speak(text!);
    setState(() {
      _isPauseIn = false;
      _isPauseEn = false;
    });
  }

  // Text To Speech

  initTutorial() {
    initializeCoachModel();
    coachMaker(context, listCoachModel).show();
    text = "Mari belajar dulu dan ikuti petunjuk untuk bermain aplikasi ini";
    _speak("id-ID");
    _isPauseIn = false;
    _isPauseEn = false;
  }

  doTutorialExam() {
    // make coach maker btn_exam
    List<CoachModel> list = [
      CoachModel(
          initial: 'btn_exam',
          title: 'Tombol untuk Berpindah ke Halaman Ujian',
          maxWidth: 400,
          subtitle: [
            '1. Kamu dapat menekan tombol ini untuk berpindah ke halaman ujian',
            '2. Pastikan kamu sudah mempelajari materi sebelumnya ya',
          ],
          header: Image.asset(
            'assets/images/exam.png',
            height: 50,
            width: 50,
          )),
    ];
    coachMaker(context, list).show();
    // make coach maker btn_exam

    // make speaker
    text = "Ketuk tombol ini untuk melakukan ujian";
    _speak("id-ID");
    _isComplete = true;
    // make speaker
  }

  initializeCoachModel() {
    setState(() {
      listCoachModel = [
        CoachModel(
            initial: 'btn_indo',
            title: 'Tombol untuk Bahasa Indonesia',
            maxWidth: 400,
            subtitle: [
              '1. Kamu dapat menekan tombol ini dan akan muncul suara Bahasa Indonesia',
              '2. Tombol ini memudahkan kamu untuk memahami materi yang ditampilkan',
            ],
            header: Image.asset(
              'assets/images/sound.png',
              height: 50,
              width: 50,
            )),
        CoachModel(
            initial: 'btn_en',
            title: 'Tombol untuk Bahasa Inggris',
            maxWidth: 400,
            subtitle: [
              '1. Kamu dapat menekan tombol ini dan akan muncul suara Bahasa Inggris',
              '2. Tombol ini memudahkan kamu untuk memahami materi yang ditampilkan',
            ],
            header: Image.asset(
              'assets/images/sound.png',
              height: 50,
              width: 50,
            )),
        CoachModel(
            initial: 'btn_next',
            title: 'Tombol untuk Berpindah ke Materi Berikutnya',
            maxWidth: 400,
            subtitle: [
              'Kamu dapat menekan tombol ini untuk berpindah ke materi selanjutnya',
            ],
            header: Image.asset(
              'assets/images/next-icon.png',
              height: 50,
              width: 50,
            )),
      ];
    });
  }

  Future getCourses() async {
    final String uri =
        "https://stulish-rest-api.herokuapp.com/api/v1/getCoursesById/" +
            widget.id_sub_category;

    String? token =
        await Provider.of<AuthProvider>(context, listen: false).getToken();
    http.Response result = await http.get(Uri.parse(uri), headers: {
      'Authorization': 'Bearer $token',
    });
    if (result.statusCode == HttpStatus.ok) {
      final jsonResponse = json.decode(result.body);
      List courseMap = jsonResponse['data'];
      List course = courseMap.map((i) => Courses.fromJson(i)).toList();
      setState(() {
        courses = course;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        backgroundColor: Color(0xFFF1F1F1),
        body: Container(
            child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: displayWidth(context) * 0.05,
            vertical: displayHeight(context) * 0.05,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ImageCourse(courses: courses, indexCourses: indexCourses),
              TextCourse(courses: courses, indexCourses: indexCourses),
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        doPrevCourse();
                      },
                      child: indexCourses == 0
                          ? Image(
                              image: AssetImage("assets/images/blank.png"),
                            )
                          : PrevButton(),
                    ),
                    Column(
                      children: [
                        InkWell(
                          onTap: () {
                            speakIndonesia();
                          },
                          child: _isPauseIn == false
                              ? CoachPoint(
                                  initial: 'btn_indo',
                                  child: Image(
                                    width: displayWidth(context) * 0.15,
                                    image:
                                        AssetImage("assets/images/sound.png"),
                                  ),
                                )
                              : Image(
                                  width: displayWidth(context) * 0.15,
                                  image: AssetImage("assets/images/pause.png"),
                                ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: displayHeight(context) * 0.01),
                          child: Image(
                            width: displayWidth(context) * 0.1,
                            image: AssetImage("assets/images/indonesia.png"),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        InkWell(
                          onTap: () {
                            speakEnglish();
                          },
                          child: _isPauseEn == false
                              ? CoachPoint(
                                  initial: 'btn_en',
                                  child: Image(
                                    width: displayWidth(context) * 0.15,
                                    image:
                                        AssetImage("assets/images/sound.png"),
                                  ),
                                )
                              : Image(
                                  width: displayWidth(context) * 0.15,
                                  image: AssetImage("assets/images/pause.png"),
                                ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: displayHeight(context) * 0.01),
                          child: Image(
                            width: displayWidth(context) * 0.1,
                            image: AssetImage("assets/images/english.png"),
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        doNextCourse();
                      },
                      child: indexCourses != courses.length - 1
                          ? CoachPoint(initial: "btn_next", child: NextButton())
                          : CoachPoint(
                              initial: "btn_exam",
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (BuildContext context) {
                                    return CourseTest(
                                      id_sub_category: widget.id_sub_category,
                                    );
                                  }));
                                },
                                child: Image(
                                  width: displayWidth(context) * 0.15,
                                  image: AssetImage("assets/images/exam.png"),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              )
            ],
          ),
        )),
      ),
      onWillPop: () {
        showAlertDialog(context);
        return Future.value(false); // if true allow back else block it
      },
    );
  }

  void speakEnglish() {
    return setState(() {
      if (!_isPauseEn) {
        _isPauseEn = true;
        text =
            courses.length > 0 ? courses[indexCourses].english_text : "Empty";
        _speak("en-US");
      }
    });
  }

  void speakIndonesia() {
    return setState(() {
      if (!_isPauseIn) {
        _isPauseIn = true;
        text =
            courses.length > 0 ? courses[indexCourses].indonesia_text : "Empty";
        _speak("id-ID");
      }
    });
  }

  void doNextCourse() {
    setState(() {
      if (indexCourses < courses.length - 1) {
        indexCourses++;
      }
    });
    if (indexCourses == courses.length - 1 && _isComplete == false) {
      doTutorialExam();
    }
  }

  void doPrevCourse() {
    return setState(() {
      if (indexCourses > 0) {
        indexCourses--;
      }
    });
  }

  showAlertDialog(BuildContext context) {
    showGeneralDialog(
      barrierLabel: "Dialog",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 400),
      context: context,
      pageBuilder: (context, anim1, anim2) {
        return DialogMessage(
          textDialog: "Apakah kamu ingin mengakhiri pembelajaran ini?",
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position:
              Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim1),
          child: child,
        );
      },
    );
  }
}
