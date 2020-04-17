import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:ofypets_mobile_app/scoped-models/main.dart';
import 'package:ofypets_mobile_app/utils/constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChangePassword extends StatefulWidget {
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _newPassword = '';
  final TextEditingController _newPasswordTextFieldController =
      TextEditingController();
  final TextEditingController _confirmTextFieldController =
      TextEditingController();
  bool _savingNewPassword = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Senha"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.check),
              onPressed: () {
                setNewPassword(context, model);
              },
            )
          ],
        ),
        body: ScopedModelDescendant(
            builder: (BuildContext context, Widget child, MainModel model) {
          return Container(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.all(20),
                children: <Widget>[
                  buildNewPasswordField(),
                  buildConfirmPasswordField(),
                  SizedBox(height: 50,),
                  submitButton()
                ],
              ),
            ),
          );
        }),
      );
    });
  }

  Widget buildNewPasswordField() {
    return TextFormField(
      validator: (String value) {
        if (value.isEmpty) {
          return 'Insira uma senha';
        }
        if (value.length < 6) {
          return 'A senha deve possuir pelo menos 6 dígitos';
        }
      },
      obscureText: true,
      controller: _newPasswordTextFieldController,
      decoration: InputDecoration(
        labelText: "Nova senha",
      ),
      onSaved: (String value) {
        setState(() {
          _newPassword = value;
        });
      },
    );
  }

  Widget buildConfirmPasswordField() {
    return TextFormField(
      validator: (String value) {
        if (value.isEmpty) {
          return 'Confirme a nova senha';
        }
        if (_newPasswordTextFieldController.text !=
            _confirmTextFieldController.text) {
          return 'As senhas não conferem';
        }
      },
      obscureText: true,
      controller: _confirmTextFieldController,
      decoration: InputDecoration(
        labelText: "Confirmar senha",
      ),
    );
  }

  Widget submitButton() {
    return ScopedModelDescendant(
        builder: (BuildContext context, Widget child, MainModel model) {
      return FlatButton(
          color: Colors.deepOrange,
          disabledColor: Colors.grey,
          child: Text(
            'ATUALIZAR SENHA',
            style: TextStyle(color: Colors.white),
          ),
          onPressed: _savingNewPassword
              ? null
              : () async {
                  setNewPassword(context, model);
                });
    });
  }

  setNewPassword(context, model) async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    setState(() {
      _savingNewPassword = true;
    });
    Map<dynamic, dynamic> updateResponse;
    _formKey.currentState.save();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = prefs.getString('email');
    Map<String, String> headers = {'Content-Type': 'application/json'};
    Map<String, dynamic> payload = Map();

    payload = {
      'spree_user': {'email': email, 'password': _newPassword}
    };
    String url = Settings.SERVER_URL + "auth/change_password";

    http.Response response =
        await http.put(url, headers: headers, body: json.encode(payload));

    setState(() {
      _savingNewPassword = false;
    });
    if (response.statusCode == 200) {
      _showSuccessDialog(context);
      _newPasswordTextFieldController.text = '';
      _confirmTextFieldController.text = '';
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Erro ao alterar a senha"),
        duration: Duration(seconds: 1),
      ));
    }
  }

  void _showSuccessDialog(context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Password"),
            content: new Text("Senha alterada com sucesso."),
            actions: <Widget>[
              new FlatButton(
                child: Text(
                  "OK",
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }
}
