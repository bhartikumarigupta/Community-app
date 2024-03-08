import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this import statement for clipboard functionality

class messageTile extends StatefulWidget {
  final String message;
  final String sender;
  final bool sendBy;
  messageTile(
      {super.key,
      required this.message,
      required this.sender,
      required this.sendBy});

  @override
  State<messageTile> createState() => _messageTileState();
}

class _messageTileState extends State<messageTile> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.only(
          top: 2,
          bottom: 4,
          left: widget.sendBy ? 0 : 24,
          right: widget.sendBy ? 24 : 0),
      child: Container(
        margin: widget.sendBy
            ? EdgeInsets.only(left: 140)
            : EdgeInsets.only(right: 140),
        padding: EdgeInsets.only(top: 8, left: 20, bottom: 17, right: 20),
        alignment: widget.sendBy ? Alignment.centerRight : Alignment.centerLeft,
        decoration: BoxDecoration(
            color: widget.sendBy ? Theme.of(context).primaryColor : Colors.grey,
            borderRadius: widget.sendBy
                ? BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20))
                : BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              // Add a row to contain the sender's name and the copy button
              children: [
                Expanded(
                  child: Text(
                    widget.sendBy == true ? "You" : widget.sender,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.copy,
                    size: 20,
                  ),
                  color: Colors.white,
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: widget.message));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Copied to clipboard')),
                    );
                  },
                ),
              ],
            ),
            Divider(
              height: 0.1,
              color: const Color.fromRGBO(255, 255, 255, 1),
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              widget.message,
              style: TextStyle(fontSize: 16, color: Colors.white),
            )
          ],
        ),
      ),
    );
  }
}
