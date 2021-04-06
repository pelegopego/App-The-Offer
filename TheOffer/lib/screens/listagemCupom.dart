import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:theoffer/scoped-models/main.dart';
import 'package:theoffer/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:theoffer/utils/connectivity_state.dart';
import 'package:theoffer/utils/locator.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:theoffer/models/endereco.dart';
import 'package:theoffer/models/Cupom.dart';
import 'package:theoffer/models/Produto.dart';
import 'package:theoffer/models/itemCupom.dart';
import 'package:theoffer/models/cidade.dart';
import 'package:theoffer/models/bairro.dart';
import 'package:theoffer/screens/detalharCupom.dart';
import 'package:theoffer/utils/headers.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ListagemCupom extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ListagemCupom();
  }
}

class _ListagemCupom extends State<ListagemCupom> {
  bool _cupomLoading = true;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  List<Cupom> listaCupom = [];
  @override
  void initState() {
    super.initState();
    getCupom();
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
              icon: Icon(Icons.arrow_back_ios, color: Colors.principalTheOffer),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'Cupom',
              style: TextStyle(color: Colors.principalTheOffer),
            ),
            bottom: _cupomLoading
                ? PreferredSize(
                    child: LinearProgressIndicator(),
                    preferredSize: Size.fromHeight(10),
                  )
                : PreferredSize(
                    child: Container(),
                    preferredSize: Size.fromHeight(10),
                  )),
        body: !_cupomLoading && listaCupom.length > 0
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
    await getCupom();
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
                    builder: (context) => DetalharCupom(listaCupom[index]));

                Navigator.push(context, route);
              },
              child: _cupomLoading
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
                                                      text: 'Cupom ' +
                                                          listaCupom[index]
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
                                                          listaCupom[index]
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
                                                                        DetalharCupom(
                                                                            listaCupom[index]));

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
                                                    listaCupom[index]
                                                        .somaQuantidadeCupom()
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
                                            Expanded(
                                              child: Column(children: <Widget>[
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.30,
                                                  color:
                                                      Colors.principalTheOffer,
                                                  alignment: Alignment.center,
                                                  child: RichText(
                                                    text: TextSpan(
                                                      text: getStatus(
                                                          listaCupom[index]
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
          }, childCount: listaCupom.length),
        );
      },
    );
  }

  getStatus(int status) {
    if (status == 1) {
      return 'ADQUIRIDO';
    } else if (status == 2) {
      return 'UTILIZADO';
    } else if (status == 3) {
      return 'Expirado';
    }
  }

  getCupom() async {
    print("LOCALIZANDO PEDIDOS");
    Map<dynamic, dynamic> objetoCupom = Map();
    Map<dynamic, dynamic> responseBody;
    Produto produto;
    Endereco endereco;
    Cupom cupom;
    bool cupomAdicionado;
    Bairro bairro;
    Cidade cidade;
    Map<String, String> headers = getHeaders();
    try {
      setState(() {
        _cupomLoading = true;
        listaCupom = [];
      });

      objetoCupom = {"usuario": Autenticacao.codigoUsuario.toString()};
      http
          .post(Configuracoes.BASE_URL + 'cupom/localizar',
              headers: headers, body: objetoCupom)
          .then((response) {
        responseBody = json.decode(response.body);
        if (responseBody['possuiCupom']) {
          responseBody['cupom'].forEach((cupomJson) {
            if (cupomJson['endereco_id'] != null) {
              bairro = Bairro(
                  id: int.parse(cupomJson['bairro_id']),
                  nome: cupomJson['nomeBairro']);

              cidade = Cidade(
                  id: int.parse(cupomJson['cidade_id']),
                  nome: cupomJson['nomeCidade']);

              endereco = Endereco(
                id: int.parse(cupomJson['endereco_id']),
                nome: cupomJson['nomeEndereco'],
                cidade: cidade,
                bairro: bairro,
                rua: cupomJson['rua'],
                numero: int.parse(cupomJson['numero']),
                complemento: cupomJson['complemento'],
                referencia: cupomJson['referencia'],
                dataCadastro: cupomJson['dataCadastroEndereco'],
                dataConfirmacao: cupomJson['dataConfirmacaoEndereco'],
              );
            }
            cupom = Cupom(
                id: int.parse(cupomJson['cupom_id']),
                usuarioId: int.parse(cupomJson['usuario_id']),
                empresa: int.parse(cupomJson['produto_empresa']),
                modalidadeEntrega: cupomJson['modalidadeEntrega'] != null
                    ? int.parse(cupomJson['modalidadeEntrega'])
                    : 0,
                formaPagamento: cupomJson['formaPagamento'] != null
                    ? int.parse(cupomJson['formaPagamento'])
                    : 0,
                horaPrevista: cupomJson['horaPrevista'],
                dataInclusao: cupomJson['dataInclusao'],
                dataConfirmacao: cupomJson['dataConfirmacaoEndereco'],
                status: int.parse(cupomJson['status']),
                endereco: endereco,
                listaItensCupom: []);

            cupomAdicionado = false;
            for (final cupomAux in listaCupom) {
              if (cupomAux.id == cupom.id) {
                cupomAdicionado = true;
                break;
              }
            }
            if (!cupomAdicionado) {
              listaCupom.add(cupom);
            }
          });

          responseBody['cupom'].forEach((cupomJson) {
            setState(() {
              for (final cupomAux in listaCupom) {
                if (cupomAux.id == int.parse(cupomJson['cupom_id'])) {
                  if (cupomJson['produto_id'] != null) {
                    produto = Produto(
                        id: int.parse(cupomJson['produto_id']),
                        titulo: cupomJson['titulo'],
                        descricao: cupomJson['descricao'],
                        imagem: cupomJson['imagem'],
                        valor: cupomJson['valor'],
                        valorNumerico: double.parse(cupomJson['valorNumerico']),
                        quantidade: int.parse(cupomJson['quantidade']),
                        quantidadeRestante:
                            int.parse(cupomJson['quantidadeRestante']),
                        dataInicial: cupomJson['dataInicial'],
                        dataFinal: cupomJson['dataFinal'],
                        dataCadastro: cupomJson['DataCadastro'],
                        usuarioId: int.parse(cupomJson['usuario_id']));
                    cupomAux.listaItensCupom.add(ItemCupom(
                        cupomId: int.parse(cupomJson['cupom_id']),
                        produtoId: int.parse(cupomJson['produto_id']),
                        quantidade: int.parse(cupomJson['quantidade_item']),
                        sabores: cupomJson['sabores_item'],
                        produto: produto));
                  }
                }
              }
            });
          });
        }
        setState(() {
          _cupomLoading = false;
        });
      });
    } catch (error) {
      _cupomLoading = false;
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
