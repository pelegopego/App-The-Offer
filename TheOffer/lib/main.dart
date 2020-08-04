import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:theoffer/scoped-models/main.dart';
import 'package:theoffer/screens/cidades.dart';
import 'package:theoffer/utils/locator.dart';
import 'package:theoffer/utils/constants.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  setupLocator();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.

  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  final MainModel _model = MainModel();

  @override
  void initState() {
    _model.localizarCarrinho(null, Autenticacao.codigoUsuario);
    getUser();
    Map<dynamic, dynamic> responseBody;
    if (Autenticacao.token == "") {
      http.get(Configuracoes.BASE_URL + 'usuario/gerarToken').then((response) {
        responseBody = json.decode(response.body);
        Autenticacao.token = responseBody['token'];
      });
    }
    super.initState();
  }

  getUser() async {
    final storage = FlutterSecureStorage();
    String codigoUsuarioAuxiliar;
    String nomeUsuarioAuxiliar;
    String token;

    Map<String, String> allValues = await storage.readAll();
    if (allValues.length > 0) 
    {
      codigoUsuarioAuxiliar     = await storage.read(key: "codigoUsuario");
      nomeUsuarioAuxiliar       = await storage.read(key: "nomeUsuario");
      token                     = await storage.read(key: "token");

      if (codigoUsuarioAuxiliar != null) {
        Autenticacao.codigoUsuario = int.parse(codigoUsuarioAuxiliar);
      }
      if (nomeUsuarioAuxiliar != null) {
        Autenticacao.nomeUsuario = nomeUsuarioAuxiliar;
      }
      if (token != null) {
        Autenticacao.token = token;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<MainModel>(
      model: _model,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'TheOffer',
        initialRoute: '/cidades',
        routes: {
          '/cidades' : (context) => TelaCidade()
        },
        theme: ThemeData(
          primarySwatch: Colors.secundariaTheOffer,
          accentColor: Colors.principalTheOffer,
          unselectedWidgetColor: Colors.principalTheOffer
        ),
        home: TelaCidade(),
      ),
    );
  }
}
