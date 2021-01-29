import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:theoffer/scoped-models/main.dart';
import 'package:theoffer/utils/connectivity_state.dart';
import 'package:theoffer/utils/constants.dart';
import 'package:theoffer/utils/locator.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:crypto/crypto.dart';
import 'package:theoffer/utils/headers.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

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
  final Map<String, dynamic> _formData = {'email': null, 'senha': null};
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyForLogin = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final TextEditingController _passwordTextController = TextEditingController();
  final UnderlineInputBorder _underlineInputBorder = UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.secundariaTheOffer));

  var maskFormatter = new MaskTextInputFormatter(
      mask: '(##) # ####-####', filter: {"#": RegExp(r'[0-9]')});

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
    super.dispose();
    locator<ConnectivityManager>().dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('pt'),
      ],
      debugShowCheckedModeBanner: false,
      color: Colors.secundariaTheOffer,
      theme: ThemeData(
        fontFamily: fontFamily,
        primarySwatch: Colors.secundariaTheOffer,
        accentColor: Colors.white,
      ),
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
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
            title: Image.asset(
              'images/logos/appBar.png',
              fit: BoxFit.fill,
              height: 60,
            ),
          ),
          body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/fundoBranco.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: TabBarView(
              controller: _tabController,
              children: [
                _renderLogin(targetWidth),
                _renderSignup(targetWidth),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _renderLogin(double targetWidth) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
          child: Container(
            width: targetWidth,
            child: Form(
              key: _formKeyForLogin,
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 30.0,
                  ),
                  TextFormField(
                    style: TextStyle(
                      color: Colors.secundariaTheOffer,
                    ),
                    decoration: InputDecoration(
                        labelStyle: TextStyle(
                            color: Colors.secundariaTheOffer,
                            fontWeight: FontWeight.bold),
                        labelText: 'Email',
                        contentPadding: EdgeInsets.all(0.0),
                        enabledBorder: _underlineInputBorder),
                    keyboardType: TextInputType.text,
                    validator: (String value) {
                      if (value.isEmpty) {
                        return 'Informe um email válido.';
                      }
                      return null;
                    },
                    onSaved: (String value) {
                      _formData['email'] = value;
                    },
                  ),
                  SizedBox(
                    height: 45.0,
                  ),
                  TextFormField(
                    style: TextStyle(
                      color: Colors.secundariaTheOffer,
                    ),
                    decoration: InputDecoration(
                        labelText: 'Senha (Mínimo de 6 dígitos)',
                        labelStyle: TextStyle(
                            color: Colors.secundariaTheOffer,
                            fontWeight: FontWeight.bold),
                        contentPadding: EdgeInsets.all(0.0),
                        enabledBorder: _underlineInputBorder),
                    obscureText: true,
                    controller: _passwordTextController,
                    validator: (String value) {
                      if (value.isEmpty || value.length < 5) {
                        return 'A senha precisa possuir pelo menos 6 dígitos.';
                      }
                      return null;
                    },
                    onSaved: (String value) {
                      _formData['senha'] = value;
                    },
                  ),
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
                      esqueceuSenha();
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
        ),
      );
    });
  }

  esqueceuSenha() async {
    const url = 'http://sistema.theoffer.com.br/recuperarconta';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Não foi possível abrir a página, tente novamente mais tarde.';
    }
  }

  confirmarEmail(String token) async {
    String url = 'http://sistema.theoffer.com.br/confirmarEmail/' + token;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Não foi possível abrir a página, tente novamente mais tarde.';
    }
  }

  Widget _renderSignup(double targetWidth) {
    final format = DateFormat("dd/MM/yyyy");
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
                TextFormField(
                  style: TextStyle(
                    color: Colors.secundariaTheOffer,
                  ),
                  decoration: InputDecoration(
                      labelStyle: TextStyle(
                          color: Colors.secundariaTheOffer,
                          fontWeight: FontWeight.bold),
                      labelText: 'Nome completo',
                      enabledBorder: _underlineInputBorder),
                  keyboardType: TextInputType.text,
                  validator: (String value) {
                    if (value.isEmpty) {
                      return 'Informe o nome completo';
                    }
                    return null;
                  },
                  onSaved: (String value) {
                    _formData['nome'] = value;
                  },
                ),
                SizedBox(
                  height: 30.0,
                ),
                TextFormField(
                  style: TextStyle(
                    color: Colors.secundariaTheOffer,
                  ),
                  decoration: InputDecoration(
                      labelStyle: TextStyle(
                          color: Colors.secundariaTheOffer,
                          fontWeight: FontWeight.bold),
                      labelText: 'Email',
                      enabledBorder: _underlineInputBorder),
                  keyboardType: TextInputType.text,
                  validator: (String value) {
                    if (value.isEmpty) {
                      return 'Informe email válido';
                    }
                    return null;
                  },
                  onSaved: (String value) {
                    _formData['email'] = value;
                  },
                ),
                SizedBox(
                  height: 30.0,
                ),
                TextFormField(
                  style: TextStyle(
                    color: Colors.secundariaTheOffer,
                  ),
                  decoration: InputDecoration(
                      labelText: 'Senha (Mínimo de 6 dígitos)',
                      labelStyle: TextStyle(
                          color: Colors.secundariaTheOffer,
                          fontWeight: FontWeight.bold),
                      enabledBorder: _underlineInputBorder),
                  obscureText: true,
                  controller: _passwordTextController,
                  validator: (String value) {
                    if (value.isEmpty || value.length < 5) {
                      return 'A senha precisa possuir pelo menos 6 dígitos.';
                    }
                    return null;
                  },
                  onSaved: (String value) {
                    _formData['senha'] = value;
                  },
                ),
                SizedBox(
                  height: 30.0,
                ),
                TextFormField(
                  style: TextStyle(
                    color: Colors.secundariaTheOffer,
                  ),
                  decoration: InputDecoration(
                    labelStyle: TextStyle(
                        color: Colors.secundariaTheOffer,
                        fontWeight: FontWeight.bold),
                    labelText: 'Confirmar senha',
                    enabledBorder: _underlineInputBorder,
                  ),
                  obscureText: true,
                  validator: (String value) {
                    if (_passwordTextController.text != value) {
                      return 'As senhas estão diferentes.';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 30.0,
                ),
                TextFormField(
                  inputFormatters: [maskFormatter],
                  style: TextStyle(
                    color: Colors.secundariaTheOffer,
                  ),
                  decoration: InputDecoration(
                      labelStyle: TextStyle(
                          color: Colors.secundariaTheOffer,
                          fontWeight: FontWeight.bold),
                      labelText: 'Telefone',
                      enabledBorder: _underlineInputBorder),
                  keyboardType: TextInputType.phone,
                  validator: (String value) {
                    if (value.isEmpty) {
                      return 'Informe um telefone válido';
                    }
                    return null;
                  },
                  onSaved: (String value) {
                    _formData['telefone'] = maskFormatter.getUnmaskedText();
                  },
                ),
                SizedBox(
                  height: 30.0,
                ),
                DateTimeField(
                  style: TextStyle(
                    color: Colors.secundariaTheOffer,
                  ),
                  decoration: InputDecoration(
                      labelStyle: TextStyle(
                          color: Colors.secundariaTheOffer,
                          fontWeight: FontWeight.bold),
                      labelText: 'Nascimento',
                      enabledBorder: _underlineInputBorder),
                  format: format,
                  onShowPicker: (context, currentValue) {
                    return showDatePicker(
                        context: context,
                        firstDate: DateTime(1900),
                        initialDate: currentValue ?? DateTime.now(),
                        lastDate: DateTime(2100));
                  },
                  onSaved: (DateTime value) {
                    _formData['nascimento'] = value.toString();
                  },
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
                            onPressed: () => {
                                  if (_formKey.currentState.validate())
                                    {
                                      _abrirCadastroUsuario(),
                                      Navigator.of(context).pop(),
                                    }
                                })),
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

  void _realizarLogin(MainModel model) {
    Map<dynamic, dynamic> responseBody;
    Map<String, String> headers = getHeaders();

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
      'email': _formData['email'],
      'senha':
          md5.convert(utf8.encode('*/666%%' + _formData['senha'])).toString(),
    };

    bool hasError = true;
    http
        .post(Configuracoes.BASE_URL + 'usuario/logar/',
            headers: headers, body: oMapLogin)
        .then((response) {
      String message = 'Ocorreu algum erro.';

      responseBody = json.decode(response.body);
      message = responseBody['message'];
      if (message.isEmpty) {
        message = "Entrou com sucesso.";

        responseBody['usuario'].forEach((usuarioJson) {
          Autenticacao.codigoUsuario = int.parse(usuarioJson['id']);
          Autenticacao.nomeUsuario = usuarioJson['nome'];
          Autenticacao.token = usuarioJson['token'];
          if (Autenticacao.notificacao != usuarioJson['notificacao']) {
            Map<String, String> headers = getHeaders();
            Map<dynamic, dynamic> oMapSalvarNotificacao = {
              'usuario': Autenticacao.codigoUsuario.toString(),
              'notificacao': Autenticacao.notificacao
            };
            http.post(
                Configuracoes.BASE_URL + 'usuario/salvarTokenNotificacao/',
                headers: headers,
                body: oMapSalvarNotificacao);

            print('ATUALIZANDO TOKEN DE NOTIFICAÇÃO.');
          }
          writeStorage();
        });
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text("Entrou com sucesso"),
          duration: Duration(seconds: 104),
        ));
        hasError = false;
        //model.localizarCarrinho(null, Autenticacao.codigoUsuario);
      } else {
        setState(() {
          _isLoader = false;
        });
      }
      final Map<String, dynamic> successInformation = {
        'success': !hasError,
        'message': message
      };
      if (successInformation['success']) {
        Navigator.of(context).pop();
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
      return responseBody['message'];
    });
  }

  void _abrirCadastroUsuario() {
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
    Map<String, String> headers = getHeaders();

    Map<dynamic, dynamic> oMapCadastrarLogin = {
      'email': _formData['email'],
      'nome': _formData['nome'],
      'senha':
          md5.convert(utf8.encode('*/666%%' + _formData['senha'])).toString(),
      'telefone': _formData['telefone'],
      'nascimento': _formData['nascimento'],
      'notificacao':
          Autenticacao.notificacao != null ? Autenticacao.notificacao : ''
    };
    http
        .post(Configuracoes.BASE_URL + 'usuario/salvar/',
            headers: headers, body: oMapCadastrarLogin)
        .then((response) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['token'] != '' &&
          responseData['token'] != null &&
          responseData['status']) {
        confirmarEmail(responseData['token']);
      }
      setState(() {
        _isLoader = false;
      });
    });
  }

  writeStorage() async {
    final storage = FlutterSecureStorage();
    await storage.deleteAll();
    await storage.write(
        key: "codigoUsuario", value: Autenticacao.codigoUsuario.toString());
    await storage.write(key: "nomeUsuario", value: Autenticacao.nomeUsuario);
    await storage.write(key: "token", value: Autenticacao.token);
    await storage.write(key: "notificacao", value: Autenticacao.notificacao);
  }
}
