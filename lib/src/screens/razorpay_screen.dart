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
      body: Center(
        child: RaisedButton(
          onPressed: () {
            var options = {
              'key': AppConstants.RAZOR_PAY_TEST_ID,
              'amount': 100,
              'name': StringConstant.APP_NAME,
              'description': 'Donating',
              'prefill': {'contact': '8888888888', 'email': 'test@razorpay.com'}
            };
            _razorPay.open(options);
          },
          child: Text('Pay Test'),
        ),
      ),
    );
  }
}
