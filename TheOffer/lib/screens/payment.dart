import 'package:flutter/material.dart';
import 'package:theoffer/models/payment_methods.dart';
import 'package:theoffer/scoped-models/main.dart';
import 'package:theoffer/screens/order_response.dart';
import 'package:theoffer/screens/payubiz.dart';
import 'package:theoffer/utils/connectivity_state.dart';
import 'package:theoffer/utils/locator.dart';
import 'package:theoffer/utils/params.dart';
import 'package:theoffer/utils/constants.dart';
import 'package:theoffer/widgets/order_details_card.dart';
import 'package:theoffer/widgets/snackbar.dart';
import 'package:theoffer/screens/update_address.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Paymenttelastate();
  }
}

class _Paymenttelastate extends State<PaymentScreen> {
  bool _proceedPressed = false;
  bool _isLoading = false;
  static List<PaymentMethod> paymentMethods = List();
  String _character = '';
  int selectedPaymentId;
  bool _isShippable = false;
  final MainModel _model = MainModel();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    locator<ConnectivityManager>().initConnectivity(context);
    checkShipmentAvailability();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    locator<ConnectivityManager>().dispose();
  }

  checkShipmentAvailability() async {
    bool _isShippableResponse = await _model.shipmentAvailability(
        pincode: ScopedModel.of<MainModel>(context, rebuildOnChange: false)
            .order
            .shipAddress
            .pincode);
    setState(() {
      _isShippable = _isShippableResponse;
    });
  }

// In the State of a stateful widget:
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return 
      WillPopScope(
        onWillPop: _canGoBack,
        child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
            title: Text('Métodos de pagamento'),
            bottom: model.isLoading || _isLoading
                ? PreferredSize(
                    child: LinearProgressIndicator(),
                    preferredSize: Size.fromHeight(10),
                  )
                : PreferredSize(
                    child: Container(),
                    preferredSize: Size.fromHeight(10),
                  )),
        body: _isLoading
            ? Container()
            : ListView.builder(
                itemCount: model.paymentMethods.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index == 2) {
                    print("SHOW ORDER DETAIL CARD ${model.paymentMethods.length}");
                    return Padding(padding: EdgeInsets.only(top: 200),child: orderDetailCard());
                  } else {
                    return paymentMethodsRadioButton(index);
                  }
                  // print("INDEXXX $index");
                },
              ),
        bottomNavigationBar: !_isLoading ? paymentButton(context) : Container(),
      ),
      )
      ;
    });
  }

  paymentMethodsRadioButton(int index) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return RadioListTile<String>(
        title: Text(model.paymentMethods[index].name),
        value: model.paymentMethods[index].name,
        groupValue: _character,
        onChanged: (value) {
          setState(() {
            _character = value;
          });
        },
        activeColor: Colors.secundariaTheOffer,
      );
    });
  }

   Future<bool> _canGoBack() {
     print("BACK PRESSED");
    if (_proceedPressed) {
      return Future<bool>.value(false);
    } else {
      return Future<bool>.value(true);
    }
  }

  Widget paymentButton(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Container(
        padding: EdgeInsets.all(20),
        child: model.isLoading
            ? Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.secundariaTheOffer,
                ),
              )
            : FlatButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                color: Colors.secundariaTheOffer,
                child: Text(
                  _character == ''
                      ? 'SELECIONE O MÉTODO DE PAGAMENTO'
                      : _character == 'COD'
                          ? 'PAGAR NA ENTREGA'
                          : 'CONTINUAR PARA O PAGSEGURO',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w300),
                ),
                onPressed: () async {
                  if (_character == 'COD') {
                    if (_isShippable &&
                        double.parse(model.order.total) >=
                            FREE_SHIPPING_AMOUNT) {
                      bool isComplete = false;
                      model.paymentMethods.forEach((paymentMethodObj) async {
                        if (paymentMethodObj.name == 'COD') {
                          setState(() {
                            selectedPaymentId = paymentMethodObj.id;
                          });
                        }
                      });
                      isComplete = await model.completeOrder(selectedPaymentId);
                      if (isComplete) {
                        bool isChanged = false;

                        if (model.order.state == 'payment') {
                          isChanged = await model.changeState();
                        }
                        if (isChanged) {
                          pushSuccessPage();
                        }
                      }
                    } else {
                      if (double.parse(model.order.total) <
                          FREE_SHIPPING_AMOUNT) {
                        _scaffoldKey.currentState.showSnackBar(insufficientAmt);
                      } else if (!_isShippable) {
                        final invalidPincode = SnackBar(
                          content: Text('COD not available for this Pincode'),
                          duration: Duration(seconds: 3),
                          action: SnackBarAction(
                            label: 'CHANGE',
                            onPressed: () {
                              MaterialPageRoute route = MaterialPageRoute(
                                  builder: (context) => UpdateAddress(
                                      model.order.shipAddress, true));
                              Navigator.pushReplacement(context, route);
                            },
                          ),
                        );
                        _scaffoldKey.currentState.showSnackBar(invalidPincode);
                      }
                    }
                  } else if (_character == 'Payubiz') {
                    setState(() {
                      _proceedPressed = true;
                    });
                    print('PAGSEGURO');
                    bool isComplete = false;
                    // isComplete = await model.completeOrder(paymentMethods.first.id);
                    model.paymentMethods.forEach((paymentMethodObj) async {
                      print(paymentMethodObj.name);
                      if (paymentMethodObj.name == 'Payubiz') {
                        setState(() {
                          selectedPaymentId = paymentMethodObj.id;
                        });
                      }
                    });
                    isComplete = await model.completeOrder(selectedPaymentId);
                    if (isComplete) {
                      print("CONFIRMA");
                      bool isChanged = false;

                      if (model.order.state == 'payment') {
                        print("ESTADO DO PAGAMENTO MUDOU");
                        isChanged = await model.changeState();
                      }
                      if (isChanged) {
                        // pushSuccessPage();
                        String url = await getParams();
                        print(url);
                        MaterialPageRoute payment = MaterialPageRoute(
                            builder: (context) => PayubizScreen(url));
                        Navigator.push(context, payment);
                      }
                    }
                  }
                },
              ),
      );
    });
  }

  pushSuccessPage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String orderNumber = prefs.getString('orderNumber');
    MaterialPageRoute payment = MaterialPageRoute(
        builder: (context) => OrderResponse(orderNumber: orderNumber));
    Navigator.pushAndRemoveUntil(
      context,
      payment,
      ModalRoute.withName('/'),
    );
  }
}
