import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:theoffer/utils/headers.dart';
import 'package:theoffer/utils/locator.dart';
import 'package:theoffer/models/banners.dart';
import 'package:theoffer/models/Produto.dart';
import 'package:theoffer/utils/constants.dart';
import 'package:theoffer/screens/produtos.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:theoffer/models/categoria.dart';
import 'package:theoffer/scoped-models/main.dart';
import 'package:theoffer/utils/drawer_homescreen.dart';
import 'package:theoffer/utils/connectivity_state.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TelaCategorias extends StatefulWidget {
  final int idCidade;
  TelaCategorias({this.idCidade});
  @override
  State<StatefulWidget> createState() {
    return _TelaCategorias();
  }
}

class _TelaCategorias extends State<TelaCategorias> {
  Size _deviceSize;
  Map<dynamic, dynamic> responseBody;
  bool _carregandoCategoria = true;
  List<Categoria> listaCategoria = [];
  List<Produto> listaProdutos = [];
  List<BannerImage> banners = [];
  List<String> bannerImageUrls = [];
  List<String> bannerLinks = [];
  int favCount;

  @override
  void initState() {
    super.initState();
    getCategorias();
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
      return Scaffold(
        appBar: AppBar(
            title: Image.asset(
              'images/logos/appBar.png',
              fit: BoxFit.fill,
              height: 55,
            ),
            iconTheme: new IconThemeData(color: Colors.principalTheOffer)),
        drawer: HomeDrawer(),
        body: Container(
          color: Colors.secundariaTheOffer,
          child: CustomScrollView(slivers: [
            _carregandoCategoria
                ? SliverList(
                    delegate: SliverChildListDelegate([
                    Container(
                      height: _deviceSize.height * 1,
                      alignment: Alignment.center,
                      child: Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.secundariaTheOffer,
                        ),
                      ),
                    )
                  ]))
                : listaCategoria.length > 0
                    ? SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2),
                        delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                          return cardCategoria(
                              index, context, _deviceSize, listaCategoria);
                        }, childCount: listaCategoria.length),
                      )
                    : SliverList(
                        delegate: SliverChildListDelegate([
                          Container(
                            width: _deviceSize.width,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage("images/fundoBranco.png"),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Center(
                              child: Text('Sem categorias.'),
                            ),
                          ),
                        ]),
                      ),
          ]),
        ),
      );
    });
  }

  Widget cardCategoria(int index, BuildContext context, Size _deviceSize,
      List<Categoria> listaCategoria) {
    return GestureDetector(
        onTap: () {
          MaterialPageRoute route = MaterialPageRoute(
              builder: (context) =>
                  TelaProdutos(idCategoria: listaCategoria[index].id));
          Navigator.push(context, route);
        },
        child: Container(
            margin: EdgeInsets.all(5.0),
            width: _deviceSize.width * 0.4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: Colors.principalTheOffer,
                width: 1,
              ),
              color: Colors.secundariaTheOffer,
            ),
            child: Stack(children: [
              Container(
                margin: EdgeInsets.only(left: 5, right: 5, bottom: 5, top: 30),
                alignment: Alignment.center,
                child:
                    CachedNetworkImage(imageUrl: listaCategoria[index].imagem),
              ),
              Container(
                margin: EdgeInsets.only(left: 20, top: 5),
                height: 20,
                width: 150,
                color: Colors.principalTheOffer,
                alignment: Alignment.center,
                child: RichText(
                  text: TextSpan(
                    text: listaCategoria[index].nome[0].toUpperCase() +
                        listaCategoria[index].nome.toLowerCase().substring(1),
                    style: TextStyle(
                        color: Colors.secundariaTheOffer,
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ])));
  }

  getCategorias() async {
    Map<String, String> headers = getHeaders();
    http
        .get(Configuracoes.BASE_URL + 'categorias/', headers: headers)
        .then((response) {
      setState(() {
        _carregandoCategoria = true;
        listaProdutos = [];
      });
      responseBody = json.decode(response.body);
      responseBody['categorias'].forEach((categoriaJson) {
        listaCategoria.add(Categoria(
            id: int.parse(categoriaJson['id']),
            nome: categoriaJson['nome'],
            imagem: categoriaJson['imagem']));
      });
      setState(() {
        _carregandoCategoria = false;
      });
    });
  }
}
