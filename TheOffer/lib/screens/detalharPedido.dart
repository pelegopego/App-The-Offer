import 'package:flutter/material.dart';
import 'package:theoffer/scoped-models/main.dart';
import 'package:theoffer/utils/connectivity_state.dart';
import 'package:theoffer/utils/locator.dart';
import 'package:theoffer/models/Pedido.dart';
import 'package:theoffer/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:scoped_model/scoped_model.dart';
import 'package:theoffer/utils/headers.dart';
import 'dart:convert';

class DetalharPedido extends StatefulWidget {
  final Pedido pedido;

  DetalharPedido(this.pedido);
  @override
  State<StatefulWidget> createState() {
    return _DetalharPedido();
  }
}

class _DetalharPedido extends State<DetalharPedido> {
  double frete;
  Size _deviceSize;
  Map<dynamic, dynamic> responseBody;

  @override
  void initState() {
    super.initState();
    locator<ConnectivityManager>().initConnectivity(context);
    if (frete == null) {
      getFretes();
    }
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
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
        appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.principalTheOffer),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text('Pedido',
                style: TextStyle(color: Colors.principalTheOffer)),
            bottom: PreferredSize(
              child: Container(),
              preferredSize: Size.fromHeight(10),
            )),
        body: Container(
            color: Colors.terciariaTheOffer,
            child: CustomScrollView(slivers: [
              SliverToBoxAdapter(
                  child: Container(
                      height: _deviceSize.height * 0.50,
                      child: CustomScrollView(
                        slivers: <Widget>[
                          itensPedido(),
                        ],
                      ))),
              widget.pedido.endereco != null
                  ? SliverToBoxAdapter(
                      child: Card(
                      child: Container(
                        height: 60,
                        color: Colors.principalTheOffer,
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Container(
                                        width: 250,
                                        child: RichText(
                                          text: TextSpan(
                                            text: widget.pedido.endereco.nome,
                                            style: TextStyle(
                                                color:
                                                    Colors.secundariaTheOffer,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                    child: Row(children: <Widget>[
                                  Container(
                                    alignment: Alignment.topLeft,
                                    child: RichText(
                                        text: TextSpan(
                                      text: widget.pedido.endereco.rua +
                                          ', ' +
                                          widget.pedido.endereco.numero
                                              .toString(),
                                      style: TextStyle(
                                          color: Colors.secundariaTheOffer,
                                          fontSize: 15.0),
                                    )),
                                  ),
                                ])),
                                Container(
                                    child: Row(children: <Widget>[
                                  Container(
                                    alignment: Alignment.topLeft,
                                    child: RichText(
                                      text: TextSpan(
                                        text: widget
                                                .pedido.endereco.cidade.nome +
                                            ', Bairro ' +
                                            widget.pedido.endereco.bairro.nome,
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
                                ])),
                              ],
                            )),
                          ],
                        ),
                      ),
                    ))
                  : SliverToBoxAdapter(child: Container()),
              SliverToBoxAdapter(
                  child: Padding(
                padding: EdgeInsets.only(top: 0),
                child: widget.pedido == null
                    ? Container()
                    : Container(
                        color: Colors.principalTheOffer,
                        margin: EdgeInsets.all(5),
                        child: Column(
                          children: <Widget>[
                            linhaTotal(
                                'Mercadorias:',
                                widget.pedido
                                    .somaValorTotalPedido()
                                    .toString()),
                            linhaTotal('Frete:', frete.toString()),
                            linhaTotal(
                                'Total do pedido:',
                                (widget.pedido.somaValorTotalPedido() + frete)
                                    .toString())
                          ],
                        ),
                      ),
              )),
              SliverToBoxAdapter(
                child: Card(
                  child: Container(
                    height: 40,
                    color: Colors.secundariaTheOffer,
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
                                child: Row(children: <Widget>[
                              Container(
                                alignment: Alignment.topLeft,
                                child: RichText(
                                    text: TextSpan(
                                  text: widget.pedido.modalidadeEntrega == 1
                                      ? 'Entrega: delivery'
                                      : 'Entrega: retirou no local',
                                  style: TextStyle(
                                      color: Colors.principalTheOffer,
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold),
                                )),
                              ),
                            ])),
                            Container(
                                child: Row(children: <Widget>[
                              Container(
                                alignment: Alignment.topLeft,
                                child: RichText(
                                  text: TextSpan(
                                    text: widget.pedido.modalidadeEntrega == 1
                                        ? widget.pedido.formaPagamento == 1
                                            ? 'Pagamento: dinheiro'
                                            : 'Pagamento: cartao'
                                        : 'Pagou no balcão',
                                    style: TextStyle(
                                        color: Colors.principalTheOffer,
                                        fontSize: 15.0),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                            ])),
                          ],
                        )),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Card(
                  child: Container(
                    height: 20,
                    color: Colors.secundariaTheOffer,
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
                                child: Row(children: <Widget>[
                              Container(
                                alignment: Alignment.topLeft,
                                child: RichText(
                                    text: TextSpan(
                                  text: widget.pedido.status >= 4
                                      ? 'Previsão de entrega: ' +
                                          widget.pedido.horaPrevista
                                      : 'Aguardando confirmação',
                                  style: TextStyle(
                                      color: Colors.principalTheOffer,
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold),
                                )),
                              ),
                            ])),
                          ],
                        )),
                      ],
                    ),
                  ),
                ),
              ),
            ])),
      );
    });
  }

  getFretes() async {
    frete = 0;
    Map<dynamic, dynamic> objetoFrete = Map();
    Map<String, String> headers = getHeaders();
    objetoFrete = {
      "empresa": widget.pedido.empresa.toString(),
      "bairro": widget.pedido.endereco.bairro.id.toString()
    };
    http
        .post(Configuracoes.BASE_URL + 'frete/',
            headers: headers, body: objetoFrete)
        .then((response) {
      print("BUSCANDO VALOR DE FRETE");
      print(json.decode(response.body).toString());
      responseBody = json.decode(response.body);
      if (responseBody['possuiFrete'] == true) {
        frete = double.parse(responseBody['fretes'][0]['valor']);
      }
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Container(
                                      width: 250,
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
                                            text: widget
                                                .pedido
                                                .listaItensPedido[index]
                                                .produto
                                                .titulo,
                                            style: TextStyle(
                                                fontSize: 15,
                                                color:
                                                    Colors.principalTheOffer),
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
                                  child: Row(children: <Widget>[
                                Container(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    'Valor: ' +
                                        widget.pedido.listaItensPedido[index]
                                            .produto.valor,
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                      Container(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          'Quantidade: ' +
                                              widget
                                                  .pedido
                                                  .listaItensPedido[index]
                                                  .quantidade
                                                  .toString(),
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                              color: Colors.principalTheOffer,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                      )
                                    ])),
                                SizedBox(
                                  width: 10,
                                ),
                              ])),
                            ],
                          )),
                        ],
                      ),
                    ),
                  ),
                ));
          }, childCount: widget.pedido.listaItensPedido.length),
        );
      },
    );
  }

  Widget paymentButton(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Container(
        color: Colors.terciariaTheOffer,
        padding: EdgeInsets.all(5),
        child: Container(
          color: Colors.secundariaTheOffer,
          child: Text(
            'PAGAMENTO',
            style: TextStyle(fontSize: 20, color: Colors.principalTheOffer),
          ),
        ),
      );
    });
  }

  Widget linhaTotal(String title, String displayAmount) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Container(
        padding: EdgeInsets.all(5),
        child: Text(
          title,
          style: TextStyle(
              color: Colors.secundariaTheOffer, fontWeight: FontWeight.bold),
        ),
      ),
      Container(
        padding: EdgeInsets.all(5),
        child: Text(
          displayAmount == null ? '' : displayAmount,
          style: TextStyle(
              fontSize: 17,
              color: Colors.secundariaTheOffer,
              fontWeight: FontWeight.bold),
        ),
      )
    ]);
  }
}
