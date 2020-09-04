import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:theoffer/scoped-models/main.dart';
import 'package:theoffer/utils/connectivity_state.dart';
import 'package:theoffer/utils/constants.dart';
import 'package:theoffer/utils/locator.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:theoffer/utils/headers.dart';
import 'package:theoffer/models/Produto.dart';
import 'package:theoffer/models/ProdutoEmpresa.dart';
import 'package:theoffer/widgets/cardProdutos.dart';

class TelaPesquisaProduto extends StatefulWidget {
  final String descricao;
  TelaPesquisaProduto({this.descricao});
  @override
  State<StatefulWidget> createState() {
    return _TelaPesquisaProduto();
  }
}

class _TelaPesquisaProduto extends State<TelaPesquisaProduto> {
  String descricao = '';
  TextEditingController _controller = TextEditingController();
  // List<SearchProduct> searchProducts = [];
  List<ProdutoEmpresa> listaProdutoEmpresa = [];
  Produto produtoSelecionado = Produto();
  bool isSearched = false;
  bool possuiProdutos = false;
  Size _deviceSize;
  int produtosEncontrados = 0;
  bool hasMore = false;
  Map<dynamic, dynamic> responseBody;
  List<Produto> produtosPorMarca = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.descricao != null) {
      print("DESCRICAO ${widget.descricao}");
      setState(() {
        descricao = widget.descricao;
        isSearched = true;
        listaProdutoEmpresa = [];
      });
      pesquisarProduto();
    }
    locator<ConnectivityManager>().initConnectivity(context);
  }

  @override
  void dispose() {
    super.dispose();
    locator<ConnectivityManager>().dispose();
  }

  @override
  Widget build(BuildContext mainContext) {
    _deviceSize = MediaQuery.of(mainContext).size;
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
          appBar: AppBar(
            elevation: 1.0,
            backgroundColor: Colors.secundariaTheOffer,
            leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.principalTheOffer,
                ),
                onPressed: () {
                  Navigator.pop(context);
                }),
            title: Container(
              padding: EdgeInsets.only(left: 15),
              child: TextField(
                style: TextStyle(
                  color: Colors.principalTheOffer,
                ),
                controller: _controller,
                onChanged: (value) {
                  setState(() {
                    descricao = value;
                  });
                },
                onSubmitted: (value) {
                  isSearched = true;
                  listaProdutoEmpresa = [];
                  pesquisarProduto();
                },
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Produto...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 18,
                      color: Colors.principalTheOffer),
                  labelStyle: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 18,
                      color: Colors.principalTheOffer),
                ),
              ),
            ),
            actions: <Widget>[
              Visibility(
                visible: descricao != null && descricao.isNotEmpty,
                child: IconButton(
                  icon: const Icon(
                    Icons.clear,
                    color: Colors.principalTheOffer,
                  ),
                  onPressed: () {
                    setState(() {
                      _controller.clear();
                      descricao = '';
                      setState(() {
                        listaProdutoEmpresa.clear();
                      });
                    });
                  },
                ),
              ),
            ],
          ),
          body: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("images/fundoBranco.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: isSearched && !_isLoading
                        ? Theme(
                            data: ThemeData(
                                primarySwatch: Colors.secundariaTheOffer),
                            child: !_isLoading && !possuiProdutos
                                ? Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 50.0),
                                    child: Center(
                                      child: Text(
                                        'Não foram encontrados produtos.',
                                        style: TextStyle(fontSize: 20.0),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                            "images/fundoBranco.png"),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    child: ListView.builder(
                                        itemCount: listaProdutoEmpresa.length,
                                        itemBuilder: (mainContext, index) {
                                          if (listaProdutoEmpresa[index]
                                                  .listaProduto
                                                  .length >
                                              0) {
                                            return cardProdutosEmpresa(
                                                index,
                                                listaProdutoEmpresa,
                                                _deviceSize,
                                                context);
                                          } else if (_isLoading) {
                                            return Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 25.0),
                                              child: Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                backgroundColor:
                                                    Colors.principalTheOffer,
                                              )),
                                            );
                                          } else {
                                            return Container();
                                          }
                                        })),
                          )
                        : Container(),
                  ),
                  Visibility(
                      visible: listaProdutoEmpresa.length > 0,
                      child: Material(
                        elevation: 2.0,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          color: Colors.secundariaTheOffer,
                          height: 50.0,
                          child: Padding(
                            padding:
                                const EdgeInsets.only(top: 18.0, left: 16.0),
                            child: Text(
                              '$produtosEncontrados Produtos encontrados',
                              textAlign: TextAlign.left,
                              style: TextStyle(color: Colors.principalTheOffer),
                            ),
                          ),
                        ),
                      )),
                  Visibility(
                      visible: _isLoading,
                      child: Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.secundariaTheOffer,
                        ),
                      )),
                ],
              )));
    });
  }

  Future<List<ProdutoEmpresa>> pesquisarProduto() async {
    Map<dynamic, dynamic> objetoProduto = Map();
    Map<String, String> headers = getHeaders();
    Map<String, dynamic> responseBody = Map();
    List<Produto> _listaProduto = [];
    print('PESQUISANDO $descricao');
    setState(() {
      possuiProdutos = false;
      produtosEncontrados = 0;
      isSearched = false;
    });

    objetoProduto = {
      "cidade": CidadeSelecionada.id.toString(),
      "descricao": descricao
    };

    http.Response response = await http.post(
        Configuracoes.BASE_URL + 'produtos/pesquisar',
        headers: headers,
        body: objetoProduto);

    responseBody = json.decode(response.body);
    responseBody['empresas'].forEach((empresaJson) {
      setState(() {
        _listaProduto = [];
        if (empresaJson['produtos'] != null) {
          possuiProdutos = true;
          empresaJson['produtos'].forEach((produtoJson) {
            setState(() {
              produtosEncontrados++;
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
              listaProduto: _listaProduto),
        );
      });
    });
    setState(() {
      _isLoading = false;
      isSearched = true;
    });

    return listaProdutoEmpresa;
  }
}
