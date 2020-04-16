import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chello/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  static String id = 'chatScreen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _firestore = Firestore.instance;
  final _auth = FirebaseAuth.instance;
  FirebaseUser loggedInUser;
  String messageText;
  final tFController = TextEditingController();

  clearText() {
    setState(() {
      tFController.clear();
    });
  }

  void getCurrentUser() async {
    try {
      final FirebaseUser user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  // getMessages() async
  // {
  //   await for(var snapshots in _firestore.collection('messages').snapshots()){
  //     for(var message in snapshots.documents)
  //     {
  //       print(message.data);
  //     }
  //   }
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chello'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder(
              stream: _firestore.collection('messages').orderBy('timestamp',descending: true).snapshots(),
              builder: (context, snapshot) {
                List<MessageBubble> messageList = [];
                MessageBubble messageWidget;
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data.documents;
                for (var message in messages) {
                  String text = message.data['message'];
                  String sender = message.data['email'];
                  
                  messageWidget = MessageBubble(
                    email: sender,
                    text: text,
                    isMe: sender==loggedInUser.email
                  );
                  messageList.add(messageWidget);
                }
                return Expanded(
                  child: ListView(
                    children: messageList,
                    reverse: true,
                  ),
                );
              },
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: tFController,
                      autocorrect: true,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      clearText();
                      _firestore
                          .collection('messages')
                          .add({
                        'message': messageText,
                        'email': loggedInUser.email,
                        'timestamp': DateTime.now(),
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble({this.email, this.text, this.isMe=false});

  final String text;
  final String email;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isMe?CrossAxisAlignment.end:CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            email,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 10,
            ),
          ),
        ),
        Padding(
          padding:isMe? const EdgeInsets.fromLTRB(80, 1, 8,12):const EdgeInsets.fromLTRB(8, 1, 80, 12),
          child: Material(
              color: isMe?Colors.blue[400]:Colors.grey[400],
              elevation: 3,
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                child: Text(
                  text,
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              )),
        ),
      ],
    );
  }
}
