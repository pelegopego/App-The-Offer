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
            bottom: 
              PreferredSize(
                preferredSize: Size(_deviceSize.width, 100),
                child: Column(
                  children: <Widget> [
                      searchBar(),
                      trocarCategoria(),
                  ],               
                )  
              ),
            iconTheme: new IconThemeData(color: Colors.principalTheOffer)
          ),
        drawer: HomeDrawer(),
        body: Container(
          color: Colors.terciariaTheOffer,
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
                        ? _deviceSize.height * 0.70
                        : _deviceSize.height * 0.77,
                      child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: listaProdutoEmpresa.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            if (listaProdutoEmpresa[index].listaProduto.length >
                                0) {
                              return cardProdutosEmpresa(index,
                                  listaProdutoEmpresa, _deviceSize, context);
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
            MaterialPageRoute route = MaterialPageRoute(
                builder: (context) => TelaPesquisaProduto());
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
        .post(Configuracoes.BASE_URL + 'produtos', headers: headers, body: objetoItemPedido)
        .then((response) {
      responseBody = json.decode(response.body);
      responseBody['empresas'].forEach((empresaJson) {
        setState(() {
          _listaProduto = [];

          if (empresaJson['produtos'] != null) {
            empresaJson['produtos'].forEach((produtoJson) {
              setState(() {
                _listaProduto.add(Produto(
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
                  color: Colors.white,
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
          style: TextStyle(
                   color: Colors.principalTheOffer,
                   fontSize: 12),
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
