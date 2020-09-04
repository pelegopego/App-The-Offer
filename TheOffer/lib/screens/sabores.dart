import 'package:flutter/material.dart';
import 'package:theoffer/scoped-models/carrinho.dart';
import 'package:theoffer/scoped-models/main.dart';
import 'package:theoffer/screens/autenticacao.dart';
import 'package:theoffer/models/sabor.dart';
import 'package:theoffer/utils/connectivity_state.dart';
import 'package:theoffer/utils/locator.dart';
import 'package:theoffer/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:scoped_model/scoped_model.dart';
import 'package:theoffer/utils/headers.dart';
import 'dart:convert';

class TelaSabores extends StatefulWidget {
  final int produtoId;
  TelaSabores(this.produtoId);
  @override
  State<StatefulWidget> createState() {
    return _TelaSabores();
  }
}

class _TelaSabores extends State<TelaSabores> {
  final CarrinhoModel carrinho = MainModel();
  Map<dynamic, dynamic> responseBody;
  bool _isLoading = false;
  Sabor sabor;
  List<Sabor> listaSabores;

  int selectedPaymentId;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    getSabores(widget.produtoId);
    locator<ConnectivityManager>().initConnectivity(context);
  }

  @override
  void dispose() {
    super.dispose();
    locator<ConnectivityManager>().dispose();
  }

  int quantidadeSelecionados() {
    int saboresSelecionados = 0;
    for (var sabor in listaSabores) {
      if (sabor.selecionado) {
        saboresSelecionados = saboresSelecionados + 1;
      }
    }
    return saboresSelecionados;
  }

  String stringSabores() {
    String saboresSelecionados = '';
    for (var sabor in listaSabores) {
      if (sabor.selecionado) {
        if (saboresSelecionados != '') {
          saboresSelecionados = saboresSelecionados + ', ' + sabor.nome;
        } else {
          saboresSelecionados = sabor.nome;
        }
      }
    }
    return saboresSelecionados;
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return WillPopScope(
        onWillPop: _canGoBack,
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
              leading: IconButton(
                icon:
                    Icon(Icons.arrow_back_ios, color: Colors.principalTheOffer),
                onPressed: () {
                  model.removerProdutoCarrinho(model.pedido.id,
                      Autenticacao.codigoUsuario, widget.produtoId);
                  Navigator.of(context).pop();
                  //ajustar para remover quantidade se so add um
                },
              ),
              title: Text('Sabores',
                  style: TextStyle(color: Colors.principalTheOffer)),
              bottom: model.isLoading || _isLoading
                  ? PreferredSize(
                      child: LinearProgressIndicator(),
                      preferredSize: Size.fromHeight(10),
                    )
                  : PreferredSize(
                      child: Container(),
                      preferredSize: Size.fromHeight(10),
                    )),
          body: _isLoading
              ? Container()
              : Container(
                  height: 700,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("images/fundoBranco.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: listaSabores.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return CheckboxListTile(
                          title: Text(
                            listaSabores[index].nome,
                            style: TextStyle(
                                color: Colors.secundariaTheOffer,
                                fontWeight: FontWeight.bold),
                          ),
                          value: listaSabores[index].selecionado,
                          activeColor: Colors.secundariaTheOffer,
                          checkColor: Colors.principalTheOffer,
                          onChanged: (selecionado) {
                            setState(() {
                              if ((quantidadeSelecionados() == 3) &&
                                  (selecionado)) {
                                selecionado = false;
                                _scaffoldKey.currentState.showSnackBar(SnackBar(
                                  content:
                                      Text("Já foram escolhidos os 3 sabores."),
                                  duration: Duration(seconds: 2),
                                ));
                              } else {
                                listaSabores[index].selecionado = selecionado;
                              }
                            });
                          },
                        );
                      }),
                ),
          bottomNavigationBar: !_isLoading ? okButton(context) : Container(),
        ),
      );
    });
  }

  Future<bool> _canGoBack() {
    print("Voltar");
    return Future<bool>.value(true);
  }

  getSabores(int produtoId) async {
    Map<String, String> headers = getHeaders();
    setState(() {
      _isLoading = true;
      listaSabores = [];
    });
    http.Response response = await http
        .get(Configuracoes.BASE_URL + 'sabor/$produtoId', headers: headers);

    responseBody = json.decode(response.body);
    if (responseBody['possuiSabores'] == true) {
      responseBody['sabores'].forEach((saborJson) {
        sabor = Sabor(
            id: int.parse(saborJson['idSabor']),
            nome: saborJson['nomeSabor'],
            selecionado: false);

        listaSabores.add(sabor);
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  Widget okButton(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Container(
        padding: EdgeInsets.all(5),
        child: model.isLoading
            ? Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.secundariaTheOffer,
                ),
              )
            : FlatButton(
                color: Colors.principalTheOffer,
                child: Text(
                  'OK',
                  style:
                      TextStyle(fontSize: 20, color: Colors.secundariaTheOffer),
                ),
                onPressed: () async {
                  if (quantidadeSelecionados() == 0) {
                    _scaffoldKey.currentState.showSnackBar(SnackBar(
                      content: Text("Favor escolher ao menos um sabor."),
                      duration: Duration(seconds: 2),
                    ));
                  } else {
                    print("SALVANDO SABORES");
                    Map<dynamic, dynamic> objetoPedido = Map();
                    Map<String, String> headers = getHeaders();
                    if (Autenticacao.codigoUsuario > 0) {
                      objetoPedido = {
                        "sabores": stringSabores(),
                        "usuario": Autenticacao.codigoUsuario.toString(),
                        "produto": widget.produtoId.toString()
                      };
                      http
                          .post(
                              Configuracoes.BASE_URL +
                                  'pedido/selecionarSabores/',
                              headers: headers,
                              body: objetoPedido)
                          .then((response) {
                        print("Adicionando sabores ao pedido.");
                        print(json.decode(response.body).toString());
                        final snackBar = SnackBar(
                            content: Text('Sabores selecionados com sucesso.'),
                            duration: Duration(seconds: 2));
                        Scaffold.of(context).showSnackBar(snackBar);
                        Navigator.of(context).pop();
                      });
                    } else {
                      MaterialPageRoute authRoute = MaterialPageRoute(
                          builder: (context) => Authentication(0));
                      Navigator.push(context, authRoute);
                    }
                  }
                },
              ),
      );
    });
  }

  Widget linhaTotal(String title, String displayAmount) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Container(
        padding: EdgeInsets.all(5),
        child: Text(
          title,
          style: TextStyle(
              color: Colors.principalTheOffer, fontWeight: FontWeight.bold),
        ),
      ),
      Container(
        padding: EdgeInsets.all(5),
        child: Text(
          displayAmount == null ? '' : displayAmount,
          style: TextStyle(
              fontSize: 17,
              color: Colors.principalTheOffer,
              fontWeight: FontWeight.bold),
        ),
      )
    ]);
  }
}
