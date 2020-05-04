import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:http/http.dart' as http;
import 'package:theoffer/scoped-models/main.dart';
import 'package:theoffer/screens/forget_password.dart';
import 'package:theoffer/utils/connectivity_state.dart';
import 'package:theoffer/utils/constants.dart';
import 'package:theoffer/utils/locator.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:theoffer/widgets/snackbar.dart';

class Authentication extends StatefulWidget {
  final int index;
  Authentication(this.index);
  @override
  State<StatefulWidget> createState() {
    return _AuthenticationState();
  }
}

class _AuthenticationState extends State<Authentication>
    with SingleTickerProviderStateMixin {
  final Map<String, dynamic> _formData = {'email': null, 'password': null};
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyForLogin = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final TextEditingController _passwordTextController = TextEditingController();
  final UnderlineInputBorder _underlineInputBorder = UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.secundariaTheOffer));

  bool _isLoader = false;
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(initialIndex: widget.index, vsync: this, length: 2);
    locator<ConnectivityManager>().initConnectivity(context);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    locator<ConnectivityManager>().dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      color: Colors.secundariaTheOffer,
      theme: ThemeData(
        primarySwatch: Colors.secundariaTheOffer,
        accentColor: Colors.terciariaTheOffer,
      ),
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.terciariaTheOffer,
          key: _scaffoldKey,
          appBar: AppBar(
            centerTitle: false,
            backgroundColor: Colors.secundariaTheOffer,
            leading: IconButton(
              icon: Icon(Icons.close, color: Colors.principalTheOffer),
              onPressed: () => Navigator.of(context).pop(),
            ),
            bottom: TabBar(
              indicatorWeight: 4.0,
              controller: _tabController,
              indicatorColor: Colors.principalTheOffer,
              tabs: [
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    "ENTRAR",
                    style: TextStyle(
                        fontSize: 13, color: Colors.principalTheOffer),
                  ),
                ),
                Text(
                  "CRIAR CONTA",
                  style:
                      TextStyle(fontSize: 13, color: Colors.principalTheOffer),
                )
              ],
            ),
            title: Text(
              'TheOffer',
              style: TextStyle(
                  fontFamily: 'HolyFat',
                  fontSize: 50,
                  color: Colors.principalTheOffer),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _renderLogin(targetWidth),
              _renderSignup(targetWidth),
            ],
          ),
        ),
      ),
    );
  }

  Widget _renderLogin(double targetWidth) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return SingleChildScrollView(
        child: Container(
          width: targetWidth,
          child: Form(
            key: _formKeyForLogin,
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 30.0,
                ),
                _buildEmailTextField(),
                SizedBox(
                  height: 45.0,
                ),
                _buildPasswordTextField(false),
                SizedBox(
                  height: 35.0,
                ),
                _isLoader
                    ? CircularProgressIndicator(
                        backgroundColor: Colors.secundariaTheOffer)
                    : Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.all(15),
                        child: FlatButton(
                          textColor: Colors.principalTheOffer,
                          color: Colors.secundariaTheOffer,
                          child: Text(
                            'ENTRAR',
                            style: TextStyle(fontSize: 12.0),
                          ),
                          onPressed: () => _realizarLogin(model),
                        )),
                SizedBox(
                  height: 20.0,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return ForgetPassword();
                    }));
                  },
                  child: Text(
                    'Esqueceu sua senha?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.secundariaTheOffer,
                        fontSize: 14.0),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _renderSignup(double targetWidth) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
        child: Container(
          width: targetWidth,
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 30.0,
                ),
                _buildNomeTextField(),
                SizedBox(
                  height: 30.0,
                ),
                _buildEmailTextField(),
                SizedBox(
                  height: 30.0,
                ),
                _buildPasswordTextField(true),
                SizedBox(
                  height: 30.0,
                ),
                _buildPasswordConfirmTextField(),
                SizedBox(
                  height: 30.0,
                ),
                _buildTelefoneTextField(),
                SizedBox(
                  height: 30.0,
                ),
                _isLoader
                    ? CircularProgressIndicator(
                        backgroundColor: Colors.secundariaTheOffer)
                    : Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.all(15),
                        child: FlatButton(
                          textColor: Colors.principalTheOffer,
                          color: Colors.secundariaTheOffer,
                          child: Text('CRIAR CONTA',
                              style: TextStyle(fontSize: 12.0)),
                          onPressed: () => _abrirCadastroUsuario(),
                        )),
                SizedBox(
                  height: 20.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNomeTextField() {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: TextFormField(
          style: TextStyle(
            color: Colors.secundariaTheOffer,
          ),
          decoration: InputDecoration(
              labelStyle: TextStyle(color: Colors.secundariaTheOffer),
              labelText: 'Nome',
              contentPadding: EdgeInsets.all(0.0),
              enabledBorder: _underlineInputBorder),
          keyboardType: TextInputType.text,
          onSaved: (String value) {
            _formData['nome'] = value;
          },
        ));
  }

  Widget _buildEmailTextField() {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: TextFormField(
          style: TextStyle(
            color: Colors.secundariaTheOffer,
          ),
          decoration: InputDecoration(
              labelStyle: TextStyle(color: Colors.secundariaTheOffer),
              labelText: 'Email',
              contentPadding: EdgeInsets.all(0.0),
              enabledBorder: _underlineInputBorder),
          keyboardType: TextInputType.emailAddress,
          validator: (String value) {
            if (value.isEmpty ||
                !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                    .hasMatch(value)) {
              return 'Informe um email válido';
            }
            return null;
          },
          onSaved: (String value) {
            _formData['email'] = value;
          },
        ));
  }

  Widget _buildPasswordTextField([bool isLimitCharacter = false]) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15.0),
      child: TextFormField(
        style: TextStyle(
          color: Colors.secundariaTheOffer,
        ),
        decoration: InputDecoration(
            labelText:
                isLimitCharacter ? 'Senha (Mínimo de 6 dígitos)' : 'Senha',
            labelStyle: TextStyle(color: Colors.secundariaTheOffer),
            contentPadding: EdgeInsets.all(0.0),
            enabledBorder: _underlineInputBorder),
        obscureText: true,
        controller: _passwordTextController,
        validator: (String value) {
          if (value.isEmpty || value.length < 6) {
            return 'A senha precisa possuir pelo menos 6 dígitos.';
          }
          return null;
        },
        onSaved: (String value) {
          _formData['senha'] = value;
        },
      ),
    );
  }

  Widget _buildPasswordConfirmTextField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: TextFormField(
        style: TextStyle(
          color: Colors.secundariaTheOffer,
        ),
        decoration: InputDecoration(
          labelStyle: TextStyle(color: Colors.secundariaTheOffer),
          labelText: 'Confirmar senha',
          enabledBorder: _underlineInputBorder,
          contentPadding: EdgeInsets.all(0.0),
        ),
        obscureText: true,
        validator: (String value) {
          if (_passwordTextController.text != value) {
            return 'As senhas estão diferentes.';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildTelefoneTextField() {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: TextFormField(
          style: TextStyle(
            color: Colors.secundariaTheOffer,
          ),
          decoration: InputDecoration(
              labelStyle: TextStyle(color: Colors.secundariaTheOffer),
              labelText: 'Telefone',
              contentPadding: EdgeInsets.all(0.0),
              enabledBorder: _underlineInputBorder),
          keyboardType: TextInputType.phone,
          /*validator: (String value) {
            if (value.isEmpty ||
                !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                    .hasMatch(value)) {
              return 'Informe um email válido';
            }
            return null;
          },*/
          onSaved: (String value) {
            _formData['telefone'] = value;
          },
        ));
  }

  void _realizarLogin(MainModel model) async {
    Map<dynamic, dynamic> responseBody;

    setState(() {
      _isLoader = true;
    });
    if (!_formKeyForLogin.currentState.validate()) {
      setState(() {
        _isLoader = false;
      });
      return;
    }

    _formKeyForLogin.currentState.save();

    Map<dynamic, dynamic> oMapLogin = {
      'usuario': _formData['email'],
      'senha': _formData['senha'],
    };

    http
        .post(Configuracoes.BASE_URL + 'usuario/logar/', body: oMapLogin)
        .then((response) {
      bool hasError = true;

      print("logou");
      print(json.decode(response.body).toString());
      responseBody = json.decode(response.body);

      String message = responseBody['message'];
      if (message.isEmpty) {
        message = "Entrou com sucesso.";
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text("Entrou com sucesso"),
          duration: Duration(seconds: 104),
        ));
        hasError = false;
        model.getAddress();
        model.localizarCarrinho(null, 1);
        model.loggedInUser();
        Navigator.of(context).pop();
      } else {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(message),
          duration: Duration(seconds: 1),
        ));
        setState(() {
          _isLoader = false;
        });
      }
      return responseBody['message'];
    });
  }

  void _abrirCadastroUsuario() async {
    setState(() {
      _isLoader = true;
    });
    if (!_formKey.currentState.validate()) {
      setState(() {
        _isLoader = false;
      });
      return;
    }
    _formKey.currentState.save();
    Map<dynamic, dynamic> responseBody;

    Map<dynamic, dynamic> oMapCadastrarLogin = {
      'nome': _formData['nome'],
      'usuario': _formData['email'],
      'senha': _formData['senha'],      
      'telefone': _formData['telefone'],
    };

    http
        .post(Configuracoes.BASE_URL + 'usuario/salvar/', body: oMapCadastrarLogin)
        .then((response) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      String message = 'Ocorreu algum erro.';
      bool hasError = true;

      message = responseData['message'];

      if (message.isEmpty) {
        print('success');
        message = 'Registrado com sucesso.';
        hasError = false;
      } else if (responseData.containsKey('errors')) {
        message = "Email " + responseData["errors"]["email"][0];
      }

      final Map<String, dynamic> successInformation = {
        'success': !hasError,
        'message': message
      };
      if (successInformation['success']) {
        Navigator.of(context).pop();
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return _alertDialog('Success!',
                  "Conta criada com sucesso! Entre para continuar.", context);
            });
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text('${successInformation['message']}'),
          duration: Duration(seconds: 1),
        ));
      } else {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text('${successInformation['message']}'),
          duration: Duration(seconds: 1),
        ));
      }
      setState(() {
        _isLoader = false;
      });
    });
  }

  Widget _alertDialog(String boxTitle, String message, BuildContext context) {
    return AlertDialog(
      title: Text(boxTitle),
      content: Text(message),
      actions: <Widget>[
        FlatButton(
          child: Text('Later',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.secundariaTheOffer.shade300)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        FlatButton(
          child: Text('Entrar',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.secundariaTheOffer.shade300)),
          onPressed: () {
            Navigator.pop(context);
            MaterialPageRoute route =
                MaterialPageRoute(builder: (context) => Authentication(0));
            Navigator.push(context, route);
          },
        )
      ],
    );
  }
}
