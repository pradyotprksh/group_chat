import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_chat/src/screens/donations_bottom_sheet.dart';
import 'package:group_chat/src/util/app_constants.dart';
import 'package:group_chat/src/util/firestore_constants.dart';
import 'package:group_chat/src/util/string.dart';
import 'package:group_chat/src/util/utility.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorPayScreen extends StatefulWidget {
  static const route_name = "razor_pay_screen";

  @override
  _RazorPayScreenState createState() => _RazorPayScreenState();
}

class _RazorPayScreenState extends State<RazorPayScreen> {
  Razorpay _razorPay;
  var _currentSelected = -1;
  var _currentDonateValue = 0;
  final _controller = TextEditingController();
  var _userId = "";

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    Get.back();
    Utility.showLoadingDialog("Confirming Payment...");
    await FirebaseFirestore.instance
        .collection(FirestoreConstants.USER)
        .doc(_userId)
        .collection(FirestoreConstants.DONATIONS)
        .doc(response.paymentId)
        .set({
      FirestoreConstants.PAYMENT_ID: response.paymentId,
      FirestoreConstants.PAYMENT_ON: DateTime.now().millisecondsSinceEpoch,
      FirestoreConstants.PAYMENT_SUCCESS: true,
      FirestoreConstants.PAYMENT_AMOUNT: _currentDonateValue,
    });
    Get.back();
    Get.back(result: true);
  }

  void _handlePaymentError(PaymentFailureResponse response) async {
    Get.back();
    await FirebaseFirestore.instance
        .collection(FirestoreConstants.USER)
        .doc(_userId)
        .collection(FirestoreConstants.DONATIONS)
        .doc()
        .set({
      FirestoreConstants.PAYMENT_ID: "",
      FirestoreConstants.PAYMENT_ON: DateTime
          .now()
          .millisecondsSinceEpoch,
      FirestoreConstants.PAYMENT_SUCCESS: false,
      FirestoreConstants.PAYMENT_AMOUNT: _currentDonateValue,
      FirestoreConstants.PAYMENT_ERROR: response.message,
    });
    Utility.showSnackBar(response.message, Colors.red);
  }

  @override
  void initState() {
    super.initState();
    DocumentSnapshot userSnapshot = Get.arguments;
    _userId = userSnapshot.get(FirestoreConstants.USER_ID);
    _razorPay = Razorpay();
    _razorPay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorPay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  }

  @override
  void dispose() {
    super.dispose();
    _razorPay.clear();
  }

  void _setupRazorPayOptions() {
    if (_currentDonateValue == 0) {
      Utility.showSnackBar(
          "Please select an amount you want to donate...", Colors.red);
      return;
    }
    Utility.showLoadingDialog("Waiting for Razor pay...");
    var options = {
      'key': AppConstants.RAZOR_PAY_LIVE_ID,
      'amount': _currentDonateValue * 100,
      'name': StringConstant.APP_NAME,
      'description': 'Donating',
    };
    _razorPay.open(options);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme
            .of(context)
            .backgroundColor,
        title: Text(
          "Donate",
          style: GoogleFonts.asap(),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Get.bottomSheet(DonationsBottomSheet(_userId));
            },
            icon: Icon(
              Icons.history,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(
          15.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Select Amount",
              textAlign: TextAlign.start,
              style: GoogleFonts.asap(
                fontSize: 20.0,
              ),
            ),
            const SizedBox(
              height: 15.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FlatButton(
                  onPressed: () {
                    _currentDonateValue = 10;
                    setState(() {
                      _currentSelected = 0;
                    });
                  },
                  color: _currentSelected == 0 ? Colors.red : null,
                  child: Text(
                    "10",
                    style: GoogleFonts.asap(
                      fontSize: 16,
                    ),
                  ),
                ),
                FlatButton(
                  onPressed: () {
                    _currentDonateValue = 50;
                    setState(() {
                      _currentSelected = 1;
                    });
                  },
                  color: _currentSelected == 1 ? Colors.red : null,
                  child: Text(
                    "50",
                    style: GoogleFonts.asap(
                      fontSize: 16,
                    ),
                  ),
                ),
                FlatButton(
                  onPressed: () {
                    _currentDonateValue = 100;
                    setState(() {
                      _currentSelected = 2;
                    });
                  },
                  color: _currentSelected == 2 ? Colors.red : null,
                  child: Text(
                    "100",
                    style: GoogleFonts.asap(
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 15.0,
            ),
            TextField(
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              keyboardType: TextInputType.number,
              controller: _controller,
              style: Theme
                  .of(context)
                  .textTheme
                  .bodyText1,
              decoration: InputDecoration(
                labelText: 'Enter Amount...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    25.0,
                  ),
                ),
                suffixIcon: IconButton(
                  color: Theme
                      .of(context)
                      .accentColor,
                  icon: Icon(
                    Icons.clear,
                  ),
                  onPressed: () {
                    _controller.clear();
                    _currentDonateValue = 0;
                    setState(() {});
                  },
                ),
              ),
              onChanged: (value) {
                _currentDonateValue = int.tryParse(value);
                setState(() {});
              },
              onSubmitted: (value) {
                _currentDonateValue = int.tryParse(value);
                setState(() {});
              },
            ),
            const SizedBox(
              height: 100,
            ),
            RaisedButton(
              onPressed: _setupRazorPayOptions,
              child: Text(
                'Donate',
                style: GoogleFonts.asap(
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              '*Please enter your phone number and email id in the next step. We don\'t save your details so you need to add it manually.',
              style: GoogleFonts.asap(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
