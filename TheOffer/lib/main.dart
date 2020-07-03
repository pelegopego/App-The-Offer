import 'package:flutter/material.dart';
import 'package:theoffer/scoped-models/main.dart';
import 'package:theoffer/screens/cidades.dart';
import 'package:theoffer/utils/locator.dart';
import 'package:theoffer/utils/constants.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  setupLocator();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  final MainModel _model = MainModel();
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
    _model.localizarCarrinho(null, Autenticacao.CodigoUsuario);
    
    Map<dynamic, dynamic> responseBody;
    //Adquire o token se não existe
    if (Autenticacao.Token == "") {
      http.get(Configuracoes.BASE_URL + 'usuario/gerarToken').then((response) {
        responseBody = json.decode(response.body);
        Autenticacao.Token = responseBody['token'];
      });
    }
    super.initState();
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
        ),
        home: TelaCidade(),
      ),
    );
  }
}
