import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:theoffer/models/Produto.dart';
import 'package:theoffer/models/ProdutoEmpresa.dart';
import 'package:theoffer/scoped-models/main.dart';
import 'package:theoffer/screens/autenticacao.dart';
import 'package:theoffer/screens/categorias.dart';
import 'package:theoffer/screens/pesquisaProduto.dart';
import 'package:theoffer/utils/connectivity_state.dart';
import 'package:theoffer/utils/locator.dart';
import 'package:theoffer/utils/constants.dart';
import 'package:theoffer/utils/drawer_homescreen.dart';
import 'package:theoffer/widgets/botaoCarrinho.dart';
import 'package:theoffer/widgets/cardProdutos.dart';
import 'package:theoffer/models/banners.dart';
import 'package:theoffer/utils/headers.dart';
import 'package:theoffer/screens/empresaDetalhada.dart';
import 'package:scoped_model/scoped_model.dart';

class TelaProdutos extends StatefulWidget {
  final int idCategoria;
  TelaProdutos({this.idCategoria});
  @override
  State<StatefulWidget> createState() {
    return _TelaProdutos();
  }
}

class _TelaProdutos extends State<TelaProdutos> {
  Size _deviceSize;
  Map<dynamic, dynamic> responseBody;
  bool _isBannerLoading = true;
  bool _produtosLoading = true;
  List<ProdutoEmpresa> listaProdutoEmpresa = [];
  List<Produto> _listaProduto = [];
  List<BannerImage> banners = [];
  List<String> bannerImageUrls = [];
  List<String> bannerLinks = [];
  int favCount;
  bool _localizarCarrinho = false;

  @override
  void initState() {
    super.initState();
    // getFavoritesCount();
    //getBanners();
    getProdutos();
    _localizarCarrinho = true;
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
    List<Widget> actions = [];

    for (int i = 0; i < banners.length; i++) {
      actions.add(bannerCards(i));
    }
/*
    Widget bannerCarousel = CarouselSlider(
      items: _isBannerLoading ? [bannerCards(0)] : actions,
      autoPlay: true,
      enlargeCenterPage: true,
    );*/
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      if (_localizarCarrinho) {
        _localizarCarrinho = false;
        model.verificarPedidoPendente(
            null, Autenticacao.codigoUsuario, context);
        model.localizarCarrinho(null, Autenticacao.codigoUsuario);
      }
      return Scaffold(
        appBar: AppBar(
            title: Image.asset(
              'images/logos/appBar.png',
              fit: BoxFit.fill,
              height: 55,
            ),
            actions: <Widget>[
              shoppingCarrinhoIconButton(),
            ],
            bottom: PreferredSize(
                preferredSize: Size(_deviceSize.width, 110),
                child: Column(
                  children: <Widget>[
                    searchBar(),
                    trocarCategoria(),
                  ],
                )),
            iconTheme: new IconThemeData(color: Colors.principalTheOffer)),
        drawer: HomeDrawer(),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/fundoBranco.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: CustomScrollView(slivers: [
            /*SliverList(
              delegate: SliverChildListDelegate([
                Container(
                    color: Colors.grey.withOpacity(0.1), child: bannerCarousel)
              ]),
            ),*/
            SliverToBoxAdapter(
              child: Divider(
                height: 1.0,
              ),
            ),
            _produtosLoading
                ? SliverList(
                    delegate: SliverChildListDelegate([
                    Container(
                      height: _deviceSize.height * 0.47,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.secundariaTheOffer,
                      ),
                    )
                  ]))
                : SliverToBoxAdapter(
                    child: Container(
                      height: Autenticacao.codigoUsuario == 0
                          ? _deviceSize.height * 0.64
                          : _deviceSize.height * 0.72,
                      child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: listaProdutoEmpresa.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            if (listaProdutoEmpresa[index].listaProduto.length >
                                0) {
                              return Container(
                                  padding:
                                      listaProdutoEmpresa[index].cardVisivel
                                          ? EdgeInsets.all(0)
                                          : EdgeInsets.only(left: 5, right: 5),
                                  child: montarCardProdutosEmpresa(index));
                            } else {
                              return Container();
                            }
                          }),
                    ),
                  ),
          ]),
        ),
        bottomNavigationBar: bottomNavigationBar(),
      );
    });
  }

  Widget montarCardProdutosEmpresa(index) {
    return SizedBox(
        width: _deviceSize.width * 0.4,
        child: Container(
            margin: EdgeInsets.only(
                bottom: listaProdutoEmpresa[index].cardVisivel ? 0 : 5),
            decoration: listaProdutoEmpresa[index].cardVisivel
                ? BoxDecoration()
                : BoxDecoration(
                    border: Border.all(
                      color: Colors.secundariaTheOffer,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(5)),
            child: Column(children: <Widget>[
              Container(
                width: _deviceSize.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                        child: Row(children: <Widget>[
                      GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            MaterialPageRoute route = MaterialPageRoute(
                                builder: (context) => TelaEmpresaDetalhada(
                                    idEmpresa:
                                        listaProdutoEmpresa[index].empresaId));
                            Navigator.push(context, route);
                          },
                          child: Container(
                              padding:
                                  const EdgeInsets.only(left: 12, right: 12),
                              height: 45,
                              child: Row(children: <Widget>[
                                Icon(
                                  Icons.business,
                                  color: Colors.secundariaTheOffer,
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Text(
                                    listaProdutoEmpresa[index]
                                            .fantasia[0]
                                            .toUpperCase() +
                                        listaProdutoEmpresa[index]
                                            .fantasia
                                            .toLowerCase()
                                            .substring(1),
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.secundariaTheOffer)),
                              ]))),
                      Expanded(
                          child: Container(
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            if (listaProdutoEmpresa[index].cardVisivel) {
                              setState(() {
                                listaProdutoEmpresa[index].cardVisivel = false;
                              });
                            } else {
                              setState(() {
                                listaProdutoEmpresa[index].cardVisivel = true;
                              });
                            }
                          },
                        ),
                        alignment: Alignment.center,
                        height: 45,
                      )),
                      GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            if (listaProdutoEmpresa[index].cardVisivel) {
                              setState(() {
                                listaProdutoEmpresa[index].cardVisivel = false;
                              });
                            } else {
                              setState(() {
                                listaProdutoEmpresa[index].cardVisivel = true;
                              });
                            }
                          },
                          child: Container(
                              child: Row(
                            children: <Widget>[
                              Container(
                                height: 45,
                                child: IconButton(
                                    iconSize: 30,
                                    color: Colors.secundariaTheOffer,
                                    icon: listaProdutoEmpresa[index].cardVisivel
                                        ? Icon(Icons.arrow_drop_up)
                                        : Icon(Icons.arrow_drop_down),
                                    onPressed: () {
                                      if (listaProdutoEmpresa[index]
                                          .cardVisivel) {
                                        setState(() {
                                          listaProdutoEmpresa[index]
                                              .cardVisivel = false;
                                        });
                                      } else {
                                        setState(() {
                                          listaProdutoEmpresa[index]
                                              .cardVisivel = true;
                                        });
                                      }
                                    }),
                              ),
                            ],
                          )))
                    ])),
                  ],
                ),
              ),
              Container(
                height: listaProdutoEmpresa[index].cardVisivel ? 260 : 0,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: listaProdutoEmpresa[index].listaProduto.length,
                    itemBuilder: (context, index2) {
                      if (listaProdutoEmpresa[index].listaProduto.length > 0) {
                        return Container(
                            child: Visibility(
                                visible: listaProdutoEmpresa[index].cardVisivel,
                                child: Container(
                                    child: cardProdutos(
                                        index2,
                                        listaProdutoEmpresa[index].listaProduto,
                                        _deviceSize,
                                        context))));
                      } else {
                        return Container();
                      }
                    }),
              ),
              Divider(
                height: 5,
              ),
            ])));
  }

  Widget bottomNavigationBar() {
    if (Autenticacao.codigoUsuario == 0) {
      return BottomNavigationBar(
        backgroundColor: Colors.secundariaTheOffer,
        onTap: (index) {
          MaterialPageRoute route =
              MaterialPageRoute(builder: (context) => Authentication(index));

          Navigator.push(context, route);
        },
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline, color: Colors.principalTheOffer),
              title: Text('ENTRAR',
                  style: TextStyle(
                      color: Colors.principalTheOffer,
                      fontSize: 15,
                      fontWeight: FontWeight.w600))),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.person_outline,
                color: Colors.principalTheOffer,
              ),
              title: Text('CRIAR CONTA',
                  style: TextStyle(
                      color: Colors.principalTheOffer,
                      fontSize: 15,
                      fontWeight: FontWeight.w600))),
        ],
      );
    } else {
      return Padding(padding: EdgeInsets.all(0));
    }
  }

  Widget bannerCards(int index) {
    if (_isBannerLoading) {
      return Container(
        width: _deviceSize.width * 0.8,
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          elevation: 2,
          margin: EdgeInsets.symmetric(
              vertical: _deviceSize.height * 0.05,
              horizontal: _deviceSize.width * 0.02),
          child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              child: Image.asset(
                'images/placeholders/slider1.jpg',
                fit: BoxFit.fill,
              )),
        ),
      );
    } else {
      return GestureDetector(
          onTap: () {
            MaterialPageRoute route =
                MaterialPageRoute(builder: (context) => TelaPesquisaProduto());
            Navigator.of(context).push(route);
          },
          child: Container(
            width: _deviceSize.width * 0.8,
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
              elevation: 2,
              margin: EdgeInsets.symmetric(
                  vertical: _deviceSize.height * 0.05,
                  horizontal: _deviceSize.width * 0.02),
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(4)),
                child: FadeInImage(
                  image: NetworkImage(banners[index].imageUrl != null
                      ? banners[index].imageUrl
                      : ''),
                  placeholder: AssetImage('images/placeholders/slider1.jpg'),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ));
    }
  }

  getProdutos() async {
    Map<dynamic, dynamic> objetoItemPedido = Map();
    Map<String, String> headers = getHeaders();
    setState(() {
      _produtosLoading = true;
      listaProdutoEmpresa = [];
    });

    objetoItemPedido = {
      "categoria": widget.idCategoria.toString(),
      "cidade": CidadeSelecionada.id.toString()
    };
    http
        .post(Configuracoes.BASE_URL + 'produtos',
            headers: headers, body: objetoItemPedido)
        .then((response) {
      responseBody = json.decode(response.body);
      responseBody['empresas'].forEach((empresaJson) {
        setState(() {
          _listaProduto = [];

          if (empresaJson['produtos'] != null) {
            empresaJson['produtos'].forEach((produtoJson) {
              setState(() {
                _listaProduto.add(Produto(
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
                    empresaHoraInicio: double.parse(empresaJson['horaInicio']),
                    empresaHoraFim: double.parse(empresaJson['horaFim']),
                    dataCadastro: produtoJson['dataCadastro'],
                    categoria: int.parse(produtoJson['categoria_id']),
                    possuiSabores: int.parse(produtoJson['possuiSabores']) > 0,
                    usuarioId: int.parse(produtoJson['usuario_id'])));
              });
            });
          }
          listaProdutoEmpresa.add(
            ProdutoEmpresa(
                empresaId: int.parse(empresaJson['id']),
                imagem: empresaJson['imagem'],
                razaoSocial: empresaJson['razaosocial'],
                fantasia: empresaJson['fantasia'],
                horaInicio: double.parse(empresaJson['horaInicio']),
                horaFim: double.parse(empresaJson['horaFim']),
                cardVisivel: false,
                listaProduto: _listaProduto),
          );
        });
      });
      setState(() {
        _produtosLoading = false;
      });
    });
  }

  Widget searchBar() {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return GestureDetector(
          onTap: () {
            MaterialPageRoute route =
                MaterialPageRoute(builder: (context) => TelaPesquisaProduto());
            Navigator.of(context).push(route);
          },
          child: Column(children: [
            Container(
              decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Colors.white, //Barra de pesquisa
                  borderRadius: BorderRadius.circular(5)),
              width: _deviceSize.width,
              height: 49,
              margin: EdgeInsets.only(top: 10, left: 10, right: 10),
              child: ListTile(
                leading: Icon(Icons.search, color: Colors.secundariaTheOffer),
                title: Text(
                  'Encontrar produtos...',
                  style: TextStyle(
                      fontWeight: FontWeight.w300,
                      color: Colors.secundariaTheOffer),
                ),
              ),
            ),
            model.isLoading ? LinearProgressIndicator() : Container()
          ]));
    });
  }

  Widget trocarCategoria() {
    return ScopedModelDescendant(
        builder: (BuildContext context, Widget child, MainModel model) {
      return ListTile(
        leading: Icon(
          Icons.refresh,
          color: Colors.principalTheOffer,
        ),
        title: Text(
          'Trocar categoria',
          style: TextStyle(color: Colors.principalTheOffer, fontSize: 12),
        ),
        onTap: () {
          MaterialPageRoute route =
              MaterialPageRoute(builder: (context) => TelaCategorias());
          Navigator.of(context).push(route);
        },
      );
    });
  }

  getBanners() async {
    /*
    http
        .get(Settings.SERVER_URL +
            'api/v1/taxonomies?q[name_cont]=Landing_Banner&set=nested')
        .then((response) {
      responseBody = json.decode(response.body);
      responseBody['taxonomies'][0]['root']['taxons'].forEach((banner) {
        setState(() {
          banners.add(BannerImage(
              imageSlug: banner['meta_title'], imageUrl: banner['icon']));
          bannerImageUrls.add(banner['icon']);
          bannerLinks.add(banner['meta_title']); //  meta_title
        });
      });
      setState(() {
        _isBannerLoading = false;
      });
    });*/
  }
}
