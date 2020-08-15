import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_chat/src/core/controller/groups_controller.dart';
import 'package:group_chat/src/widget/center_circular_progressbar.dart';

class CreateGroup extends StatefulWidget {
  static const route_name = "create_group";

  @override
  _CreateGroupState createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  var _groupDescriptionNode = FocusNode();
  final _form = GlobalKey<FormState>();
  final GroupController _createGroupController = Get.put(GroupController());
  var _groupName;
  var _groupDescription;

  void _checkForm() {
    final validate = _form.currentState.validate();
    FocusScope.of(context).unfocus();
    if (validate) {
      _form.currentState.save();
      _createGroupController.createGroup(_groupName, _groupDescription);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        title: Text(
          "Create Group",
          style: GoogleFonts.asap(),
        ),
      ),
      body: GetBuilder<GroupController>(
        init: _createGroupController,
        builder: (_) {
          return Stack(
            children: [
              Form(
                key: _form,
                child: Padding(
                  padding: const EdgeInsets.all(
                    15.0,
                  ),
                  child: Column(
                    children: [
                      TextFormField(
                        autofocus: true,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (value) {
                          _groupDescriptionNode.requestFocus();
                        },
                        validator: (value) {
                          if (value.trim().length > 5) return null;
                          return "Group name must be greater than 5 characters";
                        },
                        onSaved: (value) {
                          _groupName = value;
                        },
                        decoration: InputDecoration(
                          hintText: "Group Name",
                          labelText: "Group Name",
                          contentPadding: const EdgeInsets.all(
                            15,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              25.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        focusNode: _groupDescriptionNode,
                        validator: (value) {
                          if (value.trim().length > 15) return null;
                          return "Group description must be greater than 15 characters";
                        },
                        onSaved: (value) {
                          _groupDescription = value;
                        },
                        decoration: InputDecoration(
                          hintText: "Group Description",
                          labelText: "Group Description",
                          contentPadding: const EdgeInsets.all(
                            15,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              25.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Spacer(),
                      SizedBox(
                        width: double.infinity,
                        child: RaisedButton(
                          onPressed: _checkForm,
                          child: Text("Create Group"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_.isLoading) CenterCircularProgressBar(),
            ],
          );
        },
      ),
    );
  }
}
