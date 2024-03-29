import 'dart:convert';

import 'package:bim493_finalhw/Authentication/signin_screen.dart';
import 'package:bim493_finalhw/main.dart';
import 'package:bim493_finalhw/pages/add_course.dart';
import 'package:bim493_finalhw/pages/grade_details.dart';
import 'package:bim493_finalhw/widgets/error_dialog.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../model/course.dart';

class Courses extends StatefulWidget {
  const Courses({
    Key? key,
  }) : super(key: key);

  @override
  State<Courses> createState() => _CoursesState();
}

class _CoursesState extends State<Courses> {
  final List<Course> allCourses = [];
  void getCourses() async {
    final prefs = await SharedPreferences.getInstance();
    String? coursesJson = prefs.getString('courses');
    if (coursesJson != null) {
      List coursesList = jsonDecode(coursesJson);

      for (var course in coursesList) {
        setState(() {
          allCourses.add(Course.fromJson(course));
        });
      }
    }
  }

  double calculateAverage() {
    double gradeSum = 0;
    double creditSum = 0;
    allCourses.forEach((element) {
      gradeSum = gradeSum + (element.credit * element.letter);
      creditSum = creditSum + element.credit;
    });
    setState(() {});
    return (gradeSum / creditSum);
  }

  void removeCourse(Course course) {
    allCourses.remove(course);
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCourses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: SpeedDial(
        animationCurve: Curves.bounceInOut,
        childMargin: const EdgeInsets.symmetric(vertical: 20),
        animatedIcon: AnimatedIcons.view_list,
        backgroundColor: Constants.anaRenk,
        children: [
          SpeedDialChild(
              child: const Icon(Icons.add),
              backgroundColor: Colors.green,
              label: 'Ders Ekle',
              onTap: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (c) => const AddCourse()));
              }),
          SpeedDialChild(
              child: const Icon(Icons.remove_red_eye_outlined),
              backgroundColor: Colors.purple,
              label: 'Dersleri gör',
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (c) => const Courses()));
              }),
          SpeedDialChild(
              child: const Icon(Icons.logout),
              backgroundColor: Colors.grey,
              label: 'Çıkış Yap',
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (c) => const SignInScreen()));
              }),
        ],
      ),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          title: Center(
            child: Text("DERSLER",
                style: GoogleFonts.raleway(
                  textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w400),
                )),
          )),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
              child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Color.fromRGBO(33, 217, 233, 1),
                    Colors.white
                  ]),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(
                  flex: 2,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(('Genel Not'),
                            style: GoogleFonts.montserrat(
                              textStyle: const TextStyle(
                                  color: Color.fromRGBO(48, 64, 98, 1),
                                  fontSize: 25,
                                  fontWeight: FontWeight.w700),
                            )),
                        Text(
                            'Ortalaması : ${calculateAverage() == 0 ? 0 : (calculateAverage().toStringAsFixed(2))}',
                            style: GoogleFonts.montserrat(
                              textStyle: const TextStyle(
                                  color: Color.fromRGBO(48, 64, 98, 1),
                                  fontSize: 25,
                                  fontWeight: FontWeight.w700),
                            ))
                      ],
                    ),
                  ),
                )
              ],
            ),
          )),
          Expanded(
            flex: 3,
            child: allCourses.isNotEmpty
                ? ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: allCourses.length,
                    itemBuilder: ((context, index) => CourseCard(
                          course: allCourses[index],
                          allCourses: allCourses,
                          calculateAverage: calculateAverage,
                          removeCourse: removeCourse,
                        )))
                : Container(
                    margin: const EdgeInsets.all(24),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(('Lutfen ders ekleyiniz'),
                              style: Theme.of(context)
                                  .textTheme
                                  .headline5!
                                  .copyWith(color: Constants.anaRenk)),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class PlatformAlert {
  final String title;
  final String message;

  PlatformAlert(this.title, this.message);

  void show(BuildContext context) {
    final platform = Theme.of(context).platform;

    if (platform == TargetPlatform.iOS) {
      _buildCupertinoAlert(context);
    } else {
      _buildMaterialAlert(context);
    }
  }

  void _buildMaterialAlert(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Evet')),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Hayır'))
            ],
          );
        });
  }

  void _buildCupertinoAlert(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Evet')),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Hayır'))
            ],
          );
        });
  }
}

class CourseCard extends StatefulWidget {
  final Course course;
  final List<Course> allCourses;
  final void Function() calculateAverage;
  final void Function(Course course) removeCourse;
  const CourseCard({
    Key? key,
    required this.course,
    required this.allCourses,
    required this.calculateAverage,
    required this.removeCourse,
  }) : super(key: key);

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  Future<void> saveCourses() async {
    final prefs = await SharedPreferences.getInstance();
    List courses = widget.allCourses.map((e) => e.toJson()).toList();
    prefs.setString("courses", jsonEncode(courses));
  }

  void show(BuildContext context) {
    final platform = Theme.of(context).platform;

    if (platform == TargetPlatform.iOS) {
      _buildCupertinoAlert(context);
    } else {
      _buildMaterialAlert(context);
    }
  }

  void _buildMaterialAlert(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Dersi silinecektir!'),
            content: Text('Dersi silmek istediğinize emin misiniz?'),
            actions: [
              TextButton(
                  onPressed: () {
                    widget.removeCourse(widget.course);
                    saveCourses();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Evet')),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Hayır'))
            ],
          );
        });
  }

  void _buildCupertinoAlert(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text('Dersi silinecektir!'),
            content: Text('Dersi silmek istediğinize emin misiniz?'),
            actions: [
              TextButton(
                  onPressed: () {
                    widget.removeCourse(widget.course);
                    saveCourses();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Evet')),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Hayır'))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        show(context);
      },
      onTap: () {
        Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => GradeDetails(course: widget.course)))
            .then((value) {
          saveCourses();
          widget.calculateAverage();
          setState(() {});
        });
      },
      child: Padding(
        padding: const EdgeInsets.only(
          left: 10,
          right: 10,
          top: 10,
        ),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Constants.anaRenk.withOpacity(0.6),
                blurRadius: 5,
                spreadRadius: 2,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(widget.course.name,
                        style: GoogleFonts.montserrat(
                          textStyle: const TextStyle(
                              color: Color.fromRGBO(48, 64, 98, 1),
                              fontSize: 15,
                              fontWeight: FontWeight.w600),
                        )),
                    widget.course.gradeAverage != 0
                        ? (Text(widget.course.gradeAverage.toStringAsFixed(2),
                            style: GoogleFonts.montserrat(
                              textStyle: const TextStyle(
                                  color: Color.fromRGBO(48, 64, 98, 1),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700),
                            )))
                        : const Text("")
                  ],
                ),
                Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: widget.course.gradeAverage != 0
                        ? (Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(10)),
                            height: 10,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                backgroundColor: Colors.white,
                                color: const Color.fromRGBO(33, 217, 233, 1),
                                value: widget.course.gradeAverage / 100,
                              ),
                            ),
                          ))
                        : null),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: widget.course.contents
                          .map((e) => Column(
                                children: [
                                  Stack(alignment: Alignment.center, children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(18),
                                      child: CircularProgressIndicator(
                                        color: const Color.fromRGBO(
                                            33, 217, 233, 1),
                                        value: e.grade / 100,
                                      ),
                                    ),
                                    Center(
                                        child: Text(
                                      e.grade.round().toString(),
                                      style: GoogleFonts.montserrat(
                                        textStyle: const TextStyle(
                                            color:
                                                Color.fromRGBO(48, 64, 98, 1),
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ))
                                  ]),
                                  Padding(
                                      padding: const EdgeInsets.only(top: 5),
                                      child: Text(
                                        e.name,
                                        style: GoogleFonts.montserrat(
                                          textStyle: const TextStyle(
                                              color:
                                                  Color.fromRGBO(48, 64, 98, 1),
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ))
                                ],
                              ))
                          .toList()),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
