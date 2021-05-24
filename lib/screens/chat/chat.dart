import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DatabaseMethods {
  getChats(String placedOrderId) async {
    return Firestore.instance
        .collection("placed orders")
        .document(placedOrderId)
        .collection("chats")
        .orderBy('time')
        .snapshots();
  }

  Future<void> addMessage(String placedOrderId, chatMessageData) {
    Firestore.instance
        .collection("placed orders")
        .document(placedOrderId)
        .collection("chats")
        .add(chatMessageData)
        .catchError((e) {
      print(e.toString());
    });
  }
}

class ChatPage extends StatefulWidget {
  final String placedOrderId;
  final String userId;
  ChatPage({this.placedOrderId, this.userId});

  @override
  _ChatState createState() => _ChatState(userId);
}

class _ChatState extends State<ChatPage> {
  Stream<QuerySnapshot> chats;
  TextEditingController messageEditingController = new TextEditingController();
  String userId;

  _ChatState(String userId) {
    this.userId = userId;
  }

  @override
  void initState() {
    DatabaseMethods().getChats(widget.placedOrderId).then((val) {
      setState(() {
        chats = val;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ChatBox"),
        elevation: 0.0,
        centerTitle: false,
      ),
      body: Container(
        child: Stack(
          children: [
            chatMessages(),
            Container(
              alignment: Alignment.bottomCenter,
              width: MediaQuery.of(context).size.width,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                color: Color(0x61000000),
                child: Row(
                  children: [
                    Expanded(
                        child: TextField(
                      controller: messageEditingController,
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                      decoration: InputDecoration(
                          hintText: "Message ...",
                          hintStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                          border: InputBorder.none),
                    )),
                    SizedBox(
                      width: 16,
                    ),
                    GestureDetector(
                      onTap: () {
                        addMessage();
                      },
                      child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFFFFFFFF),
                                    const Color(0xFFFFFFFF)
                                  ],
                                  begin: FractionalOffset.topLeft,
                                  end: FractionalOffset.bottomRight),
                              borderRadius: BorderRadius.circular(40)),
                          padding: EdgeInsets.all(12),
                          child: Image.asset(
                            "images/send.png",
                            height: 25,
                            width: 25,
                          )),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget chatMessages() {
    return StreamBuilder(
      stream: chats,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  return MessageTile(
                    message: snapshot.data.documents[index].data["message"],
                    sendByMe: this.userId ==
                        snapshot.data.documents[index].data["sendBy"],
                    timeOfMessage: snapshot.data.documents[index].data["time"],
                  );
                })
            : Container();
      },
    );
  }

  addMessage() {
    if (messageEditingController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "sendBy": this.userId,
        "message": messageEditingController.text,
        'time': DateTime.now(),
      };

      DatabaseMethods().addMessage(widget.placedOrderId, chatMessageMap);

      setState(() {
        messageEditingController.text = "";
      });
    }
  }
}

class MessageTile extends StatelessWidget {
  final String message;
  final bool sendByMe;
  final Timestamp timeOfMessage;

  MessageTile(
      {@required this.message,
      @required this.sendByMe,
      @required this.timeOfMessage});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(
              top: 8,
              bottom: 8,
              left: sendByMe ? 0 : 24,
              right: sendByMe ? 24 : 0),
          alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: sendByMe
                ? EdgeInsets.only(left: 30)
                : EdgeInsets.only(right: 30),
            padding: EdgeInsets.only(top: 17, bottom: 17, left: 20, right: 20),
            decoration: BoxDecoration(
                borderRadius: sendByMe
                    ? BorderRadius.only(
                        topLeft: Radius.circular(23),
                        topRight: Radius.circular(23),
                        bottomLeft: Radius.circular(23))
                    : BorderRadius.only(
                        topLeft: Radius.circular(23),
                        topRight: Radius.circular(23),
                        bottomRight: Radius.circular(23)),
                gradient: LinearGradient(
                  colors: sendByMe
                      ? [const Color(0xff007EF4), const Color(0xff2A75BC)]
                      : [const Color(0x73000000), const Color(0x61000000)],
                )),
            child: Text(message,
                textAlign: TextAlign.start,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'OverpassRegular',
                    fontWeight: FontWeight.w300)),
          ),
        ),
        Container(
          padding: EdgeInsets.only(
              left: sendByMe ? 0 : 24, right: sendByMe ? 24 : 0),
          alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
              padding: EdgeInsets.only(top: 5, bottom: 5, left: 7, right: 7),
              child: Text(
                  DateTime.fromMicrosecondsSinceEpoch(
                          timeOfMessage.microsecondsSinceEpoch)
                      .toString(),
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontFamily: 'OverpassRegular',
                      fontWeight: FontWeight.w300))),
        )
      ],
    );
  }
}
