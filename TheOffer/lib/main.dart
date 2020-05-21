import 'package:flutter/material.dart';
import 'package:theoffer/scoped-models/main.dart';
import 'package:theoffer/screens/cidades.dart';
import 'package:theoffer/utils/locator.dart';
import 'package:theoffer/utils/constants.dart';
import 'package:scoped_model/scoped_model.dart';

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
