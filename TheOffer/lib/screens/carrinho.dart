import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:theoffer/scoped-models/main.dart';
import 'package:theoffer/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:theoffer/screens/auth.dart';
import 'package:theoffer/utils/connectivity_state.dart';
import 'package:theoffer/utils/locator.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:theoffer/utils/ImageHelper.dart';

class Carrinho extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CarrinhoState();
  }
}

class _CarrinhoState extends State<Carrinho> {
  List<int> quantities = [];
  bool stateChanged = false;
  static const _ITEM_HEIGHT = 40;
  @override
  void initState() {
    super.initState();

    locator<ConnectivityManager>().initConnectivity(context);
  }

  @override
  void dispose() {
    // TODO: implement dispose
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
                icon: Icon(Icons.close, color: Colors.principalTheOffer),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text('Carrinho', style: TextStyle(color: Colors.principalTheOffer),),
              bottom: model.isLoading
                  ? PreferredSize(
                      child: LinearProgressIndicator(),
                      preferredSize: Size.fromHeight(10),
                    )
                  : PreferredSize(
                      child: Container(),
                      preferredSize: Size.fromHeight(10),
                    )),
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
                    botaoFinalizarPedido(),
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
        return CustomScrollView(
          slivers: <Widget>[
            items(),
          ],
        );
      },
    );
  }

  Widget itemTotalContainer(MainModel model) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[carrinhoData()],
    );
  }

  Widget carrinhoData() {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
           return Text(
              'Valor total do carrinho (${model.pedido.somaValorTotalPedido()}): ',
              style:  TextStyle(
                      fontSize: 16.5,
                      color: Colors.principalTheOffer,
                      fontWeight: FontWeight.bold),
            );
    });
  }

  Widget botaoFinalizarPedido() {
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
                  child: Text( 'FINALIZAR PEDIDO',
                    style: TextStyle(
                        fontSize: 15,
                        color: Colors.secundariaTheOffer),
                  ),
                  onPressed: () async {
                    print("ESTADO DO PEDIDO ___________ ${model.pedido.status}");
                    Map<dynamic, dynamic> objetoItemPedido = Map();
                    Map<String, dynamic> responseBody;
                    if (model.pedido != null) {
                      if (Autenticacao.CodigoUsuario > 0 ) {
                        if (model.pedido.status == 1) {
                              print("finalizandocarrinho");
                              objetoItemPedido = {
                                "usuario": Autenticacao.CodigoUsuario.toString()
                              };
                              http
                                  .post(
                                      Configuracoes.BASE_URL + 'pedido/finalizarCarrinho/',
                                      body: objetoItemPedido)
                                  .then((response) {
                                print("FINALIZANDO CARRINHO");
                                print(json.decode(response.body).toString());
                                responseBody = json.decode(response.body);

                                /* tela de pagamento 
                                MaterialPageRoute addressRoute =
                                    MaterialPageRoute(
                                        builder: (context) => AddressPage());
                                Navigator.push(context, addressRoute);*/
                              });

                        } else {
                          stateChanged = await model.localizarCarrinho(model.pedido.id, model.pedido.usuarioId);
                          if (stateChanged) {
                            // print('STATE IS CHANGED, FETCH CURRENT ORDER');
                            // model.fetchCurrentOrder();
                            /*
                            MaterialPageRoute addressRoute =
                                MaterialPageRoute(
                                    builder: (context) => AddressPage());
                            Navigator.push(context, addressRoute);*/
                          } else {
                            print("OCORREU UM ERRO AO BUSCAR O PEDIDO");
                          }
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
                                child: FadeInImage(
                                 image: MemoryImage(dataFromBase64String(model.pedido.listaItensPedido[index].produto.imagem)),
                                  placeholder: AssetImage(
                                      'images/placeholders/no-product-image.png'),
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
                                    // Expanded(
                                    // child:
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
                                    // ),
                                    // Expanded(
                                    // child:
                                    Container(
                                      padding: EdgeInsets.only(top: 0),
                                      child: IconButton(
                                        iconSize: 24,
                                        color: Colors.principalTheOffer,
                                        icon: Icon(Icons.close),
                                        onPressed: () {
                                          model.removerProdutoCarrinho(model.pedido.listaItensPedido[index].pedidoId,
                                             Autenticacao.CodigoUsuario,
                                              model.pedido.listaItensPedido[index].produtoId);
                                        },
                                      ),
                                    ),
                                    // )
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
                  if (Autenticacao.CodigoUsuario > 0) {
                    if (model.pedido.listaItensPedido[lineItemIndex].produto.quantidade - model.pedido.listaItensPedido[lineItemIndex].produto.quantidadeRestante + model.pedido.listaItensPedido[lineItemIndex].quantidade >= index) {
                    model.adicionarProduto(
                      usuarioId: Autenticacao.CodigoUsuario,
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
