import 'package:chatapp/helper/helper_function.dart';
import 'package:chatapp/pages/ChatPage.dart';
import 'package:chatapp/service/database_service.dart';
import 'package:chatapp/widgets/GroupTile.dart';
import 'package:chatapp/widgets/Widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Search_page extends StatefulWidget {
  const Search_page({super.key});

  @override
  State<Search_page> createState() => _Search_pageState();
}

class _Search_pageState extends State<Search_page> {
  TextEditingController SearchController = TextEditingController();
  bool isLoading = false;
  QuerySnapshot? searchSnapshot;
  bool hasSearched = false;
  String UserName = "";
  User? user;
  bool isjoined = false;
  @override
  void initState() {
    GetCurrentUserIdandName();
    super.initState();
  }

  String getname(String r) {
    return r.substring(r.indexOf("_") + 1);
  }

  String GetId(String Res) {
    return Res.substring(0, Res.indexOf("_"));
  }

  GetCurrentUserIdandName() async {
    await HelperFunctions.getUserName().then((value) {
      setState(() {
        UserName = value!;
      });
    });
    user = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(
          "Search",
          style: TextStyle(
              fontSize: 27, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).primaryColor,
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: Row(
              children: [
                Expanded(
                    child: TextField(
                  controller: SearchController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Search Groups...",
                      hintStyle: TextStyle(color: Colors.white, fontSize: 16)),
                )),
                GestureDetector(
                  onTap: () {
                    initiateSearchMethod();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(40)),
                    child: Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),
          isLoading
              ? Center(
                  child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor),
                )
              : GroupList()
        ],
      ),
    );
  }

  initiateSearchMethod() async {
    print(SearchController.text);
    if (SearchController.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      await DataBaseService()
          .SearchByName(SearchController.text)
          .then((snapshot) {
        setState(() {
          searchSnapshot = snapshot;
          isLoading = false;
          hasSearched = true;
        });
      });
    }
  }

  GroupList() {
    return hasSearched
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: searchSnapshot!.docs.length,
            itemBuilder: (context, int index) {
              return grouptile(
                  UserName,
                  searchSnapshot!.docs[index]['groupId'],
                  searchSnapshot!.docs[index]['groupName'],
                  searchSnapshot!.docs[index]['admin']);
            },
          )
        : Container();
  }

  joinedOrNot(
      String userName, String groupId, String groupname, String admin) async {
    await DataBaseService(uid: user!.uid)
        .IsUserJoined(groupname, groupId, userName)
        .then((value) {
      setState(() {
        isjoined = value;
      });
    });
  }

  Widget grouptile(
      String username, String groupId, String groupName, String Admin) {
    joinedOrNot(username, groupId, groupName, Admin);
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      leading: CircleAvatar(
        radius: 30,
        child: Text(
          "${groupName.substring(0, 2).toUpperCase()}",
          style: TextStyle(color: Colors.white),
        ),
      ),
      title: Text(
        groupName,
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text("Admin: ${getname(Admin)}"),
      trailing: InkWell(
        onTap: () async {
          await DataBaseService(uid: user!.uid)
              .ToggleGroupJoin(groupId, username, groupName);
          if (isjoined) {
            setState(() {
              isjoined = !isjoined;
            });
            showsnackbar(context, Colors.green, "Successfully joined he group");
            Future.delayed(const Duration(seconds: 2), () {
              nextScreen(
                  context,
                  ChatPage(
                      groupId: groupId,
                      groupName: groupName,
                      UserName: username));
            });
          } else {
            setState(() {
              isjoined = !isjoined;
              showsnackbar(context, Colors.red, "Left the group $groupName");
            });
          }
        },
        child: isjoined
            ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.black,
                  border: Border.all(color: Colors.white, width: 1),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: const Text(
                  "Joined",
                  style: TextStyle(color: Colors.white),
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).primaryColor,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: const Text("Join Now",
                    style: TextStyle(color: Colors.white)),
              ),
      ),
    );
  }
}
