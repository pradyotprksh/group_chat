import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:group_chat/src/screens/group_list/single_group_detail.dart';
import 'package:group_chat/src/util/firestore_constants.dart';
import 'package:group_chat/src/widget/center_circular_progressbar.dart';
import 'package:group_chat/src/widget/center_text.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  var _searchedString = "";
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      child: Column(
        children: [
          Container(
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
                    keyboardType: TextInputType.name,
                    controller: _controller,
                    style: Theme.of(context).textTheme.bodyText1,
                    decoration: InputDecoration(
                      labelText: 'Search Group...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          25.0,
                        ),
                      ),
                      suffixIcon: IconButton(
                        color: Theme.of(context).accentColor,
                        icon: Icon(
                          Icons.clear,
                        ),
                        onPressed: () {
                          _controller.clear();
                          _searchedString = "";
                          setState(() {});
                        },
                      ),
                    ),
                    onChanged: (value) {
                      _searchedString = value;
                      setState(() {});
                    },
                    onSubmitted: (value) {
                      _searchedString = value;
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection(FirestoreConstants.GROUPS)
                  .where(
                    FirestoreConstants.GROUP_NAME,
                    isGreaterThanOrEqualTo: _searchedString,
                  )
                  .snapshots(),
              builder: (_, groupsSnapshot) {
                if (groupsSnapshot.connectionState == ConnectionState.waiting) {
                  return CenterCircularProgressBar();
                } else if (groupsSnapshot.data == null) {
                  return CenterText(
                      "No group found with the name $_searchedString.");
                } else {
                  var snapshot = groupsSnapshot.data.documents;
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.length,
                    padding: const EdgeInsets.only(
                      top: 15.0,
                    ),
                    itemBuilder: (_, position) {
                      return SingleGroupDetail(snapshot[position]);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
