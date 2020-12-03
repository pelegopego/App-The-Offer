import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:theoffer/scoped-models/main.dart';
import 'package:theoffer/screens/autenticacao.dart';
import 'package:theoffer/screens/cidades.dart';
//import 'package:theoffer/screens/listagemEndereco.dart';
//import 'package:theoffer/screens/listagemPedidos.dart';
import 'package:theoffer/screens/listagemCupom.dart';
import 'package:theoffer/screens/produtos.dart';
import 'package:theoffer/screens/categorias.dart';
import 'package:theoffer/utils/constants.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:theoffer/utils/headers.dart';

class HomeDrawer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeDrawer();
  }
}

class _HomeDrawer extends State<HomeDrawer> {
  int favCount = 0;
  @override
  void initState() {
    super.initState();
    getFavoritesCount();
  }

  getFavoritesCount() async {
    /*
    favCount = 0;
    Map<String, String> headers = getHeaders();
    Map<String, dynamic> responseBody = Map();
    http
        .get(
            Settings.SERVER_URL +
                'spree/user_favorite_products.json?&data_set=small',
            headers: headers)
        .then((response) {
      responseBody = json.decode(response.body);
      responseBody['data'].forEach((favoriteObj) {
        setState(() {
          favCount++;
        });
      });
    });*/
  }

  String userName = '';
  String observacao = '';
  Map<dynamic, dynamic> objetoSugestao = Map();
  Widget logOutButton() {
    return ScopedModelDescendant(
      builder: (BuildContext context, Widget child, MainModel model) {
        if (Autenticacao.codigoUsuario > 0) {
          return ListTile(
            leading: Icon(
              Icons.call_made,
              color: Colors.secundariaTheOffer,
            ),
            title: Text(
              'Sair',
              style: TextStyle(color: Colors.secundariaTheOffer),
            ),
            onTap: () {
              _showDialog(context, model);
            },
          );
        } else {
          return Container();
        }
      },
    );
  }

  Widget favoritesLineTile() {
    return ScopedModelDescendant(
        builder: (BuildContext context, Widget child, MainModel model) {
      return ListTile(
        leading: Icon(
          Icons.favorite,
          color: Colors.secundariaTheOffer,
        ),
        trailing: Container(
          width: 30.0,
          height: 30.0,
          child: favCount != null && favCount > 0
              ? Stack(
                  children: <Widget>[
                    Icon(Icons.brightness_1,
                        size: 30.0, color: Colors.secundariaTheOffer),
                    Center(
                      child: Text(
                        '$favCount',
                        style: TextStyle(
                          color: Colors.principalTheOffer,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                )
              : Container(
                  width: 30.0,
                  height: 30.0,
                ),
        ),
        title: Text(
          'Favoritos',
          style: TextStyle(color: Colors.secundariaTheOffer),
        ),
        onTap: () {
          /*
          if (Autenticacao.codigoUsuario > 0) {
            MaterialPageRoute orderList =
                MaterialPageRoute(builder: (context) => FavoritesScreen());
            Navigator.push(context, orderList);
          } else {
            MaterialPageRoute route =
                MaterialPageRoute(builder: (context) => Authentication(0));

            Navigator.push(context, route);
          }*/
        },
      );
    });
  }
/*
  Widget meusEndereco() {
    return ScopedModelDescendant(
        builder: (BuildContext context, Widget child, MainModel model) {
      return ListTile(
        leading: Icon(
          Icons.map,
          color: Colors.secundariaTheOffer,
        ),
        title: Text(
          'Meus endereços',
          style: TextStyle(color: Colors.secundariaTheOffer),
        ),
        onTap: () {
          if (Autenticacao.codigoUsuario > 0) {
            MaterialPageRoute listagemEndereco =
                MaterialPageRoute(builder: (context) => ListagemEndereco());
            Navigator.push(context, listagemEndereco);
          } else {
            MaterialPageRoute route =
                MaterialPageRoute(builder: (context) => Authentication(0));

            Navigator.push(context, route);
          }
        },
      );
    });
  }*/

  Widget sugestao() {
    return ScopedModelDescendant(
        builder: (BuildContext context, Widget child, MainModel model) {
      return ListTile(
        leading: Icon(
          Icons.add_comment,
          color: Colors.secundariaTheOffer,
        ),
        title: Text(
          'Sugerir melhoria / Relatar um problema',
          style: TextStyle(color: Colors.secundariaTheOffer),
        ),
        onTap: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                    scrollable: true,
                    contentPadding: EdgeInsets.all(0),
                    backgroundColor: Colors.transparent,
                    content: Container(
                        width: 260,
                        height: 220,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                alignment: Alignment.center,
                                child: Text(
                                  'Sugerir / Relatar problema',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: 18,
                                      color: Colors.principalTheOffer),
                                ),
                              ),
                              Container(
                                color: Colors.secundariaTheOffer,
                                margin: EdgeInsets.only(
                                    top: 10, right: 29, left: 29),
                                width: 250,
                                height: 140,
                                child: TextFormField(
                                  style: TextStyle(
                                    color: Colors.principalTheOffer,
                                  ),
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 6,
                                  textInputAction: TextInputAction.done,
                                  onChanged: (String value) {
                                    observacao = value;
                                  },
                                ),
                              ),
                              Container(
                                  alignment: Alignment.center,
                                  child: FlatButton(
                                    color: Colors.secundariaTheOffer,
                                    child: Text('Enviar',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.principalTheOffer)),
                                    onPressed: () {
                                      Map<String, String> headers =
                                          getHeaders();
                                      objetoSugestao = {
                                        "descricao": observacao,
                                        "usuario": Autenticacao.codigoUsuario
                                            .toString()
                                      };
                                      http
                                          .post(
                                              Configuracoes.BASE_URL +
                                                  'sugestao/salvar/',
                                              headers: headers,
                                              body: objetoSugestao)
                                          .then((response) {
                                        print("Sugerindo _______");
                                        print(json
                                            .decode(response.body)
                                            .toString());
                                      });
                                      Navigator.pop(context);
                                    },
                                  )),
                            ])));
              });
        },
      );
    });
  }
/*
  Widget meusPedidos() {
    return ScopedModelDescendant(
        builder: (BuildContext context, Widget child, MainModel model) {
      return ListTile(
        leading: Icon(
          Icons.library_books,
          color: Colors.secundariaTheOffer,
        ),
        title: Text(
          'Meus pedidos',
          style: TextStyle(color: Colors.secundariaTheOffer),
        ),
        onTap: () {
          if (Autenticacao.codigoUsuario > 0) {
            MaterialPageRoute listagemPedidos =
                MaterialPageRoute(builder: (context) => ListagemPedidos());
            Navigator.push(context, listagemPedidos);
          } else {
            MaterialPageRoute route =
                MaterialPageRoute(builder: (context) => Authentication(0));

            Navigator.push(context, route);
          }
        },
      );
    });
  }*/

  Widget meusCupons() {
    return ScopedModelDescendant(
        builder: (BuildContext context, Widget child, MainModel model) {
      return ListTile(
        leading: Icon(
          Icons.library_books,
          color: Colors.secundariaTheOffer,
        ),
        title: Text(
          'Meus cupons',
          style: TextStyle(color: Colors.secundariaTheOffer),
        ),
        onTap: () {
          if (Autenticacao.codigoUsuario > 0) {
            MaterialPageRoute listagemPedidos =
                MaterialPageRoute(builder: (context) => ListagemCupom());
            Navigator.push(context, listagemPedidos);
          } else {
            MaterialPageRoute route =
                MaterialPageRoute(builder: (context) => Authentication(0));

            Navigator.push(context, route);
          }
        },
      );
    });
  }

  writeStorageCidade() async {
    final storage = new FlutterSecureStorage();
    CidadeSelecionada.id = 0;
    await storage.delete(key: "CidadeSelecionada");
    MaterialPageRoute cidades =
        MaterialPageRoute(builder: (context) => TelaCidade());
    Navigator.push(context, cidades);
  }

  Widget trocarCategoria() {
    return ScopedModelDescendant(
        builder: (BuildContext context, Widget child, MainModel model) {
      return ListTile(
        leading: Icon(
          Icons.refresh,
          color: Colors.secundariaTheOffer,
        ),
        title: Text(
          'Trocar categoria',
          style: TextStyle(color: Colors.secundariaTheOffer),
        ),
        onTap: () {
          MaterialPageRoute route =
              MaterialPageRoute(builder: (context) => TelaCategorias());
          Navigator.of(context).push(route);
        },
      );
    });
  }

  Widget trocarCidade() {
    return ScopedModelDescendant(
        builder: (BuildContext context, Widget child, MainModel model) {
      return ListTile(
        leading: Icon(
          Icons.refresh,
          color: Colors.secundariaTheOffer,
        ),
        title: Text(
          'Trocar cidade',
          style: TextStyle(color: Colors.secundariaTheOffer),
        ),
        onTap: () {
          writeStorageCidade();
        },
      );
    });
  }

  Widget signInLineTile() {
    getUserName();
    return ScopedModelDescendant(
      builder: (BuildContext context, Widget child, MainModel model) {
        if (Autenticacao.codigoUsuario > 0) {
          return Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text('Oi, ${formatarNome()}!',
                    style: TextStyle(
                        color: Colors.principalTheOffer,
                        fontWeight: FontWeight.w500))
              ],
            ),
          );
        } else {
          return Expanded(
              child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              GestureDetector(
                child: Text(
                  'Entrar',
                  style: TextStyle(
                      color: Colors.principalTheOffer,
                      fontWeight: FontWeight.w300),
                ),
                onTap: () {
                  MaterialPageRoute route = MaterialPageRoute(
                      builder: (context) => Authentication(0));

                  Navigator.push(context, route);
                },
              ),
              Text(' | ',
                  style: TextStyle(
                      color: Colors.principalTheOffer,
                      fontWeight: FontWeight.w300)),
              GestureDetector(
                child: Text('Criar conta',
                    style: TextStyle(
                        color: Colors.principalTheOffer,
                        fontWeight: FontWeight.w300)),
                onTap: () {
                  MaterialPageRoute route = MaterialPageRoute(
                      builder: (context) => Authentication(1));

                  Navigator.push(context, route);
                },
              )
            ],
          ));
        }
      },
    );
  }

  formatarNome() {
    if (Autenticacao.nomeUsuario != null) {
      return Autenticacao.nomeUsuario[0].toUpperCase() +
          Autenticacao.nomeUsuario.substring(1).split('@')[0];
    }
  }

  getUserName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('email');
    });
  }

  void _showDialog(context, model) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Sair",
                style: TextStyle(
                    color: Colors.secundariaTheOffer,
                    fontWeight: FontWeight.bold)),
            content: new Text("Você deseja realmente sair?",
                style: TextStyle(color: Colors.secundariaTheOffer)),
            actions: <Widget>[
              new FlatButton(
                child: Text(
                  "Cancelar",
                  style: TextStyle(
                      color: Colors.secundariaTheOffer,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: Text(
                  "OK",
                  style: TextStyle(
                      color: Colors.secundariaTheOffer,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  logoutUser(model);
                },
              )
            ],
          );
        });
  }

  logoutUser(MainModel model) async {
    model.limparPedido();
    model.clearData();
    Autenticacao.codigoUsuario = 0;
    Autenticacao.nomeUsuario = '';
    final storage = FlutterSecureStorage();
    await storage.deleteAll();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.all(0.0),
        children: <Widget>[
          DrawerHeader(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Image.asset(
                'images/logos/appBar.png',
                fit: BoxFit.fill,
                height: 90,
              ),
              Text(
                '1.1.2',
                style: TextStyle(
                    color: Colors.principalTheOffer,
                    fontWeight: FontWeight.w300),
              ),
              signInLineTile()
            ]),
            decoration: BoxDecoration(color: Colors.secundariaTheOffer),
          ),
          ListTile(
            onTap: () {
              MaterialPageRoute produtosRoute = MaterialPageRoute(
                  builder: (context) => TelaProdutos(idCategoria: 0));
              Navigator.push(context, produtosRoute);
            },
            leading: Icon(
              Icons.home,
              color: Colors.secundariaTheOffer,
            ),
            title: Text(
              'Página inicial',
              style: TextStyle(color: Colors.secundariaTheOffer),
            ),
          ),
          trocarCidade(),
          trocarCategoria(),
          meusCupons(),
          //meusPedidos(),
          //meusEndereco(),
          sugestao(),
          Divider(color: Colors.secundariaTheOffer),
          ListTile(
            title: Text(
              'Ajuda',
              style: TextStyle(color: Colors.secundariaTheOffer),
            ),
          ),
          InkWell(
            onTap: () {
              _callMe('+55 (49) 9 9903-1587');
            },
            child: ListTile(
              leading: Icon(
                Icons.call,
                color: Colors.secundariaTheOffer,
              ),
              title: Text(
                '+55 (49) 9 9903-1587',
                style: TextStyle(color: Colors.secundariaTheOffer),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              _sendMail('supporte@theoffer.com.br');
            },
            child: ListTile(
              leading: Icon(
                Icons.mail,
                color: Colors.secundariaTheOffer,
              ),
              title: Text(
                'supporte@theoffer.com.br',
                style: TextStyle(color: Colors.secundariaTheOffer),
              ),
            ),
          ),
          Divider(color: Colors.secundariaTheOffer),
          logOutButton()
        ],
      ),
    );
  }
}

_sendMail(String email) async {
  // Android and iOS
  final uri = 'mailto:$email?subject=&body=';
  if (await canLaunch(uri)) {
    await launch(uri);
  } else {
    throw 'Não foi possível $uri';
  }
}

_callMe(String phone) async {
  final uri = 'tel:$phone';
  if (await canLaunch(uri)) {
    await launch(uri);
  } else {
    throw 'Não foi possível $uri';
  }
}
