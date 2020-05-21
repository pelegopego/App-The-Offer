import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:theoffer/scoped-models/main.dart';
import 'package:theoffer/screens/account.dart';
import 'package:theoffer/screens/autenticacao.dart';
import 'package:theoffer/screens/favorites.dart';
import 'package:theoffer/screens/order_history.dart';
import 'package:theoffer/screens/retun_policy.dart';
import 'package:theoffer/screens/listagemEndereco.dart';
import 'package:theoffer/utils/constants.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'headers.dart';

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

  getFavoritesCount() async {/*
    favCount = 0;
    Map<String, String> headers = await getHeaders();
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
  Widget logOutButton() {
    return ScopedModelDescendant(
      builder: (BuildContext context, Widget child, MainModel model) {
        if (Autenticacao.CodigoUsuario > 0) {
          return ListTile(
            leading: Icon(
              Icons.call_made,
              color: Colors.grey,
            ),
            title: Text(
              'Sair',
              style: TextStyle(color: Colors.grey),
            ),
            onTap: () {
              // logoutUser(model);
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
                    Icon(Icons.brightness_1, size: 30.0, color: Colors.secundariaTheOffer),
                    Center(
                      child: Text(
                        '${favCount}',
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
          if (Autenticacao.CodigoUsuario > 0) {
            MaterialPageRoute orderList =
                MaterialPageRoute(builder: (context) => FavoritesScreen());
            Navigator.push(context, orderList);
          } else {
            MaterialPageRoute route =
                MaterialPageRoute(builder: (context) => Authentication(0));

            Navigator.push(context, route);
          }
        },
      );
    });
  }

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
          if (Autenticacao.CodigoUsuario > 0) {
            MaterialPageRoute account =
                MaterialPageRoute(builder: (context) => ListagemEndereco());
            Navigator.push(context, account);
          } else {
            MaterialPageRoute route =
                MaterialPageRoute(builder: (context) => Authentication(0));

            Navigator.push(context, route);
          }
        },
      );
    });
  }

  Widget accountListTile() {
    return ScopedModelDescendant(
        builder: (BuildContext context, Widget child, MainModel model) {
      return ListTile(
        leading: Icon(
          Icons.person,
          color: Colors.secundariaTheOffer,
        ),
        title: Text(
          'Minha conta',
          style: TextStyle(color: Colors.secundariaTheOffer),
        ),
        onTap: () {
          if (Autenticacao.CodigoUsuario > 0) {
            MaterialPageRoute account =
                MaterialPageRoute(builder: (context) => Account());
            Navigator.push(context, account);
          } else {
            MaterialPageRoute route =
                MaterialPageRoute(builder: (context) => Authentication(0));

            Navigator.push(context, route);
          }
        },
      );
    });
  }

  Widget orderHistoryLineTile() {
    return ScopedModelDescendant(
        builder: (BuildContext context, Widget child, MainModel model) {
      return ListTile(
        leading: Icon(
          Icons.receipt,
          color: Colors.secundariaTheOffer,
        ),
        title: Text(
          'Histórico de pedidos',
          style: TextStyle(color: Colors.secundariaTheOffer),
        ),
        onTap: () {
          if (Autenticacao.CodigoUsuario > 0) {
            MaterialPageRoute orderList =
                MaterialPageRoute(builder: (context) => OrderList());
            Navigator.push(context, orderList);
          } else {
            MaterialPageRoute route =
                MaterialPageRoute(builder: (context) => Authentication(0));

            Navigator.push(context, route);
          }
        },
      );
    });
  }

  Widget signInLineTile() {
    getUserName();
    return ScopedModelDescendant(
      builder: (BuildContext context, Widget child, MainModel model) {
        if (Autenticacao.CodigoUsuario > 0)  {
          return Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text('Oi, ${formatarNome()}!',
                    style: TextStyle(
                        color: Colors.principalTheOffer, fontWeight: FontWeight.w500))
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
                      color: Colors.principalTheOffer, fontWeight: FontWeight.w300),
                ),
                onTap: () {
                  MaterialPageRoute route = MaterialPageRoute(
                      builder: (context) => Authentication(0));

                  Navigator.push(context, route);
                },
              ),
              Text(' | ',
                  style: TextStyle(
                      color: Colors.principalTheOffer, fontWeight: FontWeight.w300)),
              GestureDetector(
                child: Text('Criar conta',
                    style: TextStyle(
                        color: Colors.principalTheOffer, fontWeight: FontWeight.w300)),
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
    if (Autenticacao.NomeUsuario != null) {
      return  Autenticacao.NomeUsuario[0].toUpperCase() + Autenticacao.NomeUsuario.substring(1).split('@')[0];
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
            title: Text("Sair"),
            content: new Text("Você deseja realmente sair?"),
            actions: <Widget>[
              new FlatButton(
                child: Text(
                  "Cancelar",
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: Text(
                  "OK",
                  style: TextStyle(color: Colors.black),
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
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String user_id = prefs.getInt('id').toString();
    String api_key = prefs.getString('spreeApiKey');
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'token-type': 'Bearer',
      'ng-api': 'true',
      'Auth-Token': api_key,
      'uid': user_id
    };/*
    http
        .get(Settings.SERVER_URL + 'logout.json', headers: headers)
        .then((response) {
      prefs.clear();
      model.clearData();
      model.loggedInUser();
      model.localizarCarrinho(null, Autenticacao.CodigoUsuario);
    });*/
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
              Text(
                'TheOffer',
                style: TextStyle(
                    fontFamily: 'HolyFat', fontSize: 65, color: Colors.principalTheOffer),
              ),
              Text(
                '1.0.0',
                style:
                    TextStyle(color: Colors.principalTheOffer, fontWeight: FontWeight.w300),
              ),
              signInLineTile()
            ]),
            decoration: BoxDecoration(color: Colors.secundariaTheOffer),
          ),
          ListTile(
            onTap: () {
              Navigator.popUntil(
                  context, ModalRoute.withName(Navigator.defaultRouteName));
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
          favoritesLineTile(),
          accountListTile(),
          meusEndereco(),
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
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return ReturnPolicy();
              }));
            },
            child: ListTile(
              leading: Icon(
                Icons.assignment,
                color: Colors.secundariaTheOffer,
              ),
              title: Text(
                'Return Policy',
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
