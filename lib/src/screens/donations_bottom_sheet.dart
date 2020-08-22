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
        stream: FirebaseFirestore.instance
            .collection(FirestoreConstants.USER)
            .doc(userId)
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
                  DocumentSnapshot document = donationsData[position];
                  bool isPaymentSuccess = document.get(
                      FirestoreConstants.PAYMENT_SUCCESS);
                  return ListTile(
                    leading: Icon(
                      isPaymentSuccess
                          ? Icons.attach_money
                          : Icons.money_off,
                      color: isPaymentSuccess
                          ? Colors.green
                          : Colors.red,
                    ),
                    title: Text(
                      'Amount: ${document.get(
                          FirestoreConstants.PAYMENT_AMOUNT)}',
                      style: GoogleFonts.asap(),
                    ),
                    subtitle: Text(
                      isPaymentSuccess
                          ? "Successfully Donated"
                          : "Not able to donate because ${document.get(
                          FirestoreConstants.PAYMENT_ERROR)}",
                      style: GoogleFonts.asap(
                        color: isPaymentSuccess
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    trailing: isPaymentSuccess
                        ? Tooltip(
                      message: "Ask For Refund",
                      child: IconButton(
                        onPressed: () async {
                          Utility.showLoadingDialog(
                              "Creating refund request...");
                          await FirebaseFirestore.instance
                              .collection(FirestoreConstants.REFUNDS)
                              .doc(document.get(FirestoreConstants.PAYMENT_ID))
                              .set({
                            FirestoreConstants.REFUND_BY: userId,
                            FirestoreConstants.PAYMENT_ID:
                            document.get(FirestoreConstants.PAYMENT_ID),
                            FirestoreConstants.REFUND_ON:
                            DateTime
                                .now()
                                .millisecondsSinceEpoch,
                            FirestoreConstants.PAYMENT_SUCCESS:
                            isPaymentSuccess,
                            FirestoreConstants.PAYMENT_AMOUNT:
                            document.get(FirestoreConstants.PAYMENT_AMOUNT),
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
