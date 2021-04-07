import 'dart:convert';
import 'package:theoffer/widgets/cardProdutos.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:theoffer/models/Produto.dart';
import 'package:theoffer/scoped-models/main.dart';
import 'package:theoffer/screens/autenticacao.dart';
import 'package:theoffer/screens/pesquisaProduto.dart';
import 'package:theoffer/utils/connectivity_state.dart';
import 'package:theoffer/utils/constants.dart';
import 'package:theoffer/utils/locator.dart';
//import 'package:theoffer/widgets/botaoCarrinho.dart';
//import 'package:theoffer/screens/finalizarPedido.dart';
import 'package:theoffer/screens/sabores.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:theoffer/utils/headers.dart';
import 'package:http/http.dart' as http;
import 'package:theoffer/utils/Hora.dart';

class TelaProdutoDetalhado extends StatefulWidget {
  final Produto produto;
  TelaProdutoDetalhado(this.produto);
  @override
  State<StatefulWidget> createState() {
    return _TelaProdutoDetalhado();
  }
}

class _TelaProdutoDetalhado extends State<TelaProdutoDetalhado>
    with SingleTickerProviderStateMixin {
  getBloqueio() {
    if (Autenticacao.codigoUsuario > 0) {
      if (Autenticacao.dataBloqueio == null ||
          Autenticacao.dataBloqueio.isBefore(DateTime.now())) {
        Map<String, String> headers = getHeaders();
        Map<dynamic, dynamic> oMapSalvarNotificacao = {
          'usuario': Autenticacao.codigoUsuario.toString()
        };
        http
            .post(Configuracoes.BASE_URL + 'usuario/getBloqueio/',
                headers: headers, body: oMapSalvarNotificacao)
            .then((response) {
          setState(() {
            if (response.body != '' &&
                json.decode(response.body)[0]['dataBloqueio'] != null) {
              Autenticacao.dataBloqueio =
                  DateTime.parse(json.decode(response.body)[0]['dataBloqueio']);
            }

            if (Autenticacao.dataBloqueio == null ||
                Autenticacao.dataBloqueio.isBefore(DateTime.now())) {
              Autenticacao.bloqueado = false;
            } else {
              Autenticacao.bloqueado = true;
            }
          });
        });
      } else {
        Autenticacao.bloqueado = true;
      }
    } else {
      Autenticacao.bloqueado = false;
    }
  }

  bool _isFavorite = false;
  bool discount = true;
  TabController _tabController;
  Size _deviceSize;
  int quantidade = 1;
  Produto produtoSelecionado;
  bool _produtosRelacionadosLoading = true;
  List<Produto> listaProdutosRelacionados;
  String htmlDescription;
  List<Produto> produtosSimilares = List();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String pincode = '';

  @override
  void initState() {
    _tabController = TabController(length: 1, vsync: this);
    _isFavorite = true;
    produtoSelecionado = widget.produto;
    discount = false;
    htmlDescription =
        widget.produto.descricao != null ? widget.produto.descricao : '';
    getProdutosRelacionados();
    getBloqueio();
    locator<ConnectivityManager>().initConnectivity(context);
    // _dropDownVariantItems = getVariants();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    locator<ConnectivityManager>().dispose();
  }

  getProdutosRelacionados() async {
    Map<dynamic, dynamic> responseBody;
    Map<dynamic, dynamic> objetoItemPedido = Map();
    Map<String, String> headers = getHeaders();
    setState(() {
      _produtosRelacionadosLoading = true;
      listaProdutosRelacionados = [];
    });

    objetoItemPedido = {
      "categoria": produtoSelecionado.categoria.toString(),
      "produto": produtoSelecionado.id.toString(),
      "empresa": produtoSelecionado.empresa.toString()
    };
    http
        .post(Configuracoes.BASE_URL + 'produtos/relacionados/',
            headers: headers, body: objetoItemPedido)
        .then((response) {
      responseBody = json.decode(response.body);
      if (responseBody['produtos'] != null) {
        responseBody['produtos'].forEach((produtoJson) {
          setState(() {
            listaProdutosRelacionados.add(Produto(
                empresa: int.parse(produtoJson['empresa_id']),
                id: int.parse(produtoJson['id']),
                titulo: produtoJson['titulo'],
                descricao: produtoJson['descricao'],
                imagem: produtoJson['imagem'],
                valor: produtoJson['valor'],
                valorNumerico: double.parse(produtoJson['valorNumerico']),
                quantidade: int.parse(produtoJson['quantidade']),
                quantidadeRestante:
                    int.parse(produtoJson['quantidadeRestante']),
                dataInicial: produtoJson['dataInicial'],
                dataFinal: produtoJson['dataFinal'],
                dataCadastro: produtoJson['dataCadastro'],
                empresaSegundaInicio:
                    double.parse(produtoJson['segundaInicio']),
                empresaSegundaFim: double.parse(produtoJson['segundaFim']),
                empresaTercaInicio: double.parse(produtoJson['tercaInicio']),
                empresaTercaFim: double.parse(produtoJson['tercaFim']),
                empresaQuartaInicio: double.parse(produtoJson['quartaInicio']),
                empresaQuartaFim: double.parse(produtoJson['quartaFim']),
                empresaQuintaInicio: double.parse(produtoJson['quintaInicio']),
                empresaQuintaFim: double.parse(produtoJson['quintaFim']),
                empresaSextaInicio: double.parse(produtoJson['sextaInicio']),
                empresaSextaFim: double.parse(produtoJson['sextaFim']),
                empresaSabadoInicio: double.parse(produtoJson['sabadoInicio']),
                empresaSabadoFim: double.parse(produtoJson['sabadoFim']),
                empresaDomingoInicio:
                    double.parse(produtoJson['domingoInicio']),
                empresaDomingoFim: double.parse(produtoJson['domingoFim']),
                categoria: int.parse(produtoJson['categoria_id']),
                possuiSabores: int.parse(produtoJson['possuiSabores']) > 0,
                usuarioId: int.parse(produtoJson['usuario_id'])));
          });
        });
      }
    });
    setState(() {
      _produtosRelacionadosLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    _deviceSize = MediaQuery.of(context).size;
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.principalTheOffer),
              onPressed: () {
                Navigator.pop(context);
              }),
          title: Text(
            'Detalhes do item',
            style: TextStyle(color: Colors.principalTheOffer),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search, color: Colors.principalTheOffer),
              onPressed: () {
                MaterialPageRoute route = MaterialPageRoute(
                    builder: (context) => TelaPesquisaProduto());
                Navigator.of(context).push(route);
              },
            ),
            //shoppingCarrinhoIconButton()
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(50),
            child: Column(
              children: [
                TabBar(
                  indicatorWeight: 1,
                  controller: _tabController,
                  tabs: <Widget>[
                    Tab(
                      text: '',
                    ),
                  ],
                ),
                model.isLoading ? LinearProgressIndicator() : Container()
              ],
            ),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/fundoBranco.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: TabBarView(
            controller: _tabController,
            children: <Widget>[highlightsTab()],
          ),
        ),
        //floatingActionButton: adicionarCarrinhoFloatButton()
      );
    });
  }

/*
  Widget linhaQuantidade(MainModel model, Produto produtoSelecionado) {
    print("PRODUTO SELECIONADO ---> ${produtoSelecionado.id}");
    return Container(
        height: 60.0,
        color: Colors.secundariaTheOffer,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 20,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return Container();
            } else {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    quantidade = index;
                  });
                },
                child: Container(
                    width: 45,
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: quantidade == index
                              ? Colors.white //Quantidade
                              : Colors.principalTheOffer,
                        ),
                        borderRadius: BorderRadius.circular(5)),
                    alignment: Alignment.center,
                    // margin: EdgeInsets.all(10),
                    margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    padding: EdgeInsets.all(10),
                    child: Text(
                      index.toString(),
                      style: TextStyle(
                        color: quantidade == index
                            ? Colors.white //Quantidade
                            : Colors.principalTheOffer,
                      ),
                    )),
              );
            }
          },
        ));
  }
*/
  Widget highlightsTab() {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          child: Column(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                    color: Colors.secundariaTheOffer,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                            child: Center(
                          child: Container(
                            alignment: Alignment.center,
                            height: 320,
                            width: 390,
                            child: CachedNetworkImage(
                                imageUrl: produtoSelecionado.imagem),
                          ),
                        )),
                      ],
                    ),
                  ),
                  Container(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      padding: EdgeInsets.only(top: 40, right: 15.0),
                      alignment: Alignment.topRight,
                      icon: Icon(Icons.favorite),
                      color:
                          _isFavorite ? Colors.principalTheOffer : Colors.grey,
                      onPressed: () async {
                        final SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        String authToken = prefs.getString('spreeApiKey');

                        if (!_isFavorite) {
                          if (authToken == null) {
                            _scaffoldKey.currentState.showSnackBar(SnackBar(
                              content: Text(
                                'Entre na sua conta para adicionar aos favoritos',
                              ),
                              action: SnackBarAction(
                                label: 'LOGIN',
                                onPressed: () {
                                  MaterialPageRoute route = MaterialPageRoute(
                                      builder: (context) => Authentication(0));
                                  Navigator.push(context, route);
                                },
                              ),
                            ));
                          } else {
                            /*
                            _scaffoldKey.currentState.showSnackBar(SnackBar(
                              content: Text(
                                'Adicionando aos favoritos aguarde.',
                              ),
                              duration: Duration(seconds: 1),
                            ));
                            http
                                .post(Settings.SERVER_URL + 'favorite_products',
                                    body: json.encode({
                                      'id': widget.produto.id
                                          .toString()
                                    }),
                                    headers: headers)
                                .then((response) {
                              Map<dynamic, dynamic> responseBody =
                                  json.decode(response.body);
                              setState(() {
                                _isFavorite = true;
                              });
                              _scaffoldKey.currentState.showSnackBar(SnackBar(
                                content: Text('Produto adicionado aos favoritos!'),
                                duration: Duration(seconds: 1),
                              ));
                            });*/
                          }
                        } else {
                          /*
                          _scaffoldKey.currentState.showSnackBar(SnackBar(
                            content: Text(
                              'Removendo produto dos favoritos, aguarde.',
                            ),
                            duration: Duration(seconds: 1),
                          ));
                          http
                              .delete(
                                  Settings.SERVER_URL +
                                      'favorite_products/${widget.produto.id}',
                                  headers: headers)
                              .then((response) {
                            Map<dynamic, dynamic> responseBody =
                                json.decode(response.body);
                            if (responseBody['message'] != null) {
                              setState(() {
                                _isFavorite = false;
                              });
                              _scaffoldKey.currentState.showSnackBar(SnackBar(
                                content: Text(responseBody['message']),
                                duration: Duration(seconds: 1),
                              ));
                            } else {
                              _scaffoldKey.currentState.showSnackBar(SnackBar(
                                content: Text('Ocorreu um erro'),
                                duration: Duration(seconds: 1),
                              ));
                            }
                          });*/
                        }
                      },
                    ),
                  )
                ],
              ),
              Container(
                color: Colors.secundariaTheOffer,
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.all(10),
                child: Text(
                  produtoSelecionado.titulo,
                  style: TextStyle(
                      fontSize: 17,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.bold,
                      fontFamily: fontFamily,
                      color: Colors.principalTheOffer),
                  textAlign: TextAlign.start,
                ),
              ),
              produtoSelecionado.quantidade > 0
                  ? Container(
                      alignment: Alignment.centerLeft,
                      color: Colors.secundariaTheOffer,
                      padding: EdgeInsets.all(10),
                      child: Text(
                        'Quantidade ',
                        style: TextStyle(
                            fontSize: 14,
                            fontFamily: fontFamily,
                            color: Colors.principalTheOffer),
                      ),
                    )
                  : Container(),
              /*
              produtoSelecionado.quantidade > 0
                  ? linhaQuantidade(model, produtoSelecionado)
                  : Container(),*/
              Divider(color: Colors.secundariaTheOffer),
              discount
                  ? SizedBox(
                      height: 18,
                    )
                  : Container(),
              linhaPrecos('Preço: ', produtoSelecionado.valor,
                  strike: discount, valor: '${produtoSelecionado.valor}'),
              Divider(color: Colors.secundariaTheOffer),
              SizedBox(
                height: 12.0,
              ),
              adicionarCarrinhoButton(),
              /*SizedBox(
                height: 12.0,
              ),
              comprarAgoraButton(),*/
              Divider(color: Colors.principalTheOffer),
              SizedBox(
                height: 2,
              ),
              Column(
                children: <Widget>[
                  Container(
                      width: _deviceSize.width,
                      child: ListTile(
                        contentPadding: EdgeInsets.only(left: 10.0),
                        title: Text('Você também pode gostar',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.secundariaTheOffer)),
                      )),
                ],
              ),
              _produtosRelacionadosLoading
                  ? Container(
                      height: _deviceSize.height * 0.47,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.secundariaTheOffer,
                      ),
                    )
                  : Container(
                      height: _deviceSize.height * 0.500,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: listaProdutosRelacionados.length,
                          itemBuilder: (context, index) {
                            if (listaProdutosRelacionados.length > 0) {
                              return Container(
                                  child: cardProdutos(
                                      index,
                                      listaProdutosRelacionados,
                                      _deviceSize,
                                      context));
                            } else {
                              return Container();
                            }
                          }),
                    ),
              SizedBox(
                height: 12.0,
              ),
              Container(
                  color: Colors.secundariaTheOffer,
                  padding: EdgeInsets.only(left: 10.0, top: 20.0),
                  alignment: Alignment.centerLeft,
                  child: Text("Descrição",
                      style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.principalTheOffer))),
              Container(
                  color: Colors.secundariaTheOffer,
                  padding: EdgeInsets.only(left: 10.0, top: 20.0),
                  alignment: Alignment.centerLeft,
                  child: Text(htmlDescription,
                      style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.normal,
                          color: Colors.principalTheOffer))),
            ],
          ),
        ),
      );
    });
  }

  Widget comprarAgoraButton() {
    int horaAtual = (DateTime.now().toLocal().hour * 60) +
        (DateTime.now().toLocal().minute);
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Container(
            color: Colors.secundariaTheOffer,
            width: double.infinity,
            height: 45.0,
            child: FlatButton(
              child: Text(
                Autenticacao.bloqueado
                    ? 'USUÁRIO BLOQUEADO'
                    : produtoSelecionado.dataInicial != '' &&
                            produtoSelecionado.dataInicial != null &&
                            (DateTime.parse(produtoSelecionado.dataInicial)
                                .isAfter(DateTime.now().toLocal()))
                        ? 'EM BREVE'
                        : getHoraInicioProdutoHoje(produtoSelecionado) <
                                    horaAtual &&
                                getHoraFimProdutoHoje(produtoSelecionado) >
                                    horaAtual
                            ? produtoSelecionado.quantidadeRestante > 0
                                ? 'COMPRAR AGORA'
                                : 'FORA DE ESTOQUE'
                            : 'ESTABELECIMENTO FECHADO',
                style: TextStyle(
                    color: getHoraInicioProdutoHoje(produtoSelecionado) <
                                horaAtual &&
                            getHoraFimProdutoHoje(produtoSelecionado) >
                                horaAtual &&
                            produtoSelecionado.quantidadeRestante > 0
                        ? Colors.principalTheOffer
                        : Colors.grey),
              ),
              onPressed: getHoraInicioProdutoHoje(produtoSelecionado) <
                          horaAtual &&
                      getHoraFimProdutoHoje(produtoSelecionado) > horaAtual &&
                      produtoSelecionado.quantidadeRestante > 0
                  ? () {
                      if (getHoraInicioProdutoHoje(produtoSelecionado) <
                              horaAtual &&
                          getHoraFimProdutoHoje(produtoSelecionado) >
                              horaAtual &&
                          produtoSelecionado.quantidadeRestante > 0) {
                        if (Autenticacao.codigoUsuario > 0) {
                          model.pegarCupom(
                              usuarioId: Autenticacao.codigoUsuario,
                              produtoId: produtoSelecionado.id,
                              context: context);
                        } else {
                          MaterialPageRoute authRoute = MaterialPageRoute(
                              builder: (context) => Authentication(0));
                          Navigator.push(context, authRoute);
                        }
                        /*if (model.pedido != null) {
                          if (!model.isLoading) {
                            MaterialPageRoute route = MaterialPageRoute(
                                builder: (context) => TelaFinalizarPedido());

                            Navigator.push(context, route);
                          }
                        }*/
                        if (produtoSelecionado.possuiSabores) {
                          MaterialPageRoute pagamentoRoute = MaterialPageRoute(
                              builder: (context) =>
                                  TelaSabores(produtoSelecionado.id, 1));
                          Navigator.push(context, pagamentoRoute);
                        }
                      }
                    }
                  : () {},
            ),
          ),
        );
      },
    );
  }

  Widget adicionarCarrinhoButton() {
    int horaAtual = (DateTime.now().toLocal().hour * 60) +
        (DateTime.now().toLocal().minute);
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Container(
            color: Colors.secundariaTheOffer,
            width: double.infinity,
            height: 45.0,
            child: FlatButton(
              child: Text(
                Autenticacao.bloqueado
                    ? 'USUÁRIO BLOQUEADO'
                    : produtoSelecionado.dataInicial != '' &&
                            produtoSelecionado.dataInicial != null &&
                            (DateTime.parse(produtoSelecionado.dataInicial)
                                .isAfter(DateTime.now().toLocal()))
                        ? 'EM BREVE'
                        : getHoraInicioProdutoHoje(produtoSelecionado) <
                                    horaAtual &&
                                getHoraFimProdutoHoje(produtoSelecionado) >
                                    horaAtual
                            ? produtoSelecionado.quantidadeRestante > 0
                                ? 'ADQUIRIR CUPOM'
                                : 'FORA DE ESTOQUE'
                            : 'ESTABELECIMENTO FECHADO',
                /*
                    ? produtoSelecionado.quantidadeRestante > 0
                        ? 'ADICIONAR AO CARRINHO'
                        : 'FORA DE ESTOQUE'
                    : 'ESTABELECIMENTO FECHADO',*/
                style: TextStyle(
                    color: getHoraInicioProdutoHoje(produtoSelecionado) <
                                horaAtual &&
                            getHoraFimProdutoHoje(produtoSelecionado) >
                                horaAtual &&
                            produtoSelecionado.quantidadeRestante > 0 &&
                            !Autenticacao.bloqueado &&
                            (produtoSelecionado.dataInicial == '' ||
                                produtoSelecionado.dataInicial == null ||
                                !(DateTime.parse(produtoSelecionado.dataInicial)
                                    .isAfter(DateTime.now().toLocal())))
                        ? Colors.principalTheOffer
                        : Colors.grey),
              ),
              onPressed: getHoraInicioProdutoHoje(produtoSelecionado) <
                          horaAtual &&
                      getHoraFimProdutoHoje(produtoSelecionado) > horaAtual &&
                      produtoSelecionado.quantidadeRestante > 0
                  ? () {
                      if (Autenticacao.codigoUsuario > 0) {
                        if (getHoraInicioProdutoHoje(produtoSelecionado) <
                                horaAtual &&
                            getHoraFimProdutoHoje(produtoSelecionado) >
                                horaAtual &&
                            produtoSelecionado.quantidadeRestante > 0 &&
                            !Autenticacao.bloqueado &&
                            (produtoSelecionado.dataInicial == '' ||
                                produtoSelecionado.dataInicial == null ||
                                !(DateTime.parse(produtoSelecionado.dataInicial)
                                    .isAfter(DateTime.now().toLocal())))) {
                          if (widget.produto.possuiSabores) {
                            MaterialPageRoute pagamentoRoute =
                                MaterialPageRoute(
                                    builder: (context) => TelaSabores(
                                        produtoSelecionado.id, quantidade));
                            Navigator.push(context, pagamentoRoute);
                          } else {
                            model.pegarCupom(
                                usuarioId: Autenticacao.codigoUsuario,
                                produtoId: produtoSelecionado.id,
                                context: context);
                          }
                        }
                      } else {
                        MaterialPageRoute authRoute = MaterialPageRoute(
                            builder: (context) => Authentication(0));
                        Navigator.push(context, authRoute);
                      }
                    }
                  : () {},
            ),
          ),
        );
      },
    );
  }

/*
  Widget comprarAgoraButton() {
    int horaAtual = (DateTime.now().toLocal().hour * 60) +
        (DateTime.now().toLocal().minute);
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Container(
            color: Colors.secundariaTheOffer,
            width: double.infinity,
            height: 45.0,
            child: FlatButton(
              child: Text(
                getHoraInicioProdutoHoje(produtoSelecionado) < horaAtual &&
                        getHoraFimProdutoHoje(produtoSelecionado) > horaAtual
                    ? produtoSelecionado.quantidadeRestante > 0
                        ? 'COMPRAR AGORA'
                        : 'FORA DE ESTOQUE'
                    : 'ESTABELECIMENTO FECHADO',
                style: TextStyle(
                    color: getHoraInicioProdutoHoje(produtoSelecionado) <
                                horaAtual &&
                            getHoraFimProdutoHoje(produtoSelecionado) >
                                horaAtual &&
                            produtoSelecionado.quantidadeRestante > 0
                        ? Colors.principalTheOffer
                        : Colors.grey),
              ),
              onPressed: getHoraInicioProdutoHoje(produtoSelecionado) <
                          horaAtual &&
                      getHoraFimProdutoHoje(produtoSelecionado) > horaAtual &&
                      produtoSelecionado.quantidadeRestante > 0
                  ? () {
                      if (getHoraInicioProdutoHoje(produtoSelecionado) <
                              horaAtual &&
                          getHoraFimProdutoHoje(produtoSelecionado) >
                              horaAtual &&
                          produtoSelecionado.quantidadeRestante > 0) {
                        if (Autenticacao.codigoUsuario > 0) {
                          model.comprarProduto(
                              usuarioId: Autenticacao.codigoUsuario,
                              produtoId: produtoSelecionado.id,
                              quantidade: quantidade,
                              context: context);
                        } else {
                          MaterialPageRoute authRoute = MaterialPageRoute(
                              builder: (context) => Authentication(0));
                          Navigator.push(context, authRoute);
                        }
                        if (model.pedido != null) {
                          if (!model.isLoading) {
                            MaterialPageRoute route = MaterialPageRoute(
                                builder: (context) => TelaFinalizarPedido());

                            Navigator.push(context, route);
                          }
                        }
                        if (produtoSelecionado.possuiSabores) {
                          MaterialPageRoute pagamentoRoute = MaterialPageRoute(
                              builder: (context) => TelaSabores(
                                  produtoSelecionado.id, quantidade));
                          Navigator.push(context, pagamentoRoute);
                        }
                      }
                    }
                  : () {},
            ),
          ),
        );
      },
    );
  }

  Widget adicionarCarrinhoButton() {
    int horaAtual = (DateTime.now().toLocal().hour * 60) +
        (DateTime.now().toLocal().minute);
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Container(
            color: Colors.secundariaTheOffer,
            width: double.infinity,
            height: 45.0,
            child: FlatButton(
              child: Text(
                getHoraInicioProdutoHoje(produtoSelecionado) < horaAtual &&
                        getHoraFimProdutoHoje(produtoSelecionado) > horaAtual
                    ? produtoSelecionado.quantidadeRestante > 0
                        ? 'ADICIONAR AO CARRINHO'
                        : 'FORA DE ESTOQUE'
                    : 'ESTABELECIMENTO FECHADO',
                style: TextStyle(
                    color: getHoraInicioProdutoHoje(produtoSelecionado) <
                                horaAtual &&
                            getHoraFimProdutoHoje(produtoSelecionado) >
                                horaAtual &&
                            produtoSelecionado.quantidadeRestante > 0
                        ? Colors.principalTheOffer
                        : Colors.grey),
              ),
              onPressed: getHoraInicioProdutoHoje(produtoSelecionado) <
                          horaAtual &&
                      getHoraFimProdutoHoje(produtoSelecionado) > horaAtual &&
                      produtoSelecionado.quantidadeRestante > 0
                  ? () {
                      if (Autenticacao.codigoUsuario > 0) {
                        if (getHoraInicioProdutoHoje(produtoSelecionado) <
                                horaAtual &&
                            getHoraFimProdutoHoje(produtoSelecionado) >
                                horaAtual &&
                            produtoSelecionado.quantidadeRestante > 0) {
                          if (widget.produto.possuiSabores) {
                            MaterialPageRoute pagamentoRoute =
                                MaterialPageRoute(
                                    builder: (context) => TelaSabores(
                                        produtoSelecionado.id, quantidade));
                            Navigator.push(context, pagamentoRoute);
                          } else {
                            model.adicionarProduto(
                                usuarioId: Autenticacao.codigoUsuario,
                                produtoId: produtoSelecionado.id,
                                quantidade: quantidade,
                                somar: 1);
                          }
                        }
                      } else {
                        MaterialPageRoute authRoute = MaterialPageRoute(
                            builder: (context) => Authentication(0));
                        Navigator.push(context, authRoute);
                      }
                    }
                  : () {},
            ),
          ),
        );
      },
    );
  }

  Widget adicionarCarrinhoFloatButton() {
    int horaAtual = (DateTime.now().toLocal().hour * 60) +
        (DateTime.now().toLocal().minute);
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return _tabController.index == 0
            ? FloatingActionButton(
                child: Icon(
                  Icons.shopping_basket,
                  color: Colors.secundariaTheOffer,
                ),
                onPressed: getHoraInicioProdutoHoje(produtoSelecionado) <
                            horaAtual &&
                        getHoraFimProdutoHoje(produtoSelecionado) > horaAtual &&
                        produtoSelecionado.quantidadeRestante > 0
                    ? () {
                        if (Autenticacao.codigoUsuario > 0) {
                          if (widget.produto.possuiSabores) {
                            MaterialPageRoute pagamentoRoute =
                                MaterialPageRoute(
                                    builder: (context) => TelaSabores(
                                        produtoSelecionado.id, quantidade));
                            Navigator.push(context, pagamentoRoute);
                          } else {
                            model.adicionarProduto(
                                usuarioId: Autenticacao.codigoUsuario,
                                produtoId: produtoSelecionado.id,
                                quantidade: quantidade,
                                somar: 1);
                          }
                        } else {
                          MaterialPageRoute authRoute = MaterialPageRoute(
                              builder: (context) => Authentication(0));
                          Navigator.push(context, authRoute);
                        }
                      }
                    : () {},
                backgroundColor: getHoraInicioProdutoHoje(produtoSelecionado) <
                            horaAtual &&
                        getHoraFimProdutoHoje(produtoSelecionado) > horaAtual &&
                        produtoSelecionado.quantidadeRestante > 0
                    ? Colors.principalTheOffer
                    : Colors.grey,
              )
            : FloatingActionButton(
                child: Icon(
                  Icons.add,
                  color: Colors.blue,
                ),
                onPressed: () {},
                backgroundColor: Colors.orange);
      },
    );
  }*/

  Widget linhaPrecos(String key, String value, {bool strike, String valor}) {
    return Container(
        color: Colors.secundariaTheOffer,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.all(10),
              child: Text(
                key,
                style: TextStyle(
                  fontSize: 17,
                  fontFamily: fontFamily,
                  color: Colors.principalTheOffer,
                ),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.all(10),
              child: strike
                  ? RichText(
                      text: TextSpan(children: [
                        TextSpan(
                            text: valor,
                            style: TextStyle(
                                color: Colors.principalTheOffer,
                                decoration: TextDecoration.lineThrough)),
                        TextSpan(text: '   '),
                        TextSpan(
                            text: value,
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.principalTheOffer,
                                fontFamily: fontFamily,
                                fontWeight: FontWeight.bold)),
                      ]),
                    )
                  : discount
                      ? RichText(
                          text: TextSpan(children: [
                            TextSpan(
                                text: '0',
                                style: TextStyle(
                                  color: Colors.principalTheOffer,
                                )),
                            TextSpan(
                                text: value,
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.principalTheOffer,
                                    fontFamily: fontFamily,
                                    fontWeight: FontWeight.bold)),
                          ]),
                        )
                      : Text(
                          value,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.principalTheOffer,
                            fontWeight: FontWeight.bold,
                            fontFamily: fontFamily,
                          ),
                        ),
            ),
          ],
        ));
  }

  Widget pincodeBox(MainModel model, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Container(
          width: _deviceSize.width * 0.60,
          height: 70,
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(bottom: 15, left: 10),
          child: Form(
            key: _formKey,
            child: TextFormField(
              initialValue: pincode,
              decoration: InputDecoration(
                  labelText: 'Codigo',
                  labelStyle: TextStyle(color: Colors.grey),
                  contentPadding: EdgeInsets.all(0.0)),
              onSaved: (String value) {
                setState(() {
                  pincode = value;
                });
              },
            ),
          ),
        ),
        FlatButton(
            child: Container(
              child: Text(
                'VERIFICAR',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.secundariaTheOffer),
              ),
            ),
            onPressed: () async {}),
      ],
    );
  }
/*
  getSimilarProducts() {
    Map<String, dynamic> responseBody = Map();
    List<OptionValue> optionValues = [];
    List<OptionType> optionTypes = [];
    http
        .get(Settings.SERVER_URL +
            'api/v1/taxons/products?id=${widget.produto.taxonId}&per_page=15&data_set=small')
        .then((response) {
      responseBody = json.decode(response.body);
      responseBody['products'].forEach((product) {
        int reviewProductId = product["id"];
        variants = [];
        if (product['has_variants']) {
          product['variants'].forEach((variant) {
            optionValues = [];
            optionTypes = [];
            variant['option_values'].forEach((option) {
              setState(() {
                optionValues.add(OptionValue(
                  id: option['id'],
                  name: option['name'],
                  optionTypeId: option['option_type_id'],
                  optionTypeName: option['option_type_name'],
                  optionTypePresentation: option['option_type_presentation'],
                ));
              });
            });
            setState(() {
              variants.add(Product(
                  id: variant['id'],
                  name: variant['name'],
                  description: variant['description'],
                  slug: variant['slug'],
                  optionValues: optionValues,
                  displayPrice: variant['display_price'],
                  image: variant['images'][0]['product_url'],
                  isOrderable: variant['is_orderable'],
                  avgRating: double.parse(product['avg_rating']),
                  reviewsCount: product['reviews_count'].toString(),
                  reviewProductId: reviewProductId));
            });
          });
          product['option_types'].forEach((optionType) {
            setState(() {
              optionTypes.add(OptionType(
                  id: optionType['id'],
                  name: optionType['name'],
                  position: optionType['position'],
                  presentation: optionType['presentation']));
            });
          });
          setState(() {
            similarProducts.add(Product(
                taxonId: product['taxon_ids'].first,
                id: product['id'],
                name: product['name'],
                slug: product['slug'],
                displayPrice: product['display_price'],
                avgRating: double.parse(product['avg_rating']),
                reviewsCount: product['reviews_count'].toString(),
                image: product['master']['images'][0]['product_url'],
                variants: variants,
                reviewProductId: reviewProductId,
                hasVariants: product['has_variants'],
                optionTypes: optionTypes));
          });
        } else {
          setState(() {
            similarProducts.add(Product(
              taxonId: product['taxon_ids'].first,
              id: product['id'],
              name: product['name'],
              slug: product['slug'],
              displayPrice: product['display_price'],
              avgRating: double.parse(product['avg_rating']),
              reviewsCount: product['reviews_count'].toString(),
              image: product['master']['images'][0]['product_url'],
              hasVariants: product['has_variants'],
              isOrderable: product['master']['is_orderable'],
              reviewProductId: reviewProductId,
              description: product['description'],
            ));
          });
        }
      });
      setState(() {
        _isLoading = false;
      });
    });
  }*/
}
