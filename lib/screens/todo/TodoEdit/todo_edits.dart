import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';

class TodoEdits extends StatefulWidget {
  const TodoEdits({Key? key}) : super(key: key);

  @override
  _TodoEditsState createState() => _TodoEditsState();
}

class _TodoEditsState extends State<TodoEdits> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _commentController = TextEditingController();
  TextEditingController _subtaskController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  String _dateButton = "Choose Deadline";
  bool _buttonActive = false;
  DateTime? _dateTime;

  addData() async {
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random _rnd = Random.secure();

    String id = String.fromCharCodes(Iterable.generate(
        20, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("todo")
        .doc(id)
        .set({
      "id": id,
      "title": _titleController.text,
      "isdone": false,
      "isdead": _buttonActive,
      "deadline": _buttonActive ? _dateButton : null,
      "isfav": false,
      "numcom": _commentController.text == "" ? "0" : "1",
      "numsub": _subtaskController.text == "" ? "0" : "1",
    });
    if (_commentController.text != "") {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("todo")
          .doc(id)
          .collection("comment")
          .doc(id)
          .set({
        "comment": _commentController.text,
        "no": "1",
      });
    }

    if (_subtaskController.text != "") {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("todo")
          .doc(id)
          .collection("subtask")
          .doc(id)
          .set({
        "subtask": _subtaskController.text,
        "no": "1",
      });
    }
    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("stats")
        .doc("todono")
        .get()
        .then((value) async {
      if (value.exists) {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection("stats")
            .doc("todono")
            .update({
          "todono": FieldValue.increment(1),
        });
      } else {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection("stats")
            .doc("todono")
            .set({"todono": 1});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white10,
          leading: IconButton(
              splashRadius: 10,
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Tooltip(
                message: "Exit Without Saving",
                child: Icon(
                  Icons.cancel,
                  color: Colors.black,
                  size: 23,
                ),
              )),
        ),
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: screenWidth * .07, bottom: screenWidth * .055),
                    child: Text(
                      "Add Task",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * .0833),
                    ),
                  ),
                ),
                Container(
                  width: screenWidth * .85,
                  height: screenWidth * .06 * 6,
                  decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white10,
                      border: Border.all(color: Colors.white, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.1),
                          blurRadius: 100,
                          spreadRadius: 2,
                          offset: Offset(0, 3),
                        ),
                      ]
                      //borderRadius: BorderRadius.circular(10),
                      ),
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        child: Container(
                          height: 10,
                          width: 10,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: Colors.white),
                        ),
                      ),
                      Container(
                        width: screenWidth * .75,
                        height: 100,
                        child: TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (String? value) {
                            return value == null || value.trim().isEmpty
                                ? "Todo should not be empty"
                                : null;
                          },
                          controller: _titleController,
                          maxLines: 3,
                          autofocus: true,
                          style: TextStyle(
                              color: Colors.black.withOpacity(.7),
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * .055),
                          decoration: InputDecoration(
                            hintText: "Todo",
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.red, width: 2),
                            ),
                            disabledBorder: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: screenHeight * .0263,
                ),
                Padding(
                  padding: EdgeInsets.only(
                      left: screenWidth * .07, right: screenWidth * .07),
                  child: Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white10,
                        border: Border.all(color: Colors.white, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.1),
                            blurRadius: 100,
                            spreadRadius: 2,
                            offset: Offset(0, 3),
                          ),
                        ]
                        //borderRadius: BorderRadius.circular(10),
                        ),
                    width: screenWidth,
                    height: screenWidth * .0416 * 5,
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: screenWidth * .07,
                          right: screenWidth * .0416,
                          top: screenHeight * .0105,
                          bottom: screenHeight * .0105),
                      child: Align(
                          alignment: Alignment.center,
                          child: TextFormField(
                            maxLines: 1,
                            controller: _subtaskController,
                            style: TextStyle(
                              fontSize: screenWidth * .047,
                              color: Colors.black.withOpacity(.6),
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              hintText: "Sub Task 1",
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                            ),
                          )),
                    ),
                  ),
                ),
                SizedBox(
                  height: screenHeight * .0263,
                ),
                Padding(
                  padding: EdgeInsets.only(
                      left: screenWidth * .07, right: screenWidth * .07),
                  child: Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white10,
                        border: Border.all(color: Colors.white, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.1),
                            blurRadius: 100,
                            spreadRadius: 2,
                            offset: Offset(0, 3),
                          ),
                        ]
                        //borderRadius: BorderRadius.circular(10),
                        ),
                    width: screenWidth,
                    height: screenWidth * .0416 * 7,
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: screenWidth * .07,
                          right: screenWidth * .0416,
                          top: screenHeight * .0105,
                          bottom: screenHeight * .0105),
                      child: Align(
                          alignment: Alignment.topLeft,
                          child: TextFormField(
                            maxLines: 10,
                            controller: _commentController,
                            style: TextStyle(
                                fontSize: screenWidth * .04,
                                color: Colors.black.withOpacity(.5)),
                            decoration: InputDecoration(
                              hintText: "# Comments",
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                            ),
                          )),
                    ),
                  ),
                ),
                SizedBox(
                  height: screenHeight * .0263,
                ),
                Padding(
                  padding: EdgeInsets.only(
                      left: screenWidth * .07, right: screenWidth * .07),
                  child: Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white10,
                        border: Border.all(color: Colors.white, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.1),
                            blurRadius: 100,
                            spreadRadius: 2,
                            offset: Offset(0, 3),
                          ),
                        ]
                        //borderRadius: BorderRadius.circular(10),
                        ),
                    width: screenWidth,
                    height: screenWidth * .0416 * 8,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Does this task have a deadline?"),
                              Transform.scale(
                                scale: .6,
                                child: CupertinoSwitch(
                                  value: _buttonActive,
                                  onChanged: (bool value) {
                                    setState(() {
                                      _buttonActive = !_buttonActive;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: screenWidth * .7,
                            child: ElevatedButton(
                              onPressed: () {
                                DatePicker.showDateTimePicker(
                                  context,
                                  onConfirm: (dateTime) {
                                    setState(() {
                                      _dateTime = dateTime;
                                      _dateButton = DateFormat.yMEd()
                                          .add_jms()
                                          .format(_dateTime!);
                                    });
                                  },
                                  minTime: DateTime.now(),
                                  theme: DatePickerTheme(
                                    cancelStyle: TextStyle(
                                        fontFamily: 'Poppins',
                                        color: Colors.red),
                                    doneStyle:
                                        TextStyle(color: Colors.grey[800]),
                                  ),
                                );
                              },
                              child: _buttonActive
                                  ? Text(
                                      _dateButton,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : Text(
                                      "No Deadline",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                              style: ButtonStyle(
                                backgroundColor: _buttonActive
                                    ? MaterialStateProperty.all(Colors.black)
                                    : MaterialStateProperty.all(
                                        Colors.transparent),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: screenHeight * .08,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                        height: screenHeight * 0.0526 < 40
                            ? 40
                            : screenHeight * 0.0526,
                        width: screenWidth * .4,
                        child: ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.white),
                              elevation: MaterialStateProperty.all(0),
                              side: MaterialStateProperty.all(
                                  BorderSide(width: 1, color: Colors.red)),
                              overlayColor: MaterialStateProperty.all(
                                  Colors.redAccent.withOpacity(.5))),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        )),
                    Container(
                        height: screenHeight * 0.0526 < 40
                            ? 40
                            : screenHeight * 0.0526,
                        width: screenWidth * .4,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.black),
                            //elevation: MaterialStateProperty.all(0),
                            //shape: MaterialStateProperty.all(),
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              if (_buttonActive == true &&
                                  _dateButton == "Choose Deadline") {
                                showModalBottomSheet(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Container(
                                        width: screenWidth,
                                        height: 200,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              height: 30,
                                            ),
                                            Align(
                                                child: Container(
                                              child: IconButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  icon: Icon(
                                                    Icons.close,
                                                    size: 15,
                                                  )),
                                            )),
                                            SizedBox(
                                              height: 30,
                                            ),
                                            Text(
                                              "Deadline is required!",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    });
                              } else {
                                addData();
                                Navigator.pop(context);
                              }
                            }
                          },
                          child: Text(
                            "Save Task",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        )),
                  ],
                ),
                SizedBox(
                  height: screenHeight * .1,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
