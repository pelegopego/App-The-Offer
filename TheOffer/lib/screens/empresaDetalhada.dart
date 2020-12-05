import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
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
//import 'package:theoffer/widgets/botaoCarrinho.dart';
import 'package:theoffer/widgets/cardProdutos.dart';
import 'package:theoffer/models/banners.dart';
import 'package:theoffer/utils/headers.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:theoffer/utils/hora.dart';

class TelaEmpresaDetalhada extends StatefulWidget {
  final int idCategoria;
  final int idEmpresa;
  TelaEmpresaDetalhada({this.idCategoria, this.idEmpresa});
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

    _callMe(String phone) async {
      final uri = 'tel:$phone';
      if (await canLaunch(uri)) {
        await launch(uri);
      } else {
        throw 'Não foi possível $uri';
      }
    }

    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      TableRow gerarLinha(String dia, String horario) {
        return TableRow(children: [
          TableCell(
              child: Center(
                  child: Container(
                      margin: EdgeInsets.only(right: 2),
                      child: Align(
                          alignment: Alignment.topRight,
                          child: Text(dia,
                              style: TextStyle(
                                  color: Colors.principalTheOffer,
                                  fontSize: 18)))))),
          TableCell(
              child: Center(
                  child: Container(
                      margin: EdgeInsets.only(left: 8),
                      padding: EdgeInsets.all(5),
                      width: 150,
                      height: 50,
                      color: Colors.principalTheOffer,
                      child: Text(horario,
                          style: TextStyle(
                              color: Colors.secundariaTheOffer,
                              fontSize: 15))))),
        ]);
      }

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
          /*actions: <Widget>[
            shoppingCarrinhoIconButton(),
          ],*/
        ),
        drawer: HomeDrawer(),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/fundoBranco.png"),
              fit: BoxFit.cover,
            ),
          ),
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
                                return Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      Card(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                          elevation: 1,
                                          margin: EdgeInsets.all(8.0),
                                          child: Container(
                                              color: Colors.secundariaTheOffer,
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Stack(
                                                    children: <Widget>[
                                                      Container(
                                                        padding:
                                                            EdgeInsets.all(15),
                                                        height: 170,
                                                        width: 180,
                                                        decoration: BoxDecoration(
                                                            color: Colors
                                                                .secundariaTheOffer,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5)),
                                                        child: CachedNetworkImage(
                                                            imageUrl:
                                                                empresaDetalhada
                                                                    .imagem),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Expanded(
                                                      child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: <Widget>[
                                                      Container(
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: <Widget>[
                                                            Container(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      top: 10),
                                                              width: 150,
                                                              child: RichText(
                                                                text: TextSpan(
                                                                    children: [
                                                                      TextSpan(
                                                                        text: empresaDetalhada.fantasia[0].toUpperCase() +
                                                                            empresaDetalhada.fantasia.toLowerCase().substring(1),
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.principalTheOffer,
                                                                            fontSize: 19),
                                                                      ),
                                                                    ]),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(height: 10),
                                                      Container(
                                                        color: Colors
                                                            .principalTheOffer,
                                                        child: InkWell(
                                                          onTap: () {
                                                            _callMe(
                                                                empresaDetalhada
                                                                    .telefone
                                                                    .toString());
                                                          },
                                                          child: ListTile(
                                                            leading: Icon(
                                                              Icons.call,
                                                              color: Colors
                                                                  .secundariaTheOffer,
                                                            ),
                                                            title: Text(
                                                              empresaDetalhada
                                                                  .maskTelefone(),
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .secundariaTheOffer),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(height: 10),
                                                      Container(
                                                        color: Colors
                                                            .principalTheOffer,
                                                        child: InkWell(
                                                          child: ListTile(
                                                            leading: Icon(
                                                              Icons
                                                                  .calendar_today,
                                                              color: Colors
                                                                  .secundariaTheOffer,
                                                            ),
                                                            onTap: () {
                                                              showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (BuildContext
                                                                          context) {
                                                                    return AlertDialog(
                                                                        backgroundColor:
                                                                            Colors
                                                                                .secundariaTheOffer,
                                                                        content:
                                                                            Container(
                                                                          color:
                                                                              Colors.secundariaTheOffer,
                                                                          child:
                                                                              Table(
                                                                            defaultColumnWidth:
                                                                                FixedColumnWidth(50.0),
                                                                            border:
                                                                                TableBorder(
                                                                              verticalInside: BorderSide(
                                                                                color: Colors.principalTheOffer,
                                                                                style: BorderStyle.solid,
                                                                                width: 1.0,
                                                                              ),
                                                                            ),
                                                                            children: [
                                                                              gerarLinha('Segunda-Feira', getHora(empresaDetalhada.segundaInicio) + ' às ' + getHora(empresaDetalhada.segundaFim)),
                                                                              gerarLinha('Terça-Feira', getHora(empresaDetalhada.tercaInicio) + ' às ' + getHora(empresaDetalhada.tercaFim)),
                                                                              gerarLinha('Quarta-Feira', getHora(empresaDetalhada.quartaInicio) + ' às ' + getHora(empresaDetalhada.quartaFim)),
                                                                              gerarLinha('Quinta-Feira', getHora(empresaDetalhada.quintaInicio) + ' às ' + getHora(empresaDetalhada.quintaFim)),
                                                                              gerarLinha('Sexta-Feira', getHora(empresaDetalhada.sextaInicio) + ' às ' + getHora(empresaDetalhada.sextaFim)),
                                                                              gerarLinha('Sábado', getHora(empresaDetalhada.sabadoInicio) + ' às ' + getHora(empresaDetalhada.sabadoFim)),
                                                                              gerarLinha('Domingo', getHora(empresaDetalhada.domingoInicio) + ' às ' + getHora(empresaDetalhada.domingoFim)),
                                                                            ],
                                                                          ),
                                                                        ));
                                                                  });
                                                            },
                                                            title: Text(
                                                              getHora(getHoraInicioEmpresaHoje(
                                                                      empresaDetalhada)) +
                                                                  ' às ' +
                                                                  getHora(getHoraFimEmpresaHoje(
                                                                      empresaDetalhada)) +
                                                                  ', ' +
                                                                  getDiaSemana(),
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .secundariaTheOffer),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  )),
                                                ],
                                              ))),
                                    ]);
                              } else {
                                return cardProdutosCategoria(
                                    index,
                                    empresaDetalhada.listaCategoria,
                                    _deviceSize,
                                    context);
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
    _empresasLoading = true;

    objetoItemPedido = {
      "categoria": widget.idCategoria.toString(),
      "empresa": widget.idEmpresa.toString(),
      "cidade": CidadeSelecionada.id.toString()
    };
    http
        .post(Configuracoes.BASE_URL + 'produtos/localizarPorEmpresa',
            headers: headers, body: objetoItemPedido)
        .then((response) {
      responseBody = json.decode(response.body);
      responseBody['empresas'].forEach((empresaJson) {
        if (empresaJson['categorias'] != null) {
          _listaCategoriaDetalhada = [];

          _listaCategoriaDetalhada.add(CategoriaDetalhada(
              id: 0, nome: '', imagem: '', listaProduto: null));

          empresaJson['categorias'].forEach((categoriasJson) {
            _listaProduto = [];
            if (categoriasJson['produtos'] != null) {
              categoriasJson['produtos'].forEach((produtosJson) {
                setState(() {
                  _listaProduto.add(Produto(
                      empresa: int.parse(produtosJson['empresa_id']),
                      id: int.parse(produtosJson['id']),
                      titulo: produtosJson['titulo'],
                      descricao: produtosJson['descricao'],
                      imagem: produtosJson['imagem'],
                      valor: produtosJson['valor'],
                      valorNumerico:
                          double.parse(produtosJson['valorNumerico']),
                      quantidade: int.parse(produtosJson['quantidade']),
                      quantidadeRestante:
                          int.parse(produtosJson['quantidadeRestante']),
                      dataInicial: produtosJson['dataInicial'],
                      dataFinal: produtosJson['dataFinal'],
                      dataCadastro: produtosJson['dataCadastro'],
                      empresaSegundaInicio:
                          double.parse(empresaJson['segundaInicio']),
                      empresaSegundaFim:
                          double.parse(empresaJson['segundaFim']),
                      empresaTercaInicio:
                          double.parse(empresaJson['tercaInicio']),
                      empresaTercaFim: double.parse(empresaJson['tercaFim']),
                      empresaQuartaInicio:
                          double.parse(empresaJson['quartaInicio']),
                      empresaQuartaFim: double.parse(empresaJson['quartaFim']),
                      empresaQuintaInicio:
                          double.parse(empresaJson['quintaInicio']),
                      empresaQuintaFim: double.parse(empresaJson['quintaFim']),
                      empresaSextaInicio:
                          double.parse(empresaJson['sextaInicio']),
                      empresaSextaFim: double.parse(empresaJson['sextaFim']),
                      empresaSabadoInicio:
                          double.parse(empresaJson['sabadoInicio']),
                      empresaSabadoFim: double.parse(empresaJson['sabadoFim']),
                      empresaDomingoInicio:
                          double.parse(empresaJson['domingoInicio']),
                      empresaDomingoFim:
                          double.parse(empresaJson['domingoFim']),
                      categoria: int.parse(produtosJson['categoria_id']),
                      possuiSabores:
                          int.parse(produtosJson['possuiSabores']) > 0,
                      usuarioId: int.parse(produtosJson['usuario_id'])));
                });
              });
              setState(() {
                _listaCategoriaDetalhada.add(CategoriaDetalhada(
                    id: int.parse(categoriasJson['id']),
                    nome: categoriasJson['nome'],
                    imagem: categoriasJson['imagem'],
                    listaProduto: _listaProduto));
              });
            }
          });
        }
        empresaDetalhada = EmpresaDetalhada(
            id: int.parse(empresaJson['id']),
            imagem: empresaJson['imagem'],
            razaoSocial: empresaJson['razaosocial'],
            fantasia: empresaJson['fantasia'],
            telefone: num.parse(empresaJson['telefone']),
            segundaInicio: double.parse(empresaJson['segundaInicio']),
            segundaFim: double.parse(empresaJson['segundaFim']),
            tercaInicio: double.parse(empresaJson['tercaInicio']),
            tercaFim: double.parse(empresaJson['tercaFim']),
            quartaInicio: double.parse(empresaJson['quartaInicio']),
            quartaFim: double.parse(empresaJson['quartaFim']),
            quintaInicio: double.parse(empresaJson['quintaInicio']),
            quintaFim: double.parse(empresaJson['quintaFim']),
            sextaInicio: double.parse(empresaJson['sextaInicio']),
            sextaFim: double.parse(empresaJson['sextaFim']),
            sabadoInicio: double.parse(empresaJson['sabadoInicio']),
            sabadoFim: double.parse(empresaJson['sabadoFim']),
            domingoInicio: double.parse(empresaJson['domingoInicio']),
            domingoFim: double.parse(empresaJson['domingoFim']),
            listaCategoria: _listaCategoriaDetalhada);
      });
      setState(() {
        _empresasLoading = false;
      });
    });
  }
}
