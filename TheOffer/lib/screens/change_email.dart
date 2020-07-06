import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:theoffer/scoped-models/main.dart';

class EmailEdit extends StatefulWidget {
  @override
  _EmailEditState createState() => _EmailEditState();
}

class _EmailEditState extends State<EmailEdit> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _textFieldController = TextEditingController();
  bool _fetchingEmail = true;
  bool _savingEmail = false;

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
          title: Text("Email"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.check),
              onPressed: () {
                saveEmail(context, model);
              },
            )
          ],
        ),
        body: ScopedModelDescendant(
            builder: (BuildContext context, Widget child, MainModel model) {
          if (_fetchingEmail) {
            return LinearProgressIndicator();
          } else {
            return Container(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: EdgeInsets.all(20),
                  children: <Widget>[
                    buildEmailField(),
                    SizedBox(
                      height: 50,
                    ),
                    submitButton()
                  ],
                ),
              ),
            );
          }
        }),
      );
    });
  }

  Widget buildEmailField() {
    return TextFormField(
      validator: (String value) {
        if (value.isEmpty ||
            !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                .hasMatch(value)) {
          return 'Informe um email válido';
        }
        return '';
      },
      controller: _textFieldController,
      decoration: InputDecoration(
        labelText: "Email",
      ),
      onSaved: (String value) {
        setState(() {
        });
      },
    );
  }

  Widget submitButton() {
    return ScopedModelDescendant(
        builder: (BuildContext context, Widget child, MainModel model) {
      return FlatButton(
          color: Colors.deepOrange,
          disabledColor: Colors.grey,
          // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Text(
            'SALVAR',
            style: TextStyle(color: Colors.principalTheOffer),
          ),
          onPressed: _savingEmail
              ? null
              : () async {
                  saveEmail(context, model);
                });
    });
  }

  saveEmail(context, model) async {
    setState(() {
      _savingEmail = true;
    });
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
  }

  logoutUser(BuildContext context, MainModel model) async {/*
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, String> headers = getHeaders();
    http
        .get(Settings.SERVER_URL + 'logout.json', headers: headers)
        .then((response) {
      prefs.clear();
      model.loggedInUser();
      model.localizarCarrinho(null, Autenticacao.CodigoUsuario);
    });
    Navigator.popUntil(
        context, ModalRoute.withName(Navigator.defaultRouteName));*/
  }
}
