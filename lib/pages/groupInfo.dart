import 'package:chatapp/pages/HomePage.dart';
import 'package:chatapp/service/database_service.dart';
import 'package:chatapp/widgets/Widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupInfo extends StatefulWidget {
  final String GroupId;
  final String GroupName;
  final String adminName;

  const GroupInfo(
      {super.key,
      required this.GroupId,
      required this.GroupName,
      required this.adminName});

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  Stream? member;
  @override
  void initState() {
    getMember();
    super.initState();
  }

  getMember() {
    DataBaseService().getGroupMembers(widget.GroupId).then((val) {
      setState(() {
        member = val;
      });
    });
  }

  String getname(String r) {
    return r.substring(r.indexOf("_") + 1);
  }

  String GetId(String Res) {
    return Res.substring(0, Res.indexOf("_"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
          title: Text("GroupInfo"),
          actions: [
            IconButton(
                onPressed: () {
                  showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text("Exit Group"),
                          content:
                              Text("Are you sure you want to Exit the Group"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                "cancel",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                await DataBaseService(
                                        uid: FirebaseAuth
                                            .instance.currentUser!.uid)
                                    .ToggleGroupJoin(
                                        widget.GroupId,
                                        getname(widget.adminName),
                                        widget.GroupId)
                                    .whenComplete(() {
                                  nextScreenReplace(context, HomePage());
                                });
                              },
                              child: Text(
                                "OK",
                                style: TextStyle(color: Colors.green),
                              ),
                            ),
                          ],
                        );
                      });
                },
                icon: Icon(Icons.exit_to_app))
          ],
        ),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Theme.of(context).primaryColor.withOpacity(0.2)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      widget.GroupName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, color: Colors.black),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Group:  ${widget.GroupName}",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text("Admin : ${getname(widget.adminName)}",
                          style: TextStyle(fontWeight: FontWeight.w500))
                    ],
                  )
                ],
              ),
            ),
            memberList()
          ]),
        ));
  }

  memberList() {
    return StreamBuilder(
      stream: member,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data['members'] != null) {
            if (snapshot.data['members'].length != 0) {
              return ListView.builder(
                itemCount: snapshot.data['members'].length,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          getname(snapshot.data['members'][index])
                              .substring(0, 1)
                              .toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(getname(snapshot.data['members'][index])),
                      subtitle: Text(GetId(snapshot.data['members'][index])),
                    ),
                  );
                },
              );
            } else {
              return Center(
                child: Text("No Members"),
              );
            }
          } else {
            return const Center(
              child: Text("No Member"),
            );
          }
        } else {
          return CircularProgressIndicator(
              color: Theme.of(context).primaryColor);
        }
      },
    );
  }
}
