import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  // *** START DB FETCH ATTEMPT *** //
  // Code below returns a stream from 'chats' node
  // But I haven't been able to successfully also fetch and combine data from 'chats-details' node
  // Using the key fetched within the 'chats' node
  // Ref for the 'chats-details' node: DatabaseReference chatsDetailsRef = fb.child('chats-details').child(** key **);

  DatabaseReference fb = FirebaseDatabase().reference();
  StreamSubscription _streamSubscription;
  List<Chat> myChats = [];

  @override
  void initState() {
    super.initState();

    _streamSubscription = getData().listen((data) {
        if (data.length > 0) {
          setState(() {
            myChats = data;
          });
        }
      });

  }

  Stream<List<Chat>> getData() async* {
    DatabaseReference chatsRef = fb.child('chats');

    var chatsStream = chatsRef.onValue;
    var foundChats = List<Chat>();

    await for (var chatSnapshot in chatsStream) {
      foundChats.clear();
      Map chatDictionary = await chatSnapshot.snapshot.value;
      if (chatDictionary != null) {
        for (var chatItem in chatDictionary.entries) {
          Chat thisChat;
          if (chatItem.key != null) {
            thisChat = Chat.fromMap(chatItem);
          } else {
            thisChat = Chat();
          }
          foundChats.add(thisChat);
        }
      }

      yield foundChats;
    }
  }

  // *** END DB FETCH ATTEMPT *** //

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter-Firebase"),
      ),
      body: ListView.builder(
        itemCount: myChats.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(myChats[index].keyA),
            // Desired result would return data from the two separate DB nodes, which share a common chatID
            // subtitle: Text(myChats[index].chatDetail.keyC),
          );
        },
      ),
    );
  }
}

class Chat {
  
  String id;
  String keyA;
  String keyB;

  ChatDetail chatDetail;

  Chat({String id, String keyA, String keyB}) {
    this.id = id;
    this.keyA = keyA;
    this.keyB = keyB;
  }

  factory Chat.fromMap(MapEntry<dynamic, dynamic> data) {
    return Chat(
        id: data.key ?? '',
        keyA: data.value['keyA'] ?? '',
        keyB: data.value['keyB'] ?? '');
  }

}

class ChatDetail {
  String id;
  String keyC;
  String keyD;

  ChatDetail({String id, String keyC, String keyD}) {
    this.id = id;
    this.keyC = keyC;
    this.keyD = keyD;
  }

  factory ChatDetail.fromMap(MapEntry<dynamic, dynamic> data) {
    return ChatDetail(
        id: data.key ?? '',
        keyC: data.value['keyC'] ?? '',
        keyD: data.value['keyD'] ?? '');
  }
}
