import 'dart:convert';

import 'package:chatapp/helper/helper_function.dart';
import 'package:chatapp/pages/apiservice.dart';
import 'package:chatapp/pages/groupInfo.dart';
import 'package:chatapp/service/database_service.dart';
import 'package:chatapp/widgets/Widgets.dart';
import 'package:chatapp/widgets/messageTile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:openai_gpt3_api/openai_gpt3_api.dart';

class ChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  // ignore: non_constant_identifier_names
  final String UserName;
  const ChatPage(
      {super.key,
      required this.groupId,
      required this.groupName,
      required this.UserName});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Stream<QuerySnapshot>? chats;
  final ValueNotifier<String> responseNotifier = ValueNotifier<String>('');

  final ValueNotifier<bool> isLoadingNotifier = ValueNotifier<bool>(false);
  String response = "";
  TextEditingController messageController = TextEditingController();
  String admin = "";
  @override
  void initState() {
    getChatsandAdmin();
    super.initState();
  }

  String modeOpenAI = "chat";
  Future<void> sendRequestToOpenAI(String userInput) async {
    setState(() {
      isLoadingNotifier.value = true;
    });
    String api = "";
    String model = "";
    await HelperFunctions.getapikey().then((value) {
      api = value!;
      setState(() {});
    });
    await HelperFunctions.getmodel().then((value) {
      model = value!;
      setState(() {});
    });
    await APIService()
        .requestOpenAI(userInput, modeOpenAI, 2000, api, model)
        .then((value) {
      setState(() {
        isLoadingNotifier.value = false;
      });
      print("Response from OpenAI:${value.body} ");
      final responseAvailable = jsonDecode(value.body);

      if (responseAvailable["error"] != null) {
        responseNotifier.value =
            "Error: " + responseAvailable["error"].toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Error: " + responseAvailable["error"].toString(),
            ),
          ),
        );
        return;
      }
      String t = utf8.decode(responseAvailable["choices"][0]["message"]
              ["content"]
          .toString()
          .codeUnits);
      setState(() {
        responseNotifier.value = t; // This will trigger the UI to update
      });
    }).catchError((errorMessage) {
      // setState(() {
      //   isLoading = false;
      // });
      // Utils.testWinToastBar("Error:", errorMessage.toString(), Colors.red);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error: " + errorMessage.toString(),
          ),
        ),
      );
    });
  }

  getChatsandAdmin() {
    DataBaseService().getChats(widget.groupId).then((val) {
      setState(() {
        chats = val;
      });
    });
    DataBaseService().getGroupAdmin(widget.groupId).then((val) {
      admin = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(widget.groupName),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
              onPressed: () {
                nextScreen(
                    context,
                    GroupInfo(
                        GroupId: widget.groupId,
                        GroupName: widget.groupName,
                        adminName: admin));
              },
              icon: const Icon(Icons.info))
        ],
      ),
      body: Stack(
        children: <Widget>[
          chatMessages(),
          Container(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              width: MediaQuery.of(context).size.width,
              color: Colors.grey,
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                    controller: messageController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                        hintText: "Send a message...",
                        hintStyle: TextStyle(color: Colors.white, fontSize: 16),
                        border: InputBorder.none),
                  )),
                  const SizedBox(
                    width: 16,
                  ),
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          // showDialogWithTextField(BuildContext context) {
                          TextEditingController _controller =
                              TextEditingController();
                          String answer = "";

                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Ask AI a question'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: _controller,
                                            decoration: InputDecoration(
                                              hintText: "Enter your text here",
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            sendRequestToOpenAI(
                                                _controller.text);
                                          },
                                          child: Container(
                                            child: Icon(Icons.send,
                                                color: Theme.of(context)
                                                    .primaryColor),
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(height: 20),
                                    ValueListenableBuilder<bool>(
                                      valueListenable: isLoadingNotifier,
                                      builder: (context, isLoading, _) {
                                        return isLoading
                                            ? CircularProgressIndicator()
                                            : ValueListenableBuilder<String>(
                                                valueListenable:
                                                    responseNotifier,
                                                builder:
                                                    (context, response, _) {
                                                  return Expanded(
                                                    child:
                                                        SingleChildScrollView(
                                                      padding: EdgeInsets.all(
                                                          8), // Add some padding if necessary.
                                                      child: Text(
                                                        response,
                                                        style: TextStyle(
                                                          fontSize: 20,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                      },
                                    ),
                                    SizedBox(height: 20),
                                    Container(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.refresh,
                                                color: Colors.red, size: 30),
                                            onPressed: () {
                                              setState(() {
                                                responseNotifier.value = "";
                                                sendRequestToOpenAI(
                                                    _controller.text);
                                              });
                                            },
                                          ),
                                          InkWell(
                                            onTap: () {
                                              setState(() {
                                                messageController.text =
                                                    responseNotifier.value;
                                              });
                                              sendMessage();
                                              Navigator.pop(context);
                                            },
                                            child: Text(
                                              "Accept",
                                              style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: 20),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                actions: <Widget>[
                                  Container(
                                    child: Text('Submit'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle),
                            child: Text("AI")),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          sendMessage();
                        },
                        child: Container(
                          height: 45,
                          width: 45,
                          decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(30)),
                          child: const Center(
                            child: Icon(
                              Icons.send,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  chatMessages() {
    return StreamBuilder(
        stream: chats,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  padding: EdgeInsets.only(bottom: 70),
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    return messageTile(
                      message: snapshot.data.docs[index]['message'],
                      sender: snapshot.data.docs[index]['sender'],
                      sendBy: widget.UserName ==
                          snapshot.data.docs[index]['sender'],
                    );
                  },
                )
              : Container();
        });
  }

  sendMessage() {
    if (messageController.text.isNotEmpty) {
      // ignore: non_constant_identifier_names
      Map<String, dynamic> ChatMessageMap = {
        "message": messageController.text,
        "sender": widget.UserName,
        "time": DateTime.now().millisecondsSinceEpoch
      };
      DataBaseService().sendMessage(widget.groupId, ChatMessageMap);
      setState(() {
        messageController.clear();
      });
    }
  }
}
