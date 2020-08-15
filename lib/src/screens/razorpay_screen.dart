import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_chat/src/util/app_constants.dart';
import 'package:group_chat/src/util/string.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorPayScreen extends StatefulWidget {
  static const route_name = "razor_pay_screen";

  @override
  _RazorPayScreenState createState() => _RazorPayScreenState();
}

class _RazorPayScreenState extends State<RazorPayScreen> {
  Razorpay _razorPay;
  var _currentSelected = 0;

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Do something when payment succeeds
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print(response.message);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet was selected
  }

  @override
  void initState() {
    super.initState();
    _razorPay = Razorpay();
    _razorPay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorPay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorPay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    _razorPay.clear();
  }

  void _setupRazorPayOptions() {
    var options = {
      'key': AppConstants.RAZOR_PAY_TEST_ID,
      'amount': 100,
      'name': StringConstant.APP_NAME,
      'description': 'Donating',
      'prefill': {'email': 'test@razorpay.com'}
    };
    _razorPay.open(options);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        title: Text(
          "Donate",
          style: GoogleFonts.asap(),
        ),
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
          ],
        ),
      ),
    );
  }
}
