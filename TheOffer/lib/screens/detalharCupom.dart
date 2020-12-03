import 'package:flutter/material.dart';
import 'package:theoffer/scoped-models/main.dart';
import 'package:theoffer/utils/connectivity_state.dart';
import 'package:theoffer/utils/locator.dart';
import 'package:theoffer/models/Cupom.dart';
//import 'package:theoffer/utils/constants.dart';
//import 'package:http/http.dart' as http;
import 'package:scoped_model/scoped_model.dart';
//import 'package:theoffer/utils/headers.dart';
//import 'dart:convert';

class DetalharCupom extends StatefulWidget {
  final Cupom cupom;

  DetalharCupom(this.cupom);
  @override
  State<StatefulWidget> createState() {
    return _DetalharCupom();
  }
}

class _DetalharCupom extends State<DetalharCupom> {
  Size _deviceSize;
  Map<dynamic, dynamic> responseBody;

  @override
  void initState() {
    super.initState();
    locator<ConnectivityManager>().initConnectivity(context);
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
      String valorTotalCupomString =
          (widget.cupom.somaValorTotalCupom().toString() + '00');
      String somaTotalCupomString =
          ((widget.cupom.somaValorTotalCupom()).toString() + '00');
      valorTotalCupomString = valorTotalCupomString.replaceAll('.', ',');
      valorTotalCupomString = valorTotalCupomString.substring(
          0, valorTotalCupomString.indexOf(',') + 3);

      somaTotalCupomString = somaTotalCupomString.replaceAll('.', ',');
      somaTotalCupomString = somaTotalCupomString.substring(
          0, somaTotalCupomString.indexOf(',') + 3);

      return Scaffold(
        appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.principalTheOffer),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text('Cupom',
                style: TextStyle(color: Colors.principalTheOffer)),
            bottom: PreferredSize(
              child: Container(),
              preferredSize: Size.fromHeight(10),
            )),
        body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/fundoBranco.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: CustomScrollView(slivers: [
              SliverToBoxAdapter(
                  child: Container(
                      height: _deviceSize.height * 0.50,
                      child: CustomScrollView(
                        slivers: <Widget>[
                          itensCupom(),
                        ],
                      ))),
              widget.cupom.endereco != null
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
                                            text: widget.cupom.endereco.nome,
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
                                      text: widget.cupom.endereco.rua +
                                          ', ' +
                                          widget.cupom.endereco.numero
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
                                                .cupom.endereco.cidade.nome +
                                            ', Bairro ' +
                                            widget.cupom.endereco.bairro.nome,
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
            ])),
        bottomNavigationBar:
            totalCupom(widget.cupom, somaTotalCupomString, context),
      );
    });
  }

  Widget totalCupom(Cupom cupom, String valorTotal, BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel widget) {
      return Container(
        child: Padding(
          padding: EdgeInsets.only(top: 0),
          child: cupom == null
              ? Container()
              : Container(
                  color: Colors.principalTheOffer,
                  margin: EdgeInsets.all(5),
                  child: linhaTotal('Total do cupom:', valorTotal)),
        ),
      );
    });
  }

  Widget itensCupom() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return SliverList(
          delegate:
              SliverChildBuilderDelegate((BuildContext context, int index) {
            return GestureDetector(
                onTap: () {},
                child: Card(
                  child: Container(
                    height: widget.cupom.listaItensCupom[index].sabores != ""
                        ? 58
                        : 43,
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
                                                '${widget.cupom.listaItensCupom[index].produto.titulo.split(' ')[0]} ',
                                            style: TextStyle(
                                                color: Colors.principalTheOffer,
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          TextSpan(
                                            text: widget
                                                .cupom
                                                .listaItensCupom[index]
                                                .produto
                                                .titulo
                                                .substring(
                                                    widget
                                                            .cupom
                                                            .listaItensCupom[
                                                                index]
                                                            .produto
                                                            .titulo
                                                            .indexOf(' ') +
                                                        1,
                                                    widget
                                                        .cupom
                                                        .listaItensCupom[index]
                                                        .produto
                                                        .titulo
                                                        .length),
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
                              widget.cupom.listaItensCupom[index].sabores != ""
                                  ? Container(
                                      child: Row(children: <Widget>[
                                      Container(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          'Sabores: ' +
                                              widget
                                                  .cupom
                                                  .listaItensCupom[index]
                                                  .sabores,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              color: Colors.principalTheOffer,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12),
                                        ),
                                      ),
                                    ]))
                                  : Container(),
                              Container(
                                  child: Row(children: <Widget>[
                                Container(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    'Valor: ' +
                                        widget.cupom.listaItensCupom[index]
                                            .produto.valor,
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        color: Colors.principalTheOffer,
                                        fontSize: 16),
                                  ),
                                ),
                                SizedBox(
                                  width: 90,
                                ),
                                Expanded(
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                      Container(
                                        padding: EdgeInsets.only(right: 5),
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          'Quantidade: ' +
                                              widget
                                                  .cupom
                                                  .listaItensCupom[index]
                                                  .quantidade
                                                  .toString(),
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                              color: Colors.principalTheOffer,
                                              fontSize: 16),
                                        ),
                                      )
                                    ])),
                                widget.cupom.listaItensCupom[index].sabores !=
                                        ""
                                    ? SizedBox(
                                        width: 5,
                                      )
                                    : Container(),
                              ])),
                            ],
                          )),
                        ],
                      ),
                    ),
                  ),
                ));
          }, childCount: widget.cupom.listaItensCupom.length),
        );
      },
    );
  }

  Widget paymentButton(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Container(
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
