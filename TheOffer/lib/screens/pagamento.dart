import 'package:flutter/material.dart';
import 'package:theoffer/scoped-models/main.dart';
import 'package:theoffer/screens/order_response.dart';
import 'package:theoffer/screens/listagemEnderecoPedido.dart';
import 'package:theoffer/screens/autenticacao.dart';
import 'package:theoffer/utils/connectivity_state.dart';
import 'package:theoffer/utils/locator.dart';
import 'package:theoffer/utils/constants.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:theoffer/models/Pedido.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:theoffer/utils/headers.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:theoffer/screens/produtos.dart';

class TelaPagamento extends StatefulWidget {
  final Pedido pedido;

  TelaPagamento(this.pedido);
  @override
  State<StatefulWidget> createState() {
    return _TelaPagamento();
  }
}

class _TelaPagamento extends State<TelaPagamento> {
  Size _deviceSize;
  bool _proceedPressed = false;
  bool _isLoading = false;
  //static List<PaymentMethod> paymentMethods = List();
  String _character = '';
  int selectedPaymentId;
  //bool _isShippable = false;
  //final Mainwidget _widget = Mainwidget();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    locator<ConnectivityManager>().initConnectivity(context);
    //checkShipmentAvailability();
  }

  @override
  void dispose() {
    super.dispose();
    locator<ConnectivityManager>().dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    _deviceSize = MediaQuery.of(context).size;
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel widget) {
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
            title: Text('Pagamento',
            style: TextStyle(color: Colors.principalTheOffer)
            ),
            bottom: widget.isLoading || _isLoading
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
                  widget.pedido.endereco != null
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
                                            text: widget.pedido.endereco.nome,
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
                                              text: widget.pedido.endereco.rua + ', ' + widget.pedido.endereco.numero.toString(),
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
                                            text: widget.pedido.endereco.cidade.nome + ', Bairro ' + widget.pedido.endereco.bairro.nome,
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
                      child: widget.pedido == null
                      ? Container()
                      : Container(
                          color: Colors.principalTheOffer,
                          margin: EdgeInsets.all(5),
                          child: Column(
                            children: <Widget>[
                              linhaTotal('Mercadorias:', widget.pedido.somaValorTotalPedido().toString()),
                              linhaTotal('Entrega:', '1'),
                              linhaTotal('Taxas:', '1'),  
                              linhaTotal('Total do pedido:', widget.pedido.somaValorTotalPedido().toString())
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
      builder: (BuildContext context, Widget child, MainModel widget) {
        return SliverList(
          delegate:
              SliverChildBuilderDelegate((BuildContext context, int index) {
            return GestureDetector(
                onTap: () {},
                child: Card(
                  child: Container(
                    height: 58,
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
                                                '${widget.pedido.listaItensPedido[index].produto.titulo.split(' ')[0]} ',
                                            style: TextStyle(
                                                color: Colors.principalTheOffer,
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          TextSpan(
                                            text: widget.pedido.listaItensPedido[index].produto.titulo,
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
                                      'Valor: ' + widget.pedido.listaItensPedido[index].produto.valor,
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
                                                    'Quantidade: ' + widget.pedido.listaItensPedido[index].quantidade.toString(),
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
          }, childCount: widget.pedido.listaItensPedido.length),
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
        builder: (BuildContext context, Widget child, MainModel widget) {
      return Container(
        color: Colors.terciariaTheOffer,
        padding: EdgeInsets.all(5),
        child: widget.isLoading
            ? Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.secundariaTheOffer,
                ),
              )
            : FlatButton(
                color: Colors.secundariaTheOffer,
                child: Text('FINALIZAR PEDIDO',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.principalTheOffer),
                ),
                onPressed: () async {
                  
                    print("ESTADO DO PEDIDO ___________ ${widget.pedido.status}");
                    Map<dynamic, dynamic> objetoItemPedido = Map();
                    Map<String, String> headers = getHeaders();
                    if (widget.pedido != null) {
                      if (Autenticacao.codigoUsuario > 0 ) {
                        if (widget.pedido.status == 2) {
                              objetoItemPedido = {
                                "usuario": Autenticacao.codigoUsuario.toString(), "pedido": widget.pedido.id.toString()
                              };
                              http.post(
                                      Configuracoes.BASE_URL + 'pedido/pagarPedido/',
                                      headers: headers,
                                      body: objetoItemPedido)
                                  .then((response) {
                                print("PAGANDO PEDIDO");
                                print(json.decode(response.body).toString());                                
                                MaterialPageRoute produtosRoute =
                                    MaterialPageRoute(
                                        builder: (context) => TelaProdutos(idCategoria: 0));
                                Navigator.push(context, produtosRoute);
                              });
                        }
                      } else {
                        MaterialPageRoute authRoute = MaterialPageRoute(
                            builder: (context) => Authentication(0));
                        Navigator.push(context, authRoute);
                      }
                    } else {
                      Navigator.popUntil(context,
                          ModalRoute.withName(Navigator.defaultRouteName));
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
    String title, String displayAmount) {
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
