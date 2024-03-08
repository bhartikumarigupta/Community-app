import 'package:chatapp/pages/ChatPage.dart';
import 'package:chatapp/widgets/Widgets.dart';
import 'package:flutter/material.dart';

class GroupTile extends StatefulWidget {
  final String UserName;
  final String GroupId;
  final String groupName;
  const GroupTile(
      {super.key,
      required this.UserName,
      required this.GroupId,
      required this.groupName});

  @override
  State<GroupTile> createState() => _GroupTileState();
}

class _GroupTileState extends State<GroupTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        nextScreen(
            context,
            ChatPage(
              groupId: widget.GroupId,
              groupName: widget.groupName,
              UserName: widget.UserName,
            ));
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        child: ListTile(
            leading: CircleAvatar(
              radius: 30,
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(
                widget.UserName.substring(0, 1).toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
            title: Text(
              widget.groupName,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "Join The conversation as ${widget.UserName}",
              style: TextStyle(fontSize: 13),
            )),
      ),
    );
  }
}
