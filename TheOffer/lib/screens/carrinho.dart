/*import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:theoffer/scoped-models/main.dart';
import 'package:theoffer/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:theoffer/screens/autenticacao.dart';
import 'package:theoffer/utils/connectivity_state.dart';
import 'package:theoffer/utils/locator.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:theoffer/screens/finalizarPedido.dart';
import 'package:theoffer/utils/headers.dart';

class Carrinho extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CarrinhoState();
  }
}

class _CarrinhoState extends State<Carrinho> {
  List<int> quantities = [];
  bool stateChanged = false;
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
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
          appBar: AppBar(
              centerTitle: false,
              leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios,
                      color: Colors.principalTheOffer),
                  onPressed: () => {
                        Navigator.of(context).pop(),
                      }),
              title: Text(
                'Carrinho',
                style: TextStyle(color: Colors.principalTheOffer),
              ),
              actions: <Widget>[
                IconButton(
                  iconSize: 30,
                  icon: new Icon(
                    Icons.close,
                    color: Colors.principalTheOffer,
                  ),
                  onPressed: () => {
                    model.deletarPedido(model.pedido.id, 1),
                    Navigator.of(context).pop(),
                  },
                ),
              ],
              bottom: model.isLoading
                  ? PreferredSize(
                      child: LinearProgressIndicator(),
                      preferredSize: Size.fromHeight(10),
                    )
                  : PreferredSize(
                      child: Container(),
                      preferredSize: Size.fromHeight(10),
                    )),
          body: model.isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.secundariaTheOffer,
                  ),
                )
              : body(),
          bottomNavigationBar: BottomAppBar(
            child: !model.isLoading &&
                    model.pedido != null &&
                    model.pedido.listaItensPedido.length > 0
                ? Container(
                    color: Colors.secundariaTheOffer,
                    height: 100,
                    child: Column(children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: itemTotalContainer(model),
                      ),
                      botaoGerarPedido()
                    ]))
                : Container(
                    height: 0,
                  ),
          ));
    });
  }

  Widget botaoDeletar(int index) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Text(
          model.pedido.listaItensPedido[index].produto.quantidade.toString());
    });
  }

  Widget body() {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      if ((!model.isLoading) &&
          (model.pedido != null) &&
          (model.pedido.listaItensPedido.length > 0)) {
        return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/fundoBranco.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: CustomScrollView(
              slivers: <Widget>[
                items(),
              ],
            ));
      } else {
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/fundoBranco.png"),
              fit: BoxFit.cover,
            ),
          ),
          padding: EdgeInsets.only(top: 10),
          child: Align(
            alignment: Alignment.topCenter,
            child: Text(
              'Não foram incluídos itens no carrinho ainda.',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.secundariaTheOffer,
                  fontSize: 20),
            ),
          ),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
        );
      }
    });
  }

  Widget itemTotalContainer(MainModel model) {
    if ((!model.isLoading) &&
        (model.pedido != null) &&
        (model.pedido.listaItensPedido.length > 0)) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[carrinhoData()],
      );
    } else {
      return Container();
    }
  }

  Widget carrinhoData() {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      String valorTotalPedido =
          (model.pedido.somaValorTotalPedido().toString() + '00');

      valorTotalPedido = valorTotalPedido.replaceAll('.', ',');
      valorTotalPedido =
          valorTotalPedido.substring(0, valorTotalPedido.indexOf(',') + 3);

      if (model.pedido != null) {
        return Text(
          'Valor total do carrinho (R\$ $valorTotalPedido): ',
          style: TextStyle(
              fontSize: 16.5,
              color: Colors.principalTheOffer,
              fontWeight: FontWeight.bold),
        );
      } else {
        return Container();
      }
    });
  }

  Widget botaoGerarPedido() {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Padding(
        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 58.0,
          padding: EdgeInsets.all(10),
          child: FlatButton(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
            color: Colors.principalTheOffer,
            child: Text(
              'GERAR PEDIDO',
              style: TextStyle(fontSize: 15, color: Colors.secundariaTheOffer),
            ),
            onPressed: () async {
              Map<String, String> headers = getHeaders();
              print("ESTADO DO PEDIDO ___________ ${model.pedido.status}");
              Map<dynamic, dynamic> objetoItemPedido = Map();
              if (model.pedido != null) {
                if (Autenticacao.codigoUsuario > 0) {
                  print("finalizandocarrinho");
                  objetoItemPedido = {
                    "usuario": Autenticacao.codigoUsuario.toString()
                  };
                  http
                      .post(
                          Configuracoes.BASE_URL + 'pedido/finalizarCarrinho/',
                          headers: headers,
                          body: objetoItemPedido)
                      .then((response) {
                    print("GERANDO CARRINHO");
                    print(json.decode(response.body).toString());
                    model.localizarPedido(
                        model.pedido.id, Autenticacao.codigoUsuario, 2);
                    MaterialPageRoute finalizarPedidoRoute = MaterialPageRoute(
                        builder: (context) => TelaFinalizarPedido());
                    Navigator.push(context, finalizarPedidoRoute);
                  });
                } else {
                  MaterialPageRoute authRoute = MaterialPageRoute(
                      builder: (context) => Authentication(0));
                  Navigator.push(context, authRoute);
                }
              } else {
                Navigator.popUntil(
                    context, ModalRoute.withName(Navigator.defaultRouteName));
              }
            },
          ),
        ),
      );
    });
  }

  Widget items() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return SliverList(
          delegate:
              SliverChildBuilderDelegate((BuildContext context, int index) {
            return GestureDetector(
                onTap: () {},
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 1,
                  margin:
                      EdgeInsets.only(top: 8, bottom: 8, right: 10, left: 10),
                  child: Container(
                    color: Colors.secundariaTheOffer,
                    child: GestureDetector(
                      onTap: () {},
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Stack(
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.all(15),
                                height: 170,
                                width: 180,
                                decoration: BoxDecoration(
                                    color: Colors.secundariaTheOffer,
                                    borderRadius: BorderRadius.circular(5)),
                                child: CachedNetworkImage(
                                    imageUrl: model
                                        .pedido
                                        .listaItensPedido[index]
                                        .produto
                                        .imagem),
                              ),
                            ],
                          ),
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
                                      padding: EdgeInsets.only(top: 10),
                                      width: 120,
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
                                            text: model
                                                .pedido
                                                .listaItensPedido[index]
                                                .produto
                                                .titulo
                                                .substring(
                                                    model
                                                            .pedido
                                                            .listaItensPedido[
                                                                index]
                                                            .produto
                                                            .titulo
                                                            .indexOf(' ') +
                                                        1,
                                                    model
                                                        .pedido
                                                        .listaItensPedido[index]
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
                                    Container(
                                      child: IconButton(
                                        iconSize: 24,
                                        color: Colors.principalTheOffer,
                                        icon: Icon(Icons.close),
                                        onPressed: () {
                                          model.removerProdutoCarrinho(
                                              model
                                                  .pedido
                                                  .listaItensPedido[index]
                                                  .pedidoId,
                                              Autenticacao.codigoUsuario,
                                              model
                                                  .pedido
                                                  .listaItensPedido[index]
                                                  .produtoId);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              model.pedido.listaItensPedido[index].sabores != ""
                                  ? Column(children: <Widget>[
                                      Container(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          'Sabores: ' +
                                              model
                                                  .pedido
                                                  .listaItensPedido[index]
                                                  .sabores,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              color: Colors.principalTheOffer,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12),
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                    ])
                                  : Container(),
                              Container(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  model.pedido.listaItensPedido[index].produto
                                      .valor,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      color: Colors.principalTheOffer,
                                      fontSize: 18),
                                ),
                              ),
                              model.pedido.listaItensPedido[index].sabores == ""
                                  ? SizedBox(height: 35)
                                  : Container(),
                              quantityRow(model, index),
                            ],
                          )),
                        ],
                      ),
                    ),
                  ),
                ));
          }, childCount: model.pedido.listaItensPedido.length),
        );
      },
    );
  }

  Widget quantityRow(MainModel model, int lineItemIndex) {
    print(
        "QUANTIDADE DE ITENS NO CARRINHO, ${model.pedido.somaQuantidadePedido()}");
    return Container(
        height: 60,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 20,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return Container();
            } else {
              return GestureDetector(
                onTap: () {
                  if (Autenticacao.codigoUsuario > 0) {
                    if (model.pedido.listaItensPedido[lineItemIndex].produto
                                .quantidade -
                            model.pedido.listaItensPedido[lineItemIndex].produto
                                .quantidadeRestante +
                            model.pedido.listaItensPedido[lineItemIndex]
                                .quantidade >=
                        index) {
                      /*model.adicionarProduto(
                          usuarioId: Autenticacao.codigoUsuario,
                          produtoId: model
                              .pedido.listaItensPedido[lineItemIndex].produtoId,
                          quantidade: index,
                          somar: 0);*/

                      model.pegarCupom(
                          usuarioId: Autenticacao.codigoUsuario,
                          produtoId: model
                              .pedido.listaItensPedido[lineItemIndex].produtoId,
                          context: context);
                    }
                  } else {
                    MaterialPageRoute authRoute = MaterialPageRoute(
                        builder: (context) => Authentication(0));
                    Navigator.push(context, authRoute);
                  }
                },
                child: Container(
                    width: 40,
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: model.pedido.listaItensPedido[lineItemIndex]
                                      .quantidade ==
                                  index
                              ? Colors.white //Quantidade
                              : Colors.principalTheOffer,
                        ),
                        borderRadius: BorderRadius.circular(5)),
                    alignment: Alignment.center,
                    margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    child: Text(
                      index.toString(),
                      style: TextStyle(
                        color: model.pedido.listaItensPedido[lineItemIndex]
                                    .quantidade ==
                                index
                            ? Colors.white //Quantidade
                            : Colors.principalTheOffer,
                      ),
                    )),
              );
            }
          },
        ));
  }
}
*/
