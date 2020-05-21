import 'package:flutter/material.dart';
import 'package:theoffer/models/payment_methods.dart';
import 'package:theoffer/scoped-models/main.dart';
import 'package:theoffer/screens/order_response.dart';
import 'package:theoffer/screens/payubiz.dart';
import 'package:theoffer/screens/listagemEnderecoPedido.dart';
import 'package:theoffer/utils/connectivity_state.dart';
import 'package:theoffer/utils/locator.dart';
import 'package:theoffer/utils/constants.dart';
import 'package:theoffer/widgets/snackbar.dart';
import 'package:theoffer/screens/update_address.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TelaFinalizarPedido extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FinalizarPedido();
  }
}

class _FinalizarPedido extends State<TelaFinalizarPedido> {
  Size _deviceSize;
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
    //checkShipmentAvailability();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    locator<ConnectivityManager>().dispose();
  }
/*
  checkShipmentAvailability() async {
    bool _isShippableResponse = await _model.shipmentAvailability(
        pincode: ScopedModel.of<MainModel>(context, rebuildOnChange: false)
            .pedido
            .shipAddress
            .pincode);
    setState(() {
      _isShippable = _isShippableResponse;
    });
  }*/

// In the State of a stateful widget:
  @override
  Widget build(BuildContext context) {
    _deviceSize = MediaQuery.of(context).size;
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return 
      WillPopScope(
        onWillPop: _canGoBack,
        child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Colors.principalTheOffer),
                onPressed: () => Navigator.of(context).pop(),
              ),
            title: Text('Pedido',
            style: TextStyle(color: Colors.principalTheOffer)
            ),
            bottom: model.isLoading || _isLoading
                ? PreferredSize(
                    child: LinearProgressIndicator(),
                    preferredSize: Size.fromHeight(10),
                  )
                : PreferredSize(
                    child: Container(),
                    preferredSize: Size.fromHeight(10),
                  )
        ),
        body: _isLoading
            ? Container()
            : Container (
                color: Colors.terciariaTheOffer,
                child: CustomScrollView(slivers: [ 
                  SliverToBoxAdapter(
                    child: Container(
                      height: _deviceSize.height * 0.45,
                      child:  CustomScrollView(
                          slivers: <Widget>[
                            itensPedido(),
                          ],
                      )
                    )
                  ),
                  model.pedido.endereco != null
                  ? SliverToBoxAdapter(
                    child: Card(
                  child: Container(
                    height: 90,
                    color: Colors.principalTheOffer,
                    child: GestureDetector(
                      onTap: () {
                        
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Container(
                                      width: 250,
                                      child: RichText(
                                        text: TextSpan(
                                            text: model.pedido.endereco.nome,
                                            style: TextStyle(
                                                color: Colors.secundariaTheOffer,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Container(
                                            alignment: Alignment.centerRight,
                                            child: IconButton(
                                              iconSize: 24,
                                              color: Colors.secundariaTheOffer,
                                              icon: Icon(Icons.edit),
                                              onPressed: () {
                                                  MaterialPageRoute route =
                                                      MaterialPageRoute(builder: (context) => ListagemEnderecoPedido());

                                                  Navigator.push(context, route);
                                              },
                                            ),
                                          ),
                                        ]
                                      )
                                    ), 
                                  ],
                                ),
                              ),
                              Container(
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                      alignment: Alignment.topLeft,
                                      child: RichText(
                                          text: TextSpan(
                                              text: model.pedido.endereco.rua + ', ' + model.pedido.endereco.numero.toString(),
                                              style: TextStyle(
                                                  color: Colors.secundariaTheOffer,
                                                  fontSize: 15.0
                                              ),
                                          )
                                      ),
                                    ),
                                  ]
                                )
                              ),
                              Container(
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                    alignment: Alignment.topLeft,
                                    child: RichText(
                                        text: TextSpan(
                                            text: model.pedido.endereco.cidade.nome + ', Bairro ' + model.pedido.endereco.bairro.nome,
                                            style: TextStyle(
                                                color: Colors.secundariaTheOffer,
                                                fontSize: 15.0, 
                                                fontWeight: FontWeight.bold),
                                          ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                  ]
                                )
                              ),
                            ],
                          )),
                        ],
                      ),
                    ),
                  ),
                )
              )
              : SliverToBoxAdapter(
                    child: Container()
                ),
                  SliverToBoxAdapter(
                    child: Padding(padding: EdgeInsets.only(top: 0),
                      child: model.pedido == null
                      ? Container()
                      : Container(
                          color: Colors.principalTheOffer,
                          margin: EdgeInsets.all(5),
                          child: Column(
                            children: <Widget>[
                              linhaTotal('Mercadorias:', model.pedido.somaValorTotalPedido().toString(), model),
                              linhaTotal('Entrega:', '1', model),
                              linhaTotal('Taxas:', '1', model),  
                              linhaTotal('Total do pedido:', model.pedido.somaValorTotalPedido().toString(), model)
                            ],
                        ),
                      ),
                    )
                  ),
                ])
            ),
        bottomNavigationBar: !_isLoading ? paymentButton(context) : Container(),
      ),
      )
      ;
    });
  }

  Widget itensPedido() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return SliverList(
          delegate:
              SliverChildBuilderDelegate((BuildContext context, int index) {
            return GestureDetector(
                onTap: () {},
                child: Card(
                  child: Container(
                    height: 40,
                    color: Colors.secundariaTheOffer,
                    child: GestureDetector(
                      onTap: () {},
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Container(
                                      width: 200,
                                      child: RichText(
                                        text: TextSpan(children: [
                                          TextSpan(
                                            text:
                                                '${model.pedido.listaItensPedido[index].produto.titulo.split(' ')[0]} ',
                                            style: TextStyle(
                                                color: Colors.principalTheOffer,
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          TextSpan(
                                            text: model.pedido.listaItensPedido[index].produto.titulo,
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.principalTheOffer),
                                          ),
                                        ]),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(
                                height: 1.0,
                                color: Colors.principalTheOffer,
                              ),
                              Container(
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      'Valor: ' + model.pedido.listaItensPedido[index].produto.valor,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          color: Colors.principalTheOffer,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 100,
                                    ),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                                Container(
                                                  alignment: Alignment.centerRight,
                                                  child: Text(
                                                    'Quantidade: ' + model.pedido.listaItensPedido[index].quantidade.toString(),
                                                    textAlign: TextAlign.right,
                                                    style: TextStyle(
                                                        color: Colors.principalTheOffer,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16),
                                                  ),
                                                )
                                        ]
                                      )
                                    ), 
                                    SizedBox(
                                      width: 10,
                                    ),
                                  ]
                                )
                              ),
                            ],
                          )),
                        ],
                      ),
                    ),
                  ),
                )
              );
          }, childCount: model.pedido.listaItensPedido.length),
        );
      },
    );
  }

   Future<bool> _canGoBack() {
     print("Voltar");
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
        color: Colors.terciariaTheOffer,
        padding: EdgeInsets.all(5),
        child: model.isLoading
            ? Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.secundariaTheOffer,
                ),
              )
            : FlatButton(
                color: Colors.secundariaTheOffer,
                child: Text(
                  _character == ''
                      ? 'PAGAMENTO'
                      : _character == 'COD'
                          ? 'PAGAR NA ENTREGA'
                          : 'CONTINUAR PARA O PAGSEGURO',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.principalTheOffer),
                ),
                onPressed: () async {
                  if (_character == 'COD') {
                    if (_isShippable &&
                        model.pedido.somaValorTotalPedido() >=
                            FREE_SHIPPING_AMOUNT) {
                      bool isComplete = false;
                      model.paymentMethods.forEach((paymentMethodObj) async {
                        if (paymentMethodObj.name == 'COD') {
                          setState(() {
                            selectedPaymentId = paymentMethodObj.id;
                          });
                        }
                      });/*
                      isComplete = await model.completeOrder(selectedPaymentId);
                      if (isComplete) {
                        bool isChanged = false;

                        if (model.pedido.state == ) {
                          isChanged = await model.changeState();
                        }
                        if (isChanged) {
                          pushSuccessPage();
                        }
                      }*/
                    } else {
                      if (model.pedido.somaValorTotalPedido() <
                          FREE_SHIPPING_AMOUNT) {
                        _scaffoldKey.currentState.showSnackBar(insufficientAmt);
                      } else if (!_isShippable) {
                        final invalidPincode = SnackBar(
                          content: Text('COD not available for this Pincode'),
                          duration: Duration(seconds: 3),
                          action: SnackBarAction(
                            label: 'CHANGE',
                            onPressed: () {/*
                              MaterialPageRoute route = MaterialPageRoute(
                                  builder: (context) => UpdateAddress(
                                      model.pedido.endereco, true));
                              Navigator.pushReplacement(context, route);*/
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
                    /*isComplete = await model.finalizarPedido(selectedPaymentId);
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
                    }*/
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
  
Widget linhaTotal(
    String title, String displayAmount, MainModel model) {
  return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Container(
      padding: EdgeInsets.all(5),
      child: Text(
        title,
        style: TextStyle(color: Colors.secundariaTheOffer, 
          fontWeight: FontWeight.bold),
        
      ),
    ),
    Container(
      padding: EdgeInsets.all(5),
      child: Text(
        displayAmount == null ? '' : displayAmount,
        style: TextStyle(
          fontSize: 17,
          color: Colors.secundariaTheOffer,
          fontWeight: FontWeight.bold
        ),
      ),
    )
  ]);
}

}
