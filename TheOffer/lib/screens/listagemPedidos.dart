/*import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:theoffer/scoped-models/main.dart';
import 'package:theoffer/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:theoffer/utils/connectivity_state.dart';
import 'package:theoffer/utils/locator.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:theoffer/models/endereco.dart';
import 'package:theoffer/models/Pedido.dart';
import 'package:theoffer/models/Produto.dart';
import 'package:theoffer/models/itemPedido.dart';
import 'package:theoffer/models/cidade.dart';
import 'package:theoffer/models/bairro.dart';
import 'package:theoffer/screens/detalharPedido.dart';
import 'package:theoffer/utils/headers.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ListagemPedidos extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ListagemPedidos();
  }
}

class _ListagemPedidos extends State<ListagemPedidos> {
  bool _pedidosLoading = true;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  List<Pedido> listaPedidos = [];
  @override
  void initState() {
    super.initState();
    getPedidos();
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
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'Pedidos',
              style: TextStyle(color: Colors.principalTheOffer),
            ),
            bottom: _pedidosLoading
                ? PreferredSize(
                    child: LinearProgressIndicator(),
                    preferredSize: Size.fromHeight(10),
                  )
                : PreferredSize(
                    child: Container(),
                    preferredSize: Size.fromHeight(10),
                  )),
        body: !_pedidosLoading || listaPedidos.length > 0
            ? Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("images/fundoBranco.png"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: body())
            : Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("images/fundoBranco.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
      );
    });
  }

  void _onRefresh() async {
    await getPedidos();
    _refreshController.refreshCompleted();
  }

  Widget body() {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return CustomScrollView(shrinkWrap: true, slivers: <Widget>[
        SliverToBoxAdapter(
            child: Container(
                height: MediaQuery.of(context).size.height * 0.865,
                child: SmartRefresher(
                    enablePullDown: true,
                    enablePullUp: false,
                    controller: _refreshController,
                    onRefresh: _onRefresh,
                    //onLoading: _onLoading,
                    child: CustomScrollView(
                      slivers: <Widget>[
                        items(),
                      ],
                    )))),
      ]);
    });
  }

  Widget items() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return SliverList(
          delegate:
              SliverChildBuilderDelegate((BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                MaterialPageRoute route = MaterialPageRoute(
                    builder: (context) => DetalharPedido(listaPedidos[index]));

                Navigator.push(context, route);
              },
              child: _pedidosLoading
                  ? Container()
                  : Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("images/fundoBranco.png"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Card(
                              child: Container(
                                height: 85,
                                color: Colors.secundariaTheOffer,
                                child: GestureDetector(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                          child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Container(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.30,
                                                  child: RichText(
                                                    text: TextSpan(
                                                      text: 'Pedido ' +
                                                          listaPedidos[index]
                                                              .id
                                                              .toString(),
                                                      style: TextStyle(
                                                          color: Colors
                                                              .principalTheOffer,
                                                          fontSize: 17),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: RichText(
                                                    text: TextSpan(
                                                      text: 'Data ' +
                                                          listaPedidos[index]
                                                              .dataInclusao
                                                              .toString(),
                                                      style: TextStyle(
                                                          color: Colors
                                                              .principalTheOffer,
                                                          fontSize: 14),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                    child: Column(
                                                        children: <Widget>[
                                                      Container(
                                                        alignment: Alignment
                                                            .centerRight,
                                                        child: IconButton(
                                                          iconSize: 17,
                                                          color: Colors
                                                              .principalTheOffer,
                                                          icon: Icon(Icons
                                                              .arrow_forward_ios),
                                                          onPressed: () {
                                                            MaterialPageRoute
                                                                route =
                                                                MaterialPageRoute(
                                                                    builder: (context) =>
                                                                        DetalharPedido(
                                                                            listaPedidos[index]));

                                                            Navigator.push(
                                                                context, route);
                                                          },
                                                        ),
                                                      ),
                                                    ]))
                                              ],
                                            ),
                                          ),
                                          Container(
                                              child: Row(children: <Widget>[
                                            Container(
                                              alignment: Alignment.topLeft,
                                              child: RichText(
                                                  text: TextSpan(
                                                text: 'Itens ' +
                                                    listaPedidos[index]
                                                        .somaQuantidadePedido()
                                                        .toString(),
                                                style: TextStyle(
                                                    color: Colors
                                                        .principalTheOffer,
                                                    fontSize: 12.0),
                                              )),
                                            ),
                                          ])),
                                          Container(
                                              child: Row(children: <Widget>[
                                            Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.50,
                                              alignment: Alignment.topLeft,
                                              child: RichText(
                                                  text: TextSpan(
                                                text: listaPedidos[index]
                                                            .status >=
                                                        4
                                                    ? 'Entrega: ' +
                                                        listaPedidos[index]
                                                            .horaPrevista
                                                    : 'Aguardando confirma????o',
                                                style: TextStyle(
                                                    color: Colors
                                                        .principalTheOffer,
                                                    fontSize: 12.0,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )),
                                            ),
                                            Expanded(
                                              child: Column(children: <Widget>[
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.30,
                                                  color: Colors
                                                      .principalTheOffer,
                                                  alignment: Alignment.center,
                                                  child: RichText(
                                                    text: TextSpan(
                                                      text: getStatus(
                                                          listaPedidos[index]
                                                              .status),
                                                      style: TextStyle(
                                                          color: Colors
                                                              .secundariaTheOffer,
                                                          fontSize: 12.0,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ),
                                              ]),
                                            ),
                                            SizedBox(
                                              width: 20,
                                            )
                                          ]))
                                        ],
                                      )),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ])),
            );
          }, childCount: listaPedidos.length),
        );
      },
    );
  }

  getStatus(int status) {
    if (status == 1) {
      return 'CARRINHO';
    } else if (status == 2) {
      return 'EFETUADO';
    } else if (status == 3) {
      return 'AGUARDANDO';
    } else if (status == 4) {
      return 'CONFIRMADO';
    } else if (status == 5) {
      return 'EM PREPARO';
    } else if (status == 6) {
      return 'SAIU PARA ENTREGA';
    } else if (status == 7) {
      return 'FINALIZADO';
    } else {
      return '';
    }
  }

  getPedidos() async {
    print("LOCALIZANDO PEDIDOS");
    Map<dynamic, dynamic> objetoPedido = Map();
    Map<dynamic, dynamic> responseBody;
    Produto produto;
    Endereco endereco;
    Pedido pedido;
    bool pedidoAdicionado;
    Bairro bairro;
    Cidade cidade;
    Map<String, String> headers = getHeaders();
    try {
      setState(() {
        _pedidosLoading = true;
        listaPedidos = [];
      });

      objetoPedido = {"usuario": Autenticacao.codigoUsuario.toString()};
      http
          .post(Configuracoes.BASE_URL + 'pedido/localizar',
              headers: headers, body: objetoPedido)
          .then((response) {
        responseBody = json.decode(response.body);
        responseBody['pedidos'].forEach((pedidosJson) {
          if (pedidosJson['endereco_id'] != null) {
            bairro = Bairro(
                id: int.parse(pedidosJson['bairro_id']),
                nome: pedidosJson['nomeBairro']);

            cidade = Cidade(
                id: int.parse(pedidosJson['cidade_id']),
                nome: pedidosJson['nomeCidade']);

            endereco = Endereco(
              id: int.parse(pedidosJson['endereco_id']),
              nome: pedidosJson['nomeEndereco'],
              cidade: cidade,
              bairro: bairro,
              rua: pedidosJson['rua'],
              numero: int.parse(pedidosJson['numero']),
              complemento: pedidosJson['complemento'],
              referencia: pedidosJson['referencia'],
              dataCadastro: pedidosJson['dataCadastroEndereco'],
              dataConfirmacao: pedidosJson['dataConfirmacaoEndereco'],
            );
          }
          pedido = Pedido(
              id: int.parse(pedidosJson['pedido_id']),
              usuarioId: int.parse(pedidosJson['usuario_id']),
              empresa: int.parse(pedidosJson['produto_empresa']),
              modalidadeEntrega: pedidosJson['modalidadeEntrega'] != null
                  ? int.parse(pedidosJson['modalidadeEntrega'])
                  : 0,
              formaPagamento: pedidosJson['formaPagamento'] != null
                  ? int.parse(pedidosJson['formaPagamento'])
                  : 0,
              horaPrevista: pedidosJson['horaPrevista'],
              dataInclusao: pedidosJson['dataInclusao'],
              dataConfirmacao: pedidosJson['dataConfirmacaoEndereco'],
              status: int.parse(pedidosJson['status']),
              endereco: endereco,
              listaItensPedido: []);

          pedidoAdicionado = false;
          for (final pedidoAux in listaPedidos) {
            if (pedidoAux.id == pedido.id) {
              pedidoAdicionado = true;
              break;
            }
          }
          if (!pedidoAdicionado) {
            listaPedidos.add(pedido);
          }
        });

        responseBody['pedidos'].forEach((pedidosJson) {
          setState(() {
            for (final pedidoAux in listaPedidos) {
              if (pedidoAux.id == int.parse(pedidosJson['pedido_id'])) {
                if (pedidosJson['produto_id'] != null) {
                  produto = Produto(
                      id: int.parse(pedidosJson['produto_id']),
                      titulo: pedidosJson['titulo'],
                      descricao: pedidosJson['descricao'],
                      imagem: pedidosJson['imagem'],
                      valor: pedidosJson['valor'],
                      valorNumerico: double.parse(pedidosJson['valorNumerico']),
                      quantidade: int.parse(pedidosJson['quantidade']),
                      quantidadeRestante:
                          int.parse(pedidosJson['quantidadeRestante']),
                      dataInicial: pedidosJson['dataInicial'],
                      dataFinal: pedidosJson['dataFinal'],
                      dataCadastro: pedidosJson['DataCadastro'],
                      usuarioId: int.parse(pedidosJson['usuario_id']));
                  pedidoAux.listaItensPedido.add(ItemPedido(
                      pedidoId: int.parse(pedidosJson['pedido_id']),
                      produtoId: int.parse(pedidosJson['produto_id']),
                      quantidade: int.parse(pedidosJson['quantidade_item']),
                      sabores: pedidosJson['sabores_item'],
                      valor: double.parse(pedidosJson['valor_item']),
                      produto: produto));
                }
              }
            }
          });
        });
        setState(() {
          _pedidosLoading = false;
        });
      });
    } catch (error) {
      _pedidosLoading = true;
    }
  }

  void alterarEnderecoFavorito(int usuarioId, int enderecoId) {
    Map<dynamic, dynamic> objetoEndereco = Map();
    Map<dynamic, dynamic> responseBody;
    Map<String, String> headers = getHeaders();
    print("ALTERANDO ENDERECO FAVORITO");
    objetoEndereco = {
      "usuario": Autenticacao.codigoUsuario.toString(),
      "endereco": enderecoId.toString()
    };
    http
        .post(Configuracoes.BASE_URL + 'enderecos/alterarEnderecoFavorito',
            headers: headers, body: objetoEndereco)
        .then((response) {
      print("ALTERANDO ENDERECO FAVORITO");
      print(json.decode(response.body).toString());
      responseBody = json.decode(response.body);
      return responseBody['message'];
    });
  }
}
*/
