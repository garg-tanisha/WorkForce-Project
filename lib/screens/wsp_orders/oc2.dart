import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// StreamBuilder(
//                   stream: Firestore.instance
//                       .collection("messages").snapshots(),
//                   builder: (context, snapshot) {
//                     switch (snapshot.connectionState) {
//                       case ConnectionState.none:
//                       case ConnectionState.waiting:
//                         return Center(
//                           child: PlatformProgressIndicator(),
//                         );
//                       default:
//                         return ListView.builder(
//                           reverse: true,
//                           itemCount: snapshot.data.documents.length,
//                           itemBuilder: (context, index) {
//                             List rev = snapshot.data.documents.reversed.toList();
//                             ChatMessageModel message = ChatMessageModel.fromSnapshot(rev[index]);
//                             return ChatMessage(message);
//                           },
//                         );
//                     }
//                   },
//                 )

class ChatMessage extends StatefulWidget {
  final ChatMessageModel _message;
  ChatMessage(this._message);
  @override
  _ChatMessageState createState() => _ChatMessageState(_message);
}

class _ChatMessageState extends State<ChatMessage> {
  final ChatMessageModel _message;

  _ChatMessageState(this._message);

  Future<ChatMessageModel> _load() async {
    await _message.loadUser();
    return _message;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      child: FutureBuilder(
        future: _load(),
        builder: (context, AsyncSnapshot<ChatMessageModel> message) {
          if (!message.hasData) return Container();
          return Row(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(right: 16.0),
                child: GestureDetector(
                  child: CircleAvatar(
                      // backgroundImage: NetworkImage(message.data.user.pictureUrl),
                      ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Afdg",
                      // message.data.user.name,
                      style: Theme.of(context).textTheme.subhead,
                    ),
                    Container(
                        margin: const EdgeInsets.only(top: 5.0),
                        child: _message.mediaUrl != null
                            ? Image.network(_message.mediaUrl, width: 250.0)
                            : Text(_message.text))
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

class ChatMessageModel {
  String id;
  String userId;
  String text;
  String mediaUrl;
  int createdAt;
  String replyId;
  // UserModel user;

  ChatMessageModel({String text, String mediaUrl, String userId}) {
    this.text = text;
    this.mediaUrl = mediaUrl;
    this.userId = userId;
  }

  ChatMessageModel.fromSnapshot(DocumentSnapshot snapshot) {
    this.id = snapshot.documentID;
    this.text = snapshot.data["text"];
    this.mediaUrl = snapshot.data["mediaUrl"];
    this.createdAt = snapshot.data["createdAt"];
    this.replyId = snapshot.data["replyId"];
    this.userId = snapshot.data["userId"];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      "text": this.text,
      "mediaUrl": this.mediaUrl,
      "userId": this.userId,
      "createdAt": this.createdAt
    };
    return map;
  }

  Future<void> loadUser() async {
    DocumentSnapshot ds = await Firestore.instance
        .collection("users")
        .document(this.userId)
        .get();
    // if (ds != null) this.user = UserModel.fromSnapshot(ds);
  }
}
