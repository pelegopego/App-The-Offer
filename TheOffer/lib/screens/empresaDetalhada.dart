import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:theoffer/models/Produto.dart';
import 'package:theoffer/scoped-models/main.dart';
import 'package:theoffer/screens/autenticacao.dart';
import 'package:theoffer/models/EmpresaDetalhada.dart';
import 'package:theoffer/utils/connectivity_state.dart';
import 'package:theoffer/utils/constants.dart';
import 'package:theoffer/utils/drawer_homescreen.dart';
import 'package:theoffer/utils/locator.dart';
import 'package:theoffer/widgets/botaoCarrinho.dart';
import 'package:theoffer/widgets/cardProdutos.dart';
import 'package:theoffer/models/banners.dart';
import 'package:theoffer/utils/headers.dart';
import 'package:scoped_model/scoped_model.dart';

class TelaEmpresaDetalhada extends StatefulWidget {
  final int idEmpresa;
  TelaEmpresaDetalhada({this.idEmpresa});
  @override
  
  State<StatefulWidget> createState() {
    return _TelaEmpresaDetalhada();
  }
}

class _TelaEmpresaDetalhada extends State<TelaEmpresaDetalhada> {
  Size _deviceSize;
  Map<dynamic, dynamic> responseBody;
  bool _empresasLoading = true;
  EmpresaDetalhada empresaDetalhada;
  List<BannerImage> banners = [];
  List<String> bannerImageUrls = [];
  List<String> bannerLinks = [];
  int favCount;

  @override
  void initState() {
    super.initState();
    getEmpresaDetalhe();
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
            leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.principalTheOffer,
                ),
                onPressed: () {
                  Navigator.pop(context);
                }),
            actions: <Widget>[
              shoppingCarrinhoIconButton(),
            ],
        ),
        drawer: HomeDrawer(),
        body: Container(
          color: Colors.terciariaTheOffer,
          child: CustomScrollView(slivers: [
            _empresasLoading
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
                        ? _deviceSize.height * 0.80
                        : _deviceSize.height * 0.87,
                      child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: empresaDetalhada.listaCategoria.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {                            
                            if (empresaDetalhada.listaCategoria.length > 0) {
                              if (index == 0) {
                                  return Column(mainAxisAlignment: MainAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.max,
                                              children: <Widget>[
                                              Card(shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12)),
                                            elevation: 1,
                                            margin: EdgeInsets.all(8.0),
                                            child: Container(
                                              color: Colors.secundariaTheOffer,
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
                                                        image: NetworkImage(empresaDetalhada.imagem),
                                                          placeholder: AssetImage('images/placeholders/no-product-image.png'),
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
                                                                          '${empresaDetalhada.fantasia} ',
                                                                      style: TextStyle(
                                                                          color: Colors.principalTheOffer,
                                                                          fontSize: 15.0,
                                                                          fontWeight: FontWeight.bold),
                                                                    ),
                                                                  ]),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        SizedBox(height: 10),
                                                        Container(
                                                          alignment: Alignment.topLeft,
                                                          child: Text(
                                                            empresaDetalhada.telefone.toString(),
                                                            textAlign: TextAlign.left,
                                                            style: TextStyle(
                                                                color: Colors.principalTheOffer,
                                                                fontSize: 18),
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  ),
                                                ],
                                              )
                                          )
                                        ),
                                  ]
                                );
                              } else {
                                return cardProdutosCategoria(index, empresaDetalhada.listaCategoria, _deviceSize, context);
                              }
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

  getEmpresaDetalhe() async {
    Map<dynamic, dynamic> objetoItemPedido = Map();
    Map<String, String> headers = getHeaders();
    List<Produto> _listaProduto;
    List<CategoriaDetalhada> _listaCategoriaDetalhada;
    setState(() {
      _empresasLoading = true;
    });

    objetoItemPedido = {
      "empresa": widget.idEmpresa.toString(),
      "cidade": CidadeSelecionada.id.toString()
    };
    http
        .post(Configuracoes.BASE_URL + 'produtos/localizarPorEmpresa', headers: headers, body: objetoItemPedido)
        .then((response) {
      responseBody = json.decode(response.body);
      responseBody['empresas'].forEach((empresaJson) {
        if (empresaJson['categorias'] != null) {
          _listaCategoriaDetalhada = [];
          
          _listaCategoriaDetalhada.add(CategoriaDetalhada(
              id: 0,
              nome: '',
              imagem: '',
              listaProduto: null
              ));

          empresaJson['categorias'].forEach((categoriasJson) {
              _listaProduto = [];
              if (categoriasJson['produtos'] != null) {
                categoriasJson['produtos'].forEach((produtosJson) {
                  setState(() {
                    _listaProduto.add(Produto(
                        id                    : int.parse(produtosJson['id']),
                        titulo                : produtosJson['titulo'],
                        descricao             : produtosJson['descricao'],
                        imagem                : produtosJson['imagem'],
                        valor                 : produtosJson['valor'],
                        valorNumerico         : double.parse(produtosJson['valorNumerico']),
                        quantidade            : int.parse(produtosJson['quantidade']),
                        quantidadeRestante    : int.parse(produtosJson['quantidadeRestante']),
                        dataInicial           : produtosJson['dataInicial'],
                        dataFinal             : produtosJson['dataFinal'],
                        dataCadastro          : produtosJson['dataCadastro'],
                        usuarioId             : int.parse(produtosJson['usuario_id'])));
                  });
                });
              setState(() {
                _listaCategoriaDetalhada.add(CategoriaDetalhada(
                    id: int.parse(categoriasJson['id']),
                    nome: categoriasJson['nome'],
                    imagem: categoriasJson['imagem'],
                    listaProduto: _listaProduto
                    ));
              });
            }
          });
        }
        empresaDetalhada = EmpresaDetalhada(id            : int.parse(empresaJson['id']), 
                                            imagem        : empresaJson['imagem'],
                                            razaoSocial   : empresaJson['razaosocial'], 
                                            fantasia      : empresaJson['fantasia'], 
                                            telefone      : num.parse(empresaJson['telefone']), 
                                            listaCategoria: _listaCategoriaDetalhada);
      });
      setState(() {
        _empresasLoading = false;
      });
    });
  }
}
