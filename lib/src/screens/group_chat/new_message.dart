import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:group_chat/src/util/firestore_constants.dart';

class NewMessage extends StatelessWidget {
  final String groupName;
  final FirebaseUser user;

  NewMessage(this.groupName, this.user);

  @override
  Widget build(BuildContext context) {
    var _enteredMessage = "";
    final _controller = TextEditingController();

    void _sendMessage() {
      if (_enteredMessage.trim().isNotEmpty) {
        _controller.clear();
        Firestore.instance
            .collection(FirestoreConstants.GROUPS)
            .document(groupName)
            .collection(FirestoreConstants.MESSAGES)
            .document()
            .setData({
          FirestoreConstants.MESSAGE_ON: DateTime.now().millisecondsSinceEpoch,
          FirestoreConstants.MESSAGE_BY: user.uid,
          FirestoreConstants.MESSAGE: _enteredMessage,
          FirestoreConstants.USER_NAME: "${user.displayName}",
          FirestoreConstants.USER_PROFILE_PIC: "${user.photoUrl}",
        }).then((value) {
          _enteredMessage = "";
        });
      }
    }

    return Container(
      padding: EdgeInsets.all(
        10,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              controller: _controller,
              style: Theme.of(context).textTheme.bodyText1,
              decoration: InputDecoration(
                hintText: 'Remember to keep group chat respectful...',
                labelText: 'Type Message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    25.0,
                  ),
                ),
                suffixIcon: IconButton(
                  color: Theme.of(context).accentColor,
                  icon: Icon(
                    Icons.send,
                  ),
                  onPressed: () {
                    _sendMessage();
                  },
                ),
                /*prefixIcon: IconButton(
                  color: Theme.of(context).accentColor,
                  icon: Icon(
                    Icons.attach_file,
                  ),
                  onPressed: () {},
                ),*/
              ),
              onChanged: (value) {
                _enteredMessage = value;
              },
              onSubmitted: (value) {
                if (_enteredMessage.trim().isNotEmpty) {
                  _sendMessage();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
