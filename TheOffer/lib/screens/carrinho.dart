import 'dart:convert';
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
          backgroundColor: Colors.terciariaTheOffer,
          appBar: AppBar(
                centerTitle: false,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: Colors.principalTheOffer),
                  onPressed: () => {
                    Navigator.of(context).pop(),
                  }
                ),
                title: Text('Carrinho', style: TextStyle(color: Colors.principalTheOffer),
              ),
              actions: <Widget>[
                  IconButton(
                  iconSize: 30, 
                  icon: new Icon(
                    Icons.close,
                    color: Colors.principalTheOffer,
                  ),
                  onPressed: () => {
                    model.deletarCarrinho(Autenticacao.codigoUsuario),
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
                    )
               ),
          body: !model.isLoading || model.pedido != null ? body() : Container(),
          bottomNavigationBar: BottomAppBar(
              child: Container(
                  color: Colors.secundariaTheOffer,
                  height: 100,
                  child: Column(children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: itemTotalContainer(model),
                    ),
                    botaoGerarPedido(),
                  ]))));
    });
  }

  Widget botaoDeletar(int index) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Text(model.pedido.listaItensPedido[index].produto.quantidade.toString());
    });
  }

  Widget body() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        if (model.pedido.listaItensPedido.length > 0)  {
            return CustomScrollView(
              slivers: <Widget>[
                items(),
              ],
            );
        } else {
          return Container( child: 
            Text('Não foram selecionados itens para o carrinho',
              style:  TextStyle(
                      fontSize: 16.5, 
                      color: Colors.secundariaTheOffer,
                      fontWeight: FontWeight.bold),
            )
          );
        }
      }
    );
  }

  Widget itemTotalContainer(MainModel model) {
      if (model.pedido != null) { 
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
      if (model.pedido != null) { 
        return Text(
              'Valor total do carrinho (${model.pedido.somaValorTotalPedido()}): ',
              style:  TextStyle(
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
          child: model.isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.secundariaTheOffer,
                  ),
                )
              : FlatButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2)),
                  color: Colors.principalTheOffer,
                  child: Text( 'GERAR PEDIDO',
                    style: TextStyle(
                        fontSize: 15,
                        color: Colors.secundariaTheOffer),
                  ),
                  onPressed: () async {
                    Map<String, String> headers = getHeaders();
                    print("ESTADO DO PEDIDO ___________ ${model.pedido.status}");
                    Map<dynamic, dynamic> objetoItemPedido = Map();
                    //Map<String, dynamic> responseBody;
                    if (model.pedido != null) {
                      if (Autenticacao.codigoUsuario > 0 ) {
                        //if (model.pedido.status == 1) {
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
                                //responseBody = json.decode(response.body);
                                model.localizarPedido(model.pedido.id, Autenticacao.codigoUsuario, 2);
                                  MaterialPageRoute finalizarPedidoRoute =
                                      MaterialPageRoute(
                                          builder: (context) => TelaFinalizarPedido());
                                  Navigator.push(context, finalizarPedidoRoute);
                              });
                        //}
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
                  margin: EdgeInsets.all(8.0),
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
                                color: Colors.secundariaTheOffer,
                                child: Image(
                                 image: NetworkImage(model.pedido.listaItensPedido[index].produto.imagem),
                                ),
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
                                      width: 150,
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
                                    Container(
                                      padding: EdgeInsets.only(top: 0),
                                      child: IconButton(
                                        iconSize: 24,
                                        color: Colors.principalTheOffer,
                                        icon: Icon(Icons.close),
                                        onPressed: () {
                                          model.removerProdutoCarrinho(model.pedido.listaItensPedido[index].pedidoId,
                                             Autenticacao.codigoUsuario,
                                              model.pedido.listaItensPedido[index].produtoId);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10),
                              Container(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  model.pedido.listaItensPedido[index].produto.valor,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      color: Colors.principalTheOffer,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                              ),
                              SizedBox(height: 12),
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
        height: 60.0,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          // itemExtent: 50,
          itemCount: 20,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return Container();
            } else {
              return GestureDetector(
                onTap: () {
                  if (Autenticacao.codigoUsuario > 0) {
                    if (model.pedido.listaItensPedido[lineItemIndex].produto.quantidade - model.pedido.listaItensPedido[lineItemIndex].produto.quantidadeRestante + model.pedido.listaItensPedido[lineItemIndex].quantidade >= index) {
                    model.adicionarProduto(
                      usuarioId: Autenticacao.codigoUsuario,
                      produtoId: model.pedido.listaItensPedido[lineItemIndex].produtoId,
                      quantidade: index,
                      somar: 0
                    );
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
                          color: model.pedido.listaItensPedido[lineItemIndex].quantidade == index
                              ? Colors.white
                              : Colors.principalTheOffer,
                        ),
                        borderRadius: BorderRadius.circular(5)),
                    alignment: Alignment.center,
                    margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    child: Text(
                      index.toString(),
                      style: TextStyle(
                          color: model.pedido.listaItensPedido[lineItemIndex].quantidade == index
                              ? Colors.white
                              : Colors.principalTheOffer,),
                    )),
              );
            }
          },
        ));
  }
}
