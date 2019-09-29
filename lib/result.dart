import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quiz_application/mainDashboard.dart';
import 'package:quiz_application/component/rounded_button.dart';
import 'package:quiz_application/LoginPage.dart';
import 'package:quiz_application/dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

final _fireStore = Firestore.instance;

class Result extends StatefulWidget {
  static String id = 'Result';
  @override
  _ResultState createState() => _ResultState();
}

class _ResultState extends State<Result> {
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
                    'Do you want to give Quiz Again',
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
            onPressed: () {
              Navigator.popAndPushNamed(context, MainDashboard.id);
            },
            child: new Text('Yes'),
            textColor: Colors.green,
          ),
        ],
      ),
    ) ?? false;
  }
  String userId;
  final _auth = FirebaseAuth.instance;
  List<String> answerList = [];
  List<String> uanswerList = [];
  List<String> scoreList = [];
  List<Widget> resultText = [];
  List<Widget> answerText = [];
  List<String> randomNo = [];
  String display;
  bool _showSpinner = false;
  String temp;
  int countAnswer = 0;
  void getResult() async {
    setState(() {
      _showSpinner = true;
    });
    var fireBaseUser = await _auth.currentUser();
    userId = fireBaseUser.email;
    // var allanswer =
    //     await _fireStore.collection('questions').document('answers').get();
    // for (String answer in allanswer['answer']) {
    //   answerList.add(answer);
    // }
    var data = await _fireStore.collection('questions').document('random').get();
    for(int Data in data['random']){
      randomNo.add(Data.toString());
    }

    for(int i=0;i<10;i++){
      temp = randomNo[i];
      var allanswer = 
          await _fireStore.collection('questions').document('$temp').get();
      answerList.add(allanswer['answer']);
    }
    var useranswer = 
      await _fireStore.collection('users').document('$userId').get();
    for(String uanswer in useranswer['answer']){
      uanswerList.add(uanswer);
    }
    for(int i=0;i<10;i++){
      if(uanswerList[i] == answerList[i]){
        countAnswer++;
      }
    }
    String fScore = countAnswer.toString();
    var score = 
      await _fireStore.collection('users').document('$userId').get();
    for(String pre_score in score['result']){
      scoreList.add(pre_score);
    }
    scoreList.add(fScore);

    await _fireStore
        .collection('users').document('$userId').updateData({'result': scoreList});

    setState(() {
      _showSpinner = false;
      resultText.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Total Score = $fScore / 10',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 25.0,
              color: Colors.blueAccent,
              ),
          ),
        ),
      ); 
    });
    for(int i=0;i<10;i++){
      display = uanswerList[i];
      if(uanswerList[i] == answerList[i]){
        setState(() {
          _showSpinner = false;
          answerText.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                '${i+1}.) $display\n',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.lightGreen,
                  ),
              ),
            )
          );
        });
      }else{
        setState(() {
          _showSpinner = false;
          answerText.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                '${i+1}.) $display\n',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.red,
                  ),
              ),
            )
          );
        });
      }
    }

    // setState(() {
    //   resultText.add(
    //     Padding(
    //       padding: const EdgeInsets.symmetric(vertical: 8.0),
    //       child: Text(
    //         'Total Score = $fScore / 10',
    //         textAlign: TextAlign.center,
    //         style: TextStyle(
    //           fontSize: 20.0,
    //           color: Colors.lightGreen,
    //           ),
    //       ),
    //     ),
    //   );
    //   resultText.add();
    // });
  }

  @override
  void initState() {
    getResult();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: _onWillPop,
      child: new Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          leading: null,
          centerTitle: true,
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
                  children: <Widget>[
                    Center(
                      child: Container(
                        child: Text(
                          '\nThank you for giving Quiz.\nYour Result',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: resultText,
                      ),
                    ),  
                    //       Center(
                    //         child: Row(
                    //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //           children: answerText,
                    //         ),
                    //       ),
                    //   ),
                    // ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: answerText,
                      ),
                    ),
                    Column(
                      children: <Widget>[
                        Center(
                          child: RoundedButton(
                            colour: Colors.lightBlueAccent,
                            title: 'Retry',
                            onPressed: () {
                              countAnswer = 0;
                              try {
                                Navigator.popAndPushNamed(context, DashBoard.id);
                              } catch (e) {
                                print(e);
                              }
                            },
                            textSize: 17.0,
                          ),
                        ),
                        Center(
                          child: RoundedButton(
                            colour: Colors.lightBlueAccent,
                            title: 'Sign Out',
                            onPressed: () {
                              Navigator.popAndPushNamed(context, LoginScreen.id);
                              _auth.signOut();
                          },
                            textSize: 17.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
