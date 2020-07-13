import 'dart:convert';
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
            actions: <Widget>[
              shoppingCarrinhoIconButton(),
            ],
            iconTheme: new IconThemeData(color: Colors.principalTheOffer)),
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
                    child: 
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Row(
                          children: <Widget>[Padding(
                              padding: const EdgeInsets.only(left: 40.0),
                              child: Text(
                                '${empresaDetalhada.fantasia}',
                                style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.secundariaTheOffer,
                                    fontFamily: fontFamily),
                              ),
                            ),
                          ],
                        ),
                    ),
                ),
                _empresasLoading
                ? SliverToBoxAdapter(
                    child: Divider(
                      height: 0,
                    ),
                  )
                : SliverToBoxAdapter(
                    child: Divider(
                      height: 10,
                    ),
                  ),
                
                _empresasLoading
                ? SliverToBoxAdapter(
                    child: Divider(
                      height: 0,
                    ),
                  )
                : SliverToBoxAdapter(
                child: Container(
                  alignment: Alignment.center,    
                  height: 320,
                  width: 390,
                  child: FadeInImage(
                    image: NetworkImage(empresaDetalhada.imagem),
                    placeholder: AssetImage(
                        'images/placeholders/no-product-image.png'),  
                  ),
                ),
                ),
                _empresasLoading
               ? SliverToBoxAdapter(
                    child: Divider(
                      height: 0,
                    ),
                  )
                : SliverToBoxAdapter(
                    child: Container(
                      height: Autenticacao.codigoUsuario == 0
                        ? _deviceSize.height * 0.70
                        : _deviceSize.height * 0.77,
                      child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: empresaDetalhada.listaCategoria.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            if (empresaDetalhada.listaCategoria[index].listaProduto.length >
                                0) {
                              return cardProdutosCategoria(index, empresaDetalhada.listaCategoria, _deviceSize, context);
                            } else {
                              return Container();
                            }
                          }),
                    ),
                  ),
          ]),
        ),
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
          empresaJson['categorias'].forEach((categoriasJson) {
              if (categoriasJson['produtos'] != null) {
                _listaProduto = [];
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
                        modalidadeRecebimento1: int.parse(produtosJson['modalidadeRecebimento1']),
                        modalidadeRecebimento2: int.parse(produtosJson['modalidadeRecebimento2']),
                        usuarioId             : int.parse(produtosJson['usuario_id'])));
                  });
                });
            }
            setState(() {
              _listaCategoriaDetalhada.add(CategoriaDetalhada(
                  id: int.parse(categoriasJson['id']),
                  nome: categoriasJson['nome'],
                  imagem: categoriasJson['imagem'],
                  listaProduto: _listaProduto
                  ));
            });
          });
        }
         empresaDetalhada = EmpresaDetalhada(id           : int.parse(empresaJson['id']), 
                                             imagem       : empresaJson['imagem'],
                                            razaoSocial   : empresaJson['razaosocial'], 
                                            fantasia      : empresaJson['fantasia'], 
                                            listaCategoria: _listaCategoriaDetalhada);
      });
      setState(() {
        _empresasLoading = false;
      });
    });
  }
}
