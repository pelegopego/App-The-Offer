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
import 'package:theoffer/screens/produtos.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
//import 'package:firebase_auth/firebase_auth.dart';
//import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

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
  bool entrouFacebook = false;
  final UnderlineInputBorder _underlineInputBorder = UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.secundariaTheOffer));

  var maskFormatter = new MaskTextInputFormatter(
      mask: '(##) # ####-####', filter: {"#": RegExp(r'[0-9]')});

  bool _isLoader = false;
  TabController _tabController;

/*
  Future<String> signInWithGoogle() async {
    await Firebase.initializeApp();
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final UserCredential authResult =
        await _auth.signInWithCredential(credential);
    final User user = authResult.user;

    if (user != null) {
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final User currentUser = _auth.currentUser;
      assert(user.uid == currentUser.uid);

      print('signInWithGoogle succeeded: $user');

      return '$user';
    }

    return null;
  }

  Future<void> signOutGoogle() async {
    await Firebase.initializeApp();
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();

    print("User Signed Out");
  }
*/
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
      home: Scaffold(
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
                  style:
                      TextStyle(fontSize: 13, color: Colors.principalTheOffer),
                ),
              ),
              Text(
                "CRIAR CONTA",
                style: TextStyle(fontSize: 13, color: Colors.principalTheOffer),
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
          child: DefaultTabController(
            length: 2,
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
                      : Column(children: <Widget>[
                          Container(
                              width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.only(
                                  left: 15, right: 15, top: 5, bottom: 5),
                              child: FlatButton(
                                textColor: Colors.principalTheOffer,
                                color: Colors.secundariaTheOffer,
                                child: Text(
                                  'ENTRAR',
                                  style: TextStyle(fontSize: 12.0),
                                ),
                                onPressed: () => _realizarLogin(model),
                              )),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.only(
                                left: 15, right: 15, top: 5, bottom: 5),
                            child: SignInButton(
                              Buttons.FacebookNew,
                              text: 'Entrar com o Facebook',
                              onPressed: () => entrarFacebook(context, model),
                            ),
                          ),
                          /*
                          Container(
                              width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.all(15),
                              child: FlatButton(
                                textColor: Colors.principalTheOffer,
                                color: Colors.secundariaTheOffer,
                                child: Text(
                                  'ENTRAR COM Google',
                                  style: TextStyle(fontSize: 12.0),
                                ),
                                onPressed: () {
                                  signInWithGoogle().then((result) {
                                    if (result != null) {
                                      print(result);
                                    }
                                  });
                                },
                              ))*/
                        ]),
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
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
          child: Container(
            width: targetWidth,
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.only(left: 15, right: 15, bottom: 5),
                    child: SignInButton(
                      Buttons.FacebookNew,
                      text: 'Registrar com o Facebook',
                      onPressed: () => entrarFacebook(context, model),
                    ),
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
                                    _abrirCadastroUsuario(true),
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
    });
  }

  void _realizarLoginRedeSocial(MainModel model) {
    /* 
       0 - Normal
       1 - Rede Social
    */
    Map<dynamic, dynamic> responseBody;
    Map<String, String> headers = getHeaders();

    setState(() {
      _isLoader = true;
    });

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
      String message = '';
      int status = 0;

      responseBody = json.decode(response.body);
      message = responseBody['message'];
      status = responseBody['status'];
      if (status == 100) {
        responseBody['usuario'].forEach((usuarioJson) {
          Autenticacao.codigoUsuario = int.parse(usuarioJson['id']);
          Autenticacao.nomeUsuario = usuarioJson['nome'];
          Autenticacao.dataBloqueioAbriuApp = null;
          if (usuarioJson['dataBloqueio'] != null &&
              usuarioJson['dataBloqueio'] != '') {
            Autenticacao.dataBloqueio =
                DateTime.parse(usuarioJson['dataBloqueio']);
            Autenticacao.bloqueado =
                !Autenticacao.dataBloqueio.isBefore(DateTime.now());
          } else {
            Autenticacao.bloqueado = false;
          }

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
        hasError = false;
        //if (model != null) {
        //  model.localizarCarrinho(null, Autenticacao.codigoUsuario);
        //}
      } else {
        if (status == 400) {
          _abrirCadastroUsuario(false);
        } else if (status == 300) {
          message = 'Você já possui uma conta cadastrada com esse email.';
        }
        setState(() {
          _isLoader = false;
        });
      }
      if (status != 400) {
        final Map<String, dynamic> successInformation = {
          'success': !hasError,
          'message': message
        };
        if (successInformation['success']) {
          MaterialPageRoute produtosRoute = MaterialPageRoute(
              builder: (context) => TelaProdutos(idCategoria: 0));
          Navigator.push(context, produtosRoute);
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
      }
      return responseBody['message'];
    });
  }

  void _realizarLogin(MainModel model) {
    /* 
       0 - Normal
       1 - Rede Social
    */
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
      String message = '';
      int status = 0;

      responseBody = json.decode(response.body);
      message = responseBody['message'];
      status = responseBody['status'];
      if (status == 100) {
        responseBody['usuario'].forEach((usuarioJson) {
          Autenticacao.codigoUsuario = int.parse(usuarioJson['id']);
          Autenticacao.nomeUsuario = usuarioJson['nome'];
          Autenticacao.dataBloqueioAbriuApp = null;
          if (usuarioJson['dataBloqueio'] != null &&
              usuarioJson['dataBloqueio'] != '') {
            Autenticacao.dataBloqueio =
                DateTime.parse(usuarioJson['dataBloqueio']);
            Autenticacao.bloqueado =
                !Autenticacao.dataBloqueio.isBefore(DateTime.now());
          } else {
            Autenticacao.bloqueado = false;
          }

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
        hasError = false;
        //if (model != null) {
        //  model.localizarCarrinho(null, Autenticacao.codigoUsuario);
        //}
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

  void _abrirCadastroUsuario(bool solicitarConfirmacao) {
    setState(() {
      _isLoader = true;
    });
    if (solicitarConfirmacao && !_formKey.currentState.validate()) {
      setState(() {
        _isLoader = false;
      });
      return;
    }
    if (solicitarConfirmacao) {
      _formKey.currentState.save();
    }

    Map<String, String> headers = getHeaders();

    Map<dynamic, dynamic> oMapCadastrarLogin = {
      'email': _formData['email'],
      'nome': _formData['nome'],
      'senha':
          md5.convert(utf8.encode('*/666%%' + _formData['senha'])).toString(),
      'telefone': solicitarConfirmacao ? _formData['telefone'] : '0',
      'nascimento':
          _formData['nascimento'] != null ? _formData['nascimento'] : '',
      'solicitarConfirmacao': solicitarConfirmacao ? 'true' : 'false',
      'notificacao':
          Autenticacao.notificacao != null ? Autenticacao.notificacao : ''
    };
    http
        .post(Configuracoes.BASE_URL + 'usuario/salvar/',
            headers: headers, body: oMapCadastrarLogin)
        .then((response) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (solicitarConfirmacao) {
        if (responseData['token'] != '' &&
            responseData['token'] != null &&
            responseData['status']) {
          confirmarEmail(responseData['token']);
          Navigator.of(context).pop();
        }

        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text('${responseData['message']}'),
          duration: Duration(seconds: 1),
        ));
      } else {
        _realizarLoginRedeSocial(null);
      }
      setState(() {
        _isLoader = false;
      });
    });
  }

  void entrarFacebook(BuildContext aContext, model) async {
    void onLoginStatusChanged(MainModel model, bool isLoggedIn) {
      setState(() {
        entrouFacebook = isLoggedIn;
        if (entrouFacebook) {
          _realizarLoginRedeSocial(model);
        } else {
          model.limparPedido();
          model.clearData();
          Autenticacao.codigoUsuario = 0;
          Autenticacao.nomeUsuario = '';
          Autenticacao.dataBloqueio = null;
          Autenticacao.bloqueado = false;
          final storage = FlutterSecureStorage();
          storage.deleteAll();
        }
      });
    }

    final facebookLogin = FacebookLogin();
    final facebookLoginResult = await facebookLogin.logIn(['email']);
    switch (facebookLoginResult.status) {
      case FacebookLoginStatus.error:
        onLoginStatusChanged(model, false);
        break;
      case FacebookLoginStatus.cancelledByUser:
        onLoginStatusChanged(model, false);
        break;
      case FacebookLoginStatus.loggedIn:
        var graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=name,email&access_token=${facebookLoginResult.accessToken.token}');

        var profile = json.decode(graphResponse.body);
        _formData['email'] = profile['email'];
        _formData['senha'] = profile['id'];
        _formData['nome'] = profile['name'];
        onLoginStatusChanged(model, true);
        break;
    }
  }

  writeStorage() async {
    final storage = FlutterSecureStorage();
    await storage.deleteAll();
    await storage.write(
        key: "codigoUsuario", value: Autenticacao.codigoUsuario.toString());
    await storage.write(key: "nomeUsuario", value: Autenticacao.nomeUsuario);
    await storage.write(key: "token", value: Autenticacao.token);
    await storage.write(key: "notificacao", value: Autenticacao.notificacao);
    await storage.write(
        key: "dataBloqueio", value: Autenticacao.dataBloqueio.toString());
  }
}
