import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:quiz_application/mainDashboard.dart';
import 'LoginPage.dart';

final _fireStore = Firestore.instance;
class PreviousResult extends StatefulWidget {
  static String id = 'previousResult';
  @override
  _PreviousResultState createState() => _PreviousResultState();
}

class _PreviousResultState extends State<PreviousResult> {
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
  bool _showSpinner = false;
  List<String> pResult = [];
  List<Widget> showText = [];
  List<Widget> showNo = [];
  String temp;
  String data;

    void previousResult() async{
      _showSpinner = true; 
      var fireBaseUserId = await _auth.currentUser();
      var result = await _fireStore
        .collection('users')
        .document('${fireBaseUserId.email}').get();
      for(data in result['result']){
        pResult.add(data);
      }
      if(data == null){
        setState(() {
          _showSpinner = false; 
          showText.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Not Attempted',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22.0,
                  color: Colors.blueAccent,
                ),
              ),
            ),
          );
          showNo.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Quiz - 1',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22.0,
                  color: Colors.red,
                ),
              ),
            ),
          );
        });
      }else{
        for(int i=0; i<pResult.length;i++){
          temp = pResult[i];
          setState(() {
            _showSpinner = false;
              showText.add(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  '$temp Score',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22.0,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
            );
            showNo.add(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Quiz - ${i+1}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22.0,
                    color: Colors.red,
                  ),
                ),
              ),
            );
          });
        }
      }
    }

    @override
  void initState() {
    previousResult();
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: showNo,
                  ),
                  SizedBox(
                    width: 35,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: showText,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}