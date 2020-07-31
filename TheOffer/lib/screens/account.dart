/*import 'package:flutter/material.dart';
import 'package:theoffer/scoped-models/main.dart';
import 'package:theoffer/utils/constants.dart';
import 'package:theoffer/utils/drawer_homescreen.dart';
import 'package:theoffer/screens/retun_policy.dart';

import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class Account extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AccountState();
  }
}

class _AccountState extends State<Account> {
  var formatter = new DateFormat('MMM dd, yyyy');
  String createdAtString = '';
  TextStyle _textStyle = TextStyle(fontWeight: FontWeight.w500);
  @override
  void initState() {
    super.initState();
    getDate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Minha conta"),
      ),
      body: Container(
        child: accountOptions(),
      ),
      drawer: HomeDrawer(),
    );
  }

  getDate() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String createdAt = prefs.getString('createdAt');
    setState(() {
      createdAtString = formatter.format(DateTime.parse(createdAt));
    });
  }

  Widget accountOptions() {
    return ScopedModelDescendant(
        builder: (BuildContext context, Widget child, MainModel model) {
      return ListView(
        children: <Widget>[
          Container(
            color: Colors.grey.shade100,
            child: ListTile(
              title: Text(
                "Cliente desde $createdAtString",
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
              onTap: () {},
            ),
          ),
          ListTile(
            title: Text(
              "Histórico de pedidos",
              style: _textStyle,
            ),
            onTap: () {
            },
          ),
          ListTile(
            title: Text(
              "Endereços",
              style: _textStyle,
            ),
            onTap: () {
            },
          ),
          ListTile(
            title: Text(
              "Mudar email",
              style: _textStyle,
            ),
            onTap: () {
            },
          ),
          ListTile(
            title: Text(
              "Mudar senha",
              style: _textStyle,
            ),
            onTap: () {
            },
          ),
          Container(
            color: Colors.grey.shade100,
            child: ListTile(
              title: Text(
                "Ajuda e informações",
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
              onTap: () {},
            ),
          ),
          InkWell(
            onTap: () {
              _callMe('+55 (49) 9 9903-1587');
            },
            child: ListTile(
              title: Text(
                '+55 (49) 9 9903-1587',
              ),
            ),
          ),
          InkWell(
            onTap: () {
              _sendMail('suporte@theoffer.com');
            },
            child: ListTile(
              title: Text(
                'suporte@theoffer.com',
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
              title: Text(
                'Política de reembolso',
              ),
            ),
          ),
          logOutButton(),
        ],
      );
    });
  }

  Widget logOutButton() {
    return ScopedModelDescendant(
      builder: (BuildContext context, Widget child, MainModel model) {
        if (Autenticacao.codigoUsuario > 0) {
          return ListTile(
            title: Text(
              'Sair',
              style: TextStyle(
                color: Colors.red,
              ),
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

  void _showDialog(context, model) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Sair"),
            content: new Text("Você deseja realmente sair da conta?"),
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
                 // logoutUser(context, model);
                },
              )
            ],
          );
        });
  }

  _sendMail(String email) async {
    // Android and iOS
    final uri = 'mailto:$email?subject=&body=';
    if (await canLaunch(uri)) {
      await launch(uri);
    } else {
      throw 'Não foi possível acessar $uri';
    }
  }

  _callMe(String phone) async {
    final uri = 'tel:$phone';
    if (await canLaunch(uri)) {
      await launch(uri);
    } else {
      throw 'Não foi possível acessar $uri';
    }
  }
}
*/