import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_chat/src/util/firestore_constants.dart';
import 'package:group_chat/src/util/utility.dart';
import 'package:group_chat/src/widget/center_circular_progressbar.dart';
import 'package:group_chat/src/widget/center_text.dart';

class DonationsBottomSheet extends StatelessWidget {
  final String userId;

  DonationsBottomSheet(this.userId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        leading: CloseButton(),
        title: Text(
          "Donation History",
          style: GoogleFonts.asap(),
        ),
      ),
      body: StreamBuilder(
        stream: Firestore.instance
            .collection(FirestoreConstants.USER)
            .document(userId)
            .collection(FirestoreConstants.DONATIONS)
            .orderBy(
              FirestoreConstants.PAYMENT_ON,
              descending: true,
            )
            .snapshots(),
        builder: (_, donationsSnapshot) {
          if (donationsSnapshot.connectionState == ConnectionState.waiting) {
            return CenterCircularProgressBar();
          } else if (donationsSnapshot.data == null) {
            return CenterText("Not able to get donation lists");
          } else {
            var donationsData = donationsSnapshot.data.documents;
            if (donationsData.length > 0) {
              return ListView.builder(
                itemCount: donationsData.length,
                itemBuilder: (_, position) {
                  return ListTile(
                    leading: Icon(
                      donationsData[position]
                              [FirestoreConstants.PAYMENT_SUCCESS]
                          ? Icons.attach_money
                          : Icons.money_off,
                      color: donationsData[position]
                              [FirestoreConstants.PAYMENT_SUCCESS]
                          ? Colors.green
                          : Colors.red,
                    ),
                    title: Text(
                      'Amount: ${donationsData[position][FirestoreConstants.PAYMENT_AMOUNT]}',
                      style: GoogleFonts.asap(),
                    ),
                    subtitle: Text(
                      donationsData[position]
                              [FirestoreConstants.PAYMENT_SUCCESS]
                          ? "Successfully Donated"
                          : "Not able to donate because ${donationsData[position][FirestoreConstants.PAYMENT_ERROR]}",
                      style: GoogleFonts.asap(
                        color: donationsData[position]
                                [FirestoreConstants.PAYMENT_SUCCESS]
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    trailing: donationsData[position]
                            [FirestoreConstants.PAYMENT_SUCCESS]
                        ? Tooltip(
                            message: "Ask For Refund",
                            child: IconButton(
                              onPressed: () async {
                                Utility.showLoadingDialog(
                                    "Creating refund request...");
                                await Firestore.instance
                                    .collection(FirestoreConstants.REFUNDS)
                                    .document(donationsData[position]
                                        [FirestoreConstants.PAYMENT_ID])
                                    .setData({
                                  FirestoreConstants.REFUND_BY: userId,
                                  FirestoreConstants.PAYMENT_ID:
                                      donationsData[position]
                                          [FirestoreConstants.PAYMENT_ID],
                                  FirestoreConstants.REFUND_ON:
                                      DateTime.now().millisecondsSinceEpoch,
                                  FirestoreConstants.PAYMENT_SUCCESS:
                                      donationsData[position]
                                          [FirestoreConstants.PAYMENT_SUCCESS],
                                  FirestoreConstants.PAYMENT_AMOUNT:
                                      donationsData[position]
                                          [FirestoreConstants.PAYMENT_AMOUNT],
                                });
                                Get.back();
                                Utility.showSnackBar(
                                    ("A request for refund is initiated. We will get back to you"),
                                    Colors.green);
                              },
                              icon: Icon(
                                Icons.settings_backup_restore,
                              ),
                            ),
                          )
                        : Container(
                            width: 0,
                            height: 0,
                          ),
                  );
                },
              );
            } else {
              return CenterText('No Donation Given Yet.');
            }
          }
        },
      ),
    );
  }
}
