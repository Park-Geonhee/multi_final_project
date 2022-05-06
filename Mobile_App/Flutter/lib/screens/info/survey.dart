import 'package:conditional_questions/conditional_questions.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class surveyScreen extends StatefulWidget {
  surveyScreen({Key? key}) : super(key: key);

  @override
  _surveyScreenState createState() => _surveyScreenState();
}

class _surveyScreenState extends State<surveyScreen> {
  final _key = GlobalKey<QuestionFormState>();
  final user = FirebaseAuth.instance.currentUser;
  late final _firestream;

  @override
  void initState() {
    super.initState();
    _firestream =
        FirebaseFirestore.instance.collection('survey').doc(user!.uid).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
        elevation: 0,
        centerTitle: true,
        title: Text('설문조사', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _firestream,
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());
          return ConditionalQuestions(
            key: _key,
            children: questions(),
            trailing: [
              MaterialButton(
                color: Colors.blue,
                splashColor: Colors.blue,
                onPressed: () async {
                  if (_key.currentState!.validate()) {
                    print("validated!");
                    FirebaseFirestore.instance
                        .collection('survey')
                        .doc(user!.uid) // userid로 변경
                        .set(_key.currentState!.toMap());
                    showDialog(
                        context: context,
                        builder: (context) {
                          return Container(
                            height: 100,
                            child: AlertDialog(
                                content: new Text(
                                  "설문이 제출되었습니다.",
                                  style: TextStyle(fontSize: 14),
                                ),
                                actions: <Widget>[
                                  new FlatButton(
                                      child: new Text("Close", style: TextStyle(color: Colors.blue),),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      }),
                                ]),
                          );
                        });
                  }
                },
                child: Text(
                  "Submit",
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

List<Question> questions() {
  return [
    PolarQuestion(
        question: "샴푸 후 얼마 지나지 않아 당기고 가렵거나 따갑다.",
        answers: ['그렇지 않다', '조금 그렇다', '그렇다', '매우 그렇다'],
        isMandatory: true),
    PolarQuestion(
        question: "머리를 하루만 감지 않아도 기름이 진다.",
        answers: ['그렇지 않다', '조금 그렇다', '그렇다', '매우 그렇다'],
        isMandatory: true),
    PolarQuestion(
        question: "두피를 긁으면 쉽게 붉어진다.",
        answers: ['그렇지 않다', '조금 그렇다', '그렇다', '매우 그렇다'],
        isMandatory: true),
    PolarQuestion(
        question: "두피에 뾰루지가 난다.",
        answers: ['그렇지 않다', '조금 그렇다', '그렇다', '매우 그렇다'],
        isMandatory: true),
    PolarQuestion(
        question: "머리카락이 요즘들어 많이 빠진다.",
        answers: ['그렇지 않다', '조금 그렇다', '그렇다', '매우 그렇다'],
        isMandatory: true),
    PolarQuestion(
        question: "머리 숱이 적어 진 것 같다.",
        answers: ['그렇지 않다', '조금 그렇다', '그렇다', '매우 그렇다'],
        isMandatory: true)
  ];
}
