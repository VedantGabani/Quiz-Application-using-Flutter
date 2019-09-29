import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quiz_application/LoginPage.dart';
import 'package:quiz_application/mainDashboard.dart';
import 'package:quiz_application/component/rounded_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'result.dart';
import 'dart:math';

final _fireStore = Firestore.instance;
class DashBoard extends StatefulWidget {
  static String id = 'dashboard';
  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {

    Future<bool> _onWillPop() {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: Center(child: Text('Are you sure?')),
        content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children : <Widget>[
                Expanded(
                  child: Text(
                    'Do you want to go back on Dashboard',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                )
              ],
            ),
        actions: <Widget>[
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: new Text('No'),
            textColor: Colors.green,
          ),
          new FlatButton(
            onPressed: () => Navigator.popAndPushNamed(context, MainDashboard.id),
            child: new Text('Yes'),
            textColor: Colors.green,
          ),
        ],
      ),
    ) ?? false;
  }

  final _auth = FirebaseAuth.instance;
  var dataQuestion;
  var option;
  var option1;
  var option2;
  var option3;
  String question;
  int min = 1;
  int max = 31;
  int value;
  List<int> random = [];
  int qno;
  int counter = 0;

  bool _showSpinner = false;
  String answer;
  List<String> answerList = [];
  String userId;

  void setAnswer() async {
    var fireBaseUserId = await _auth.currentUser();
    await _fireStore
        .collection('users')
        .document('${fireBaseUserId.email}')
        .updateData({'answer': answerList});
  }

  void getFirstQuestion() async {
    _showSpinner = true;
    var rng = new Random();
    for (var i = 0; i < 10; i++) {
      value = min + rng.nextInt(max - min);
      if(random.contains(value)){
          while(random.contains(value) != false){
              value = min + rng.nextInt(max - min);
          }
          random.add(value);
      }else{
          random.add(value);
      }
    }
    await _fireStore
        .collection('questions')
        .document('random')
        .updateData({'random': random});
    qno = random[counter];
    dataQuestion = await _fireStore
        .collection('questions')
        .document('$qno')
        .get();
    setState(() {
      _showSpinner = false;
      question = dataQuestion['question'];
      option1 = dataQuestion['option1'];
      option2 = dataQuestion['option2'];
      option3 = dataQuestion['option3'];
    });
    //questionCount++;
    counter++;
  }

  void getQuestion(String answer) async {
    answerList.add(answer);
    if (counter < 10) {
      qno = random[counter];
      dataQuestion = await _fireStore
          .collection('questions')
          .document('$qno')
          .get();
      setState(() {
        _showSpinner = false;
        question = dataQuestion['question'];
        option1 = dataQuestion['option1'];
        option2 = dataQuestion['option2'];
        option3 = dataQuestion['option3'];
      });
      //questionCount++;
      counter++;
    } else {
      setAnswer();
      setState(() {
        _showSpinner = false;
      });
      Navigator.pushNamed(context, Result.id);
    }
  }

  @override
  void initState() {
    getFirstQuestion();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: _onWillPop,
      child: new Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          centerTitle: true,
          leading: null,
          actions: <Widget>[
            IconButton(
              tooltip: 'Logout',
              icon: Icon(Icons.exit_to_app),
              onPressed: () {
                Navigator.popAndPushNamed(context, LoginScreen.id);
                _auth.signOut();
              },
            )
          ],
          title: Text('Quiz Application'),
          backgroundColor: Colors.grey,
        ),
        body: ModalProgressHUD(        
          inAsyncCall: _showSpinner,
          child: Center(
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 30.0),
                        child: Center(
                          child: Text(
                            'Question: $counter\n\n\n$question',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 25.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: RoundedButton( 
                          colour: Colors.green,
                          title: '$option1',
                          onPressed: () {
                            setState(() {
                              _showSpinner = true;
                            });
                            getQuestion('$option1');
                          },
                          padding: 0.0,
                          textSize: 20.0,
                        ),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: RoundedButton(
                          colour: Colors.blue,
                          title: '$option2',
                          onPressed: () {
                            setState(() {
                              _showSpinner = true;
                            });
                            getQuestion('$option2');
                          },
                          padding: 0.0,
                          textSize: 20.0,
                        ),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: RoundedButton(
                          colour: Colors.red,
                          title: '$option3',
                          onPressed: () {
                            setState(() {
                              _showSpinner = true;
                            });
                            getQuestion('$option3');
                          },
                          padding: 0.0,
                          textSize: 20.0,
                        ),
                      ),
                    ),
                    Row(),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      )
    );
  }
}
