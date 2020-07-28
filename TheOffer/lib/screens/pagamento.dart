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


enum FormaPagamentoRecebimento { dinheiro, cartao }

class _TelaPagamento extends State<TelaPagamento> {
  bool _proceedPressed = false;
  Map<dynamic, dynamic> responseBody;
  bool _isLoading = false;
  bool pagamentoEntregaVisivel = false;
  bool pagamentoBalcaoVisivel = false;
  double frete = 0;
  FormaPagamentoRecebimento formaPagamentoRecebimentoSelecionada = FormaPagamentoRecebimento.dinheiro;
  int selectedPaymentId;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    getFretes();
    locator<ConnectivityManager>().initConnectivity(context);
  }

  @override
  void dispose() {
    super.dispose();
    locator<ConnectivityManager>().dispose();
  }
  
  @override
  Widget build(BuildContext context) {
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
                    child: Padding(padding: EdgeInsets.only(top: 0),
                      child: widget.pedido == null
                      ? Container()
                      : Container(
                          color: Colors.secundariaTheOffer,
                          margin: EdgeInsets.only(top: 5, right: 5, left: 5, bottom: 5),
                          child: Column(
                            children: <Widget>[
                              linhaTotal('Mercadorias:', widget.pedido.somaValorTotalPedido().toString()),
                              linhaTotal('Frete:', frete.toString()),
                              linhaTotal('Taxas:', '1'),  
                              linhaTotal('Total do pedido:', widget.pedido.somaValorTotalPedido().toString())
                            ],
                        ),
                      ),
                    )
                  ),
                  SliverToBoxAdapter(
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                            children: [
                              pagamentoEntrega(context),
                              retirarLocal(context)
                            ]
                        )
                  ),
                  //Pagamento na entrega
                  SliverToBoxAdapter(
                    child: Visibility (
                      visible: pagamentoEntregaVisivel,
                      child: Container(
                             margin: EdgeInsets.only(right: 29, left: 29),
                             height: 112,
                             color: Colors.secundariaTheOffer,
                             child: Column(
                              children: <Widget>[
                                ListTile(
                                  title: 
                                    const Text('Dinheiro',
                                               style: TextStyle(color: Colors.principalTheOffer
                                            )
                                          ),
                                    leading: Radio(
                                      value: FormaPagamentoRecebimento.dinheiro,
                                      groupValue: formaPagamentoRecebimentoSelecionada,
                                      onChanged: (FormaPagamentoRecebimento value) {
                                        setState(() {
                                          formaPagamentoRecebimentoSelecionada = value;
                                        });
                                      },
                                    ),
                                ),
                                ListTile(
                                  title: 
                                    const Text('Cartão',
                                               style: TextStyle(color: Colors.principalTheOffer
                                            )
                                          ),
                                    leading: Radio(
                                      value: FormaPagamentoRecebimento.cartao,
                                      groupValue: formaPagamentoRecebimentoSelecionada,
                                      activeColor: Colors.principalTheOffer,
                                      onChanged: (FormaPagamentoRecebimento value) {
                                        setState(() {
                                          formaPagamentoRecebimentoSelecionada = value;
                                        });
                                      },
                                    ),
                                ),
                            ])
                      )
                    )
                  ),
                  //Retirar no local
                  SliverToBoxAdapter(
                    child: Visibility (
                      visible: pagamentoBalcaoVisivel,
                      child: Container(
                             height: 112,
                             margin: EdgeInsets.only(right: 29, left: 29),
                             color: Colors.secundariaTheOffer,
                             child: Align(
                              alignment: Alignment.center,
                              child: Text('O pagamento será efetuado na retirada.',
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.principalTheOffer),
                                    ), 
                            ),
                      )
                    )
                  ),
                ]
                )
            ),
        bottomNavigationBar: !_isLoading ? paymentButton(context) : Container(),
      ),
      )
      ;
    });
  }

   Future<bool> _canGoBack() {
     print("Voltar");
    if (_proceedPressed) {
      return Future<bool>.value(false);
    } else {
      return Future<bool>.value(true);
    }
  }

  Widget pagamentoEntrega(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel widget) {
      return Container(
        color: Colors.terciariaTheOffer,
        margin: EdgeInsets.only(left: 30),
        child: widget.isLoading
            ? Center(
                child: CircularProgressIndicator(
                  backgroundColor: pagamentoEntregaVisivel
                                   ? Colors.secundariaTheOffer
                                   : Colors.principalTheOffer,
                ),
              )
            : FlatButton(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                color: pagamentoEntregaVisivel
                                   ? Colors.secundariaTheOffer
                                   : Colors.principalTheOffer,
                child: Text('PAGAR NA ENTREGA',
                  style: TextStyle(
                      fontSize: 15,
                      color: pagamentoEntregaVisivel
                             ? Colors.principalTheOffer
                             : Colors.secundariaTheOffer),
                ),
                onPressed: () {
                  setState(() {
                    pagamentoEntregaVisivel = true;
                    pagamentoBalcaoVisivel  = false;
                  });
                },
              ),
      );
    });
  }
  
  getFretes() async {
    frete = 0;
    Map<dynamic, dynamic> objetoFrete = Map();
    Map<String, String> headers = getHeaders();
    setState(() {
      _isLoading = true;
    });
    objetoFrete = {
      "empresa": widget.pedido.empresa.toString(), "bairro": widget.pedido.endereco.bairro.id.toString()
    };
    http.post(
            Configuracoes.BASE_URL + 'frete/',
            headers: headers,
            body: objetoFrete)
        .then((response) {
      print("BUSCANDO VALOR DE FRETE");
      print(json.decode(response.body).toString());   
      responseBody = json.decode(response.body);
      setState(() {
        _isLoading = false;
        frete = double.parse(responseBody['fretes'][0]['valor']);       
      });
    });
    setState(() {
      _isLoading = false;
    });
  }
  
                              
  Widget retirarLocal(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel widget) {
      return Container(
        color: Colors.terciariaTheOffer,
        margin: EdgeInsets.only(right: 30),
        child: widget.isLoading
            ? Center(
                child: CircularProgressIndicator(
                  backgroundColor: pagamentoBalcaoVisivel
                                   ? Colors.principalTheOffer
                                   : Colors.secundariaTheOffer,
                ),
              )
            : FlatButton(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                color: pagamentoBalcaoVisivel
                       ? Colors.secundariaTheOffer
                       : Colors.principalTheOffer,
                child: Text('RETIRAR NO LOCAL',
                  style: TextStyle(
                      fontSize: 15,
                      color: pagamentoBalcaoVisivel
                             ? Colors.principalTheOffer
                             : Colors.secundariaTheOffer),
                ),
                onPressed: () {
                  setState(() {
                    pagamentoEntregaVisivel = false;
                    pagamentoBalcaoVisivel  = true;
                  });
                },
              ),
      );
    });
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
                color: Colors.principalTheOffer,
                child: Text('FINALIZAR PEDIDO',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.secundariaTheOffer),
                ),
                onPressed: () async {
                    print("ESTADO DO PEDIDO ___________ ${widget.pedido.status}");
                    Map<dynamic, dynamic> objetoPedido = Map();
                    Map<String, String> headers = getHeaders();
                    if (widget.pedido != null) {
                      if (Autenticacao.codigoUsuario > 0 ) {
                        if (widget.pedido.status == 2) {
                              objetoPedido = {
                                "usuario": Autenticacao.codigoUsuario.toString(), 
                                "pedido": widget.pedido.id.toString(),
                                "modalidadeRecebimento": pagamentoEntregaVisivel
                                                         ? '1'
                                                         : '2',
                                "formaPagamento":        (formaPagamentoRecebimentoSelecionada.index + 1).toString()      
                              };
                              http.post(
                                      Configuracoes.BASE_URL + 'pedido/pagarPedido/',
                                      headers: headers,
                                      body: objetoPedido)
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
        style: TextStyle(color: Colors.principalTheOffer, 
          fontWeight: FontWeight.bold),
        
      ),
    ),
    Container(
      padding: EdgeInsets.all(5),
      child: Text(
        displayAmount == null ? '' : displayAmount,
        style: TextStyle(
          fontSize: 17,
          color: Colors.principalTheOffer,
          fontWeight: FontWeight.bold
        ),
      ),
    )
  ]);
}

}
