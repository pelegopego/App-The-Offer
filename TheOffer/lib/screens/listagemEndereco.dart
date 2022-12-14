/*import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:theoffer/scoped-models/main.dart';
import 'package:theoffer/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:theoffer/utils/connectivity_state.dart';
import 'package:theoffer/utils/locator.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:theoffer/models/endereco.dart';
import 'package:theoffer/models/cidade.dart';
import 'package:theoffer/screens/cadastroEndereco.dart';
import 'package:theoffer/models/bairro.dart';
import 'package:theoffer/utils/headers.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ListagemEndereco extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ListagemEndereco();
  }
}

class _ListagemEndereco extends State<ListagemEndereco> {
  bool _enderecosLoading = true;
  List<Endereco> listaEnderecos = [];
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  @override
  void initState() {
    super.initState();
    getEnderecos();
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
              'Endereços',
              style: TextStyle(color: Colors.principalTheOffer),
            ),
            bottom: _enderecosLoading
                ? PreferredSize(
                    child: LinearProgressIndicator(),
                    preferredSize: Size.fromHeight(10),
                  )
                : PreferredSize(
                    child: Container(),
                    preferredSize: Size.fromHeight(10),
                  )),
        body: !_enderecosLoading || listaEnderecos != null
            ? Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("images/fundoBranco.png"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: body())
            : !_enderecosLoading
                ? Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("images/fundoBranco.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: IconButton(
                      iconSize: 24,
                      color: Colors.principalTheOffer,
                      icon: Icon(Icons.add),
                      onPressed: () {
                        MaterialPageRoute route = MaterialPageRoute(
                            builder: (context) => TelaCadastroEndereco());

                        Navigator.push(context, route);
                      },
                    ),
                  )
                : Container(),
      );
    });
  }

  void _onRefresh() async {
    await getEnderecos();
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
              )),
        ))
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
                  print('object');
                  alterarEnderecoFavorito(
                      Autenticacao.codigoUsuario, listaEnderecos[index].id);
                  MaterialPageRoute route = MaterialPageRoute(
                      builder: (context) => ListagemEndereco());

                  Navigator.push(context, route);
                  print('objects');
                },
                child: _enderecosLoading
                    ? Container()
                    : index != listaEnderecos.length
                        ? Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage("images/fundoBranco.png"),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Card(
                                    child: Container(
                                      height: 115,
                                      color: listaEnderecos[index].favorito
                                          ? Colors.principalTheOffer
                                          : Colors.secundariaTheOffer,
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
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Container(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: <Widget>[
                                                      Container(
                                                        width: 250,
                                                        child: RichText(
                                                          text: TextSpan(
                                                            text:
                                                                listaEnderecos[
                                                                        index]
                                                                    .nome,
                                                            style: TextStyle(
                                                                color: listaEnderecos[
                                                                            index]
                                                                        .favorito
                                                                    ? Colors
                                                                        .secundariaTheOffer
                                                                    : Colors
                                                                        .principalTheOffer,
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                          child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: <
                                                                  Widget>[
                                                            Container(
                                                              alignment: Alignment
                                                                  .centerRight,
                                                              child: IconButton(
                                                                iconSize: 24,
                                                                color: listaEnderecos[
                                                                            index]
                                                                        .favorito
                                                                    ? Colors
                                                                        .secundariaTheOffer
                                                                    : Colors
                                                                        .principalTheOffer,
                                                                icon: Icon(Icons
                                                                    .close),
                                                                onPressed: () {
                                                                  deletarEndereco(
                                                                      Autenticacao
                                                                          .codigoUsuario,
                                                                      listaEnderecos[
                                                                              index]
                                                                          .id);
                                                                },
                                                              ),
                                                            ),
                                                          ])),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                    child:
                                                        Row(children: <Widget>[
                                                  Container(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: RichText(
                                                        text: TextSpan(
                                                      text: listaEnderecos[
                                                                  index]
                                                              .rua +
                                                          ', ' +
                                                          listaEnderecos[index]
                                                              .numero
                                                              .toString(),
                                                      style: TextStyle(
                                                          color: listaEnderecos[
                                                                      index]
                                                                  .favorito
                                                              ? Colors
                                                                  .secundariaTheOffer
                                                              : Colors
                                                                  .principalTheOffer,
                                                          fontSize: 15.0),
                                                    )),
                                                  ),
                                                ])),
                                                Container(
                                                    child:
                                                        Row(children: <Widget>[
                                                  Container(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: RichText(
                                                      text: TextSpan(
                                                        text: listaEnderecos[
                                                                    index]
                                                                .cidade
                                                                .nome +
                                                            ', Bairro ' +
                                                            listaEnderecos[
                                                                    index]
                                                                .bairro
                                                                .nome,
                                                        style: TextStyle(
                                                            color: listaEnderecos[
                                                                        index]
                                                                    .favorito
                                                                ? Colors
                                                                    .secundariaTheOffer
                                                                : Colors
                                                                    .principalTheOffer,
                                                            fontSize: 15.0,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 100,
                                                  ),
                                                ])),
                                                listaEnderecos[index].favorito
                                                    ? Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 10,
                                                                right: 20),
                                                        child: Container(
                                                            alignment: Alignment
                                                                .bottomCenter,
                                                            width: 80,
                                                            color: Colors
                                                                .secundariaTheOffer,
                                                            child:
                                                                Row(children: <
                                                                    Widget>[
                                                              Container(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            5),
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child: RichText(
                                                                  text:
                                                                      TextSpan(
                                                                    text:
                                                                        'FAVORITO',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .principalTheOffer,
                                                                        fontSize:
                                                                            15.0,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                ),
                                                              ),
                                                            ])))
                                                    : Container(),
                                              ],
                                            )),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                ]))
                        : Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.secundariaTheOffer,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              iconSize: 24,
                              color: Colors.principalTheOffer,
                              icon: Icon(Icons.add),
                              onPressed: () {
                                MaterialPageRoute route = MaterialPageRoute(
                                    builder: (context) =>
                                        TelaCadastroEndereco());

                                Navigator.push(context, route);
                              },
                            ),
                          ));
          }, childCount: listaEnderecos.length + 1),
        );
      },
    );
  }

  void deletarEndereco(int usuarioId, int enderecoId) {
    Map<dynamic, dynamic> objetoEndereco = Map();
    Map<String, String> headers = getHeaders();
    print("DELETANDO ENDERECO");
    objetoEndereco = {
      "usuario": usuarioId.toString(),
      "endereco": enderecoId.toString()
    };
    http
        .post(Configuracoes.BASE_URL + 'enderecos/deletar',
            headers: headers, body: objetoEndereco)
        .then((response) {
      print("REMOVENDO PRODUTO DO CARRINHO _______");
      getEnderecos();
    });
  }

  getEnderecos() async {
    List<Endereco> _listaEnderecos = [];
    Cidade cidade;
    Bairro bairro;
    Map<String, String> headers = getHeaders();
    Map<dynamic, dynamic> responseBody;
    Map<dynamic, dynamic> objetoEndereco = Map();

    setState(() {
      _enderecosLoading = true;
      listaEnderecos = [];
      _listaEnderecos = [];
    });

    objetoEndereco = {
      "usuario": Autenticacao.codigoUsuario.toString(),
      "cidade": CidadeSelecionada.id.toString()
    };
    http
        .post(Configuracoes.BASE_URL + 'enderecos',
            headers: headers, body: objetoEndereco)
        .then((response) {
      responseBody = json.decode(response.body);
      responseBody['enderecos'].forEach((enderecoJson) {
        setState(() {
          cidade = Cidade(
              id: int.parse(enderecoJson['cidade_id']),
              nome: enderecoJson['nomeCidade']);

          bairro = Bairro(
              id: int.parse(enderecoJson['bairro_id']),
              nome: enderecoJson['nomeBairro']);

          _listaEnderecos.add(Endereco(
              id: int.parse(enderecoJson['id']),
              nome: enderecoJson['nome'],
              cidade: cidade,
              bairro: bairro,
              rua: enderecoJson['rua'],
              numero: int.parse(enderecoJson['numero']),
              complemento: enderecoJson['complemento'],
              referencia: enderecoJson['referencia'],
              usuarioId: int.parse(enderecoJson['usuario_id']),
              favorito: (enderecoJson['favorito'] == 'S'),
              dataCadastro: enderecoJson['dataCadastro'],
              dataConfirmacao: enderecoJson['dataConfirmacao']));
        });
      });
      listaEnderecos = _listaEnderecos;
    });
    setState(() {
      _enderecosLoading = false;
    });
  }

  void alterarEnderecoFavorito(int usuarioId, int enderecoId) {
    Map<String, String> headers = getHeaders();
    Map<dynamic, dynamic> objetoEndereco = Map();
    print("ALTERANDO ENDERECO FAVORITO");
    objetoEndereco = {
      "usuario": Autenticacao.codigoUsuario.toString(),
      "endereco": enderecoId.toString()
    };
    http
        .post(Configuracoes.BASE_URL + 'enderecos/alterarEnderecoFavorito',
            headers: headers, body: objetoEndereco)
        .then((response) {
      print(json.decode(response.body).toString());
    });
  }
}
*/
