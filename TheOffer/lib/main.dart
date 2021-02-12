import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:theoffer/utils/headers.dart';
import 'package:theoffer/utils/locator.dart';
import 'package:theoffer/screens/cidades.dart';
import 'package:theoffer/utils/constants.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:theoffer/scoped-models/main.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
  String notificacao;

  @override
  void initState() {
    initPlatformState();
    getUser();
    if (Autenticacao.token != "") {
      super.initState();
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  void initPlatformState() {
    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
    var settings = {
      OSiOSSettings.autoPrompt: true,
      OSiOSSettings.inAppLaunchUrl: true
    };

    OneSignal.shared.setRequiresUserPrivacyConsent(true);

    OneSignal.shared
        .init("060cfdde-6123-4086-b569-9d03093a5e08", iOSSettings: settings);

    OneSignal.shared.consentGranted(true);
    OneSignal.shared
        .setInFocusDisplayType(OSNotificationDisplayType.notification);
    OneSignal.shared.requiresUserPrivacyConsent();
    OneSignal.shared
        .getPermissionSubscriptionState()
        .then((status) => notificacao = status.subscriptionStatus.userId);
  }

  getUser() async {
    Map<dynamic, dynamic> responseBody;
    final storage = FlutterSecureStorage();
    String codigoUsuarioAuxiliar;
    String nomeUsuarioAuxiliar;
    String token;

    //storage.write(key: "dataBloqueio", value: '2021-02-01');
    Map<String, String> allValues = await storage.readAll();
    if (allValues.length > 0) {
      codigoUsuarioAuxiliar = allValues["codigoUsuario"];
      nomeUsuarioAuxiliar = allValues["nomeUsuario"];

      if (allValues["dataBloqueio"] != null &&
          allValues["dataBloqueio"] != '' &&
          allValues["dataBloqueio"] != 'null') {
        Autenticacao.dataBloqueio = DateTime.parse(allValues["dataBloqueio"]);
        Autenticacao.dataBloqueioAbriuApp = Autenticacao.dataBloqueio;
      }
      token = allValues["token"];

      if (codigoUsuarioAuxiliar != null) {
        setState(() {
          Autenticacao.codigoUsuario = int.parse(codigoUsuarioAuxiliar);
        });
      }
      if (nomeUsuarioAuxiliar != null) {
        setState(() {
          Autenticacao.nomeUsuario = nomeUsuarioAuxiliar;
        });
      }
      if (token != null) {
        setState(() {
          Autenticacao.token = token;
        });
      }

      if ((notificacao != allValues["notificacao"]) && (notificacao != '')) {
        if (Autenticacao.codigoUsuario > 0) {
          salvarTokenNotificacao();
          storage.write(key: "notificacao", value: notificacao);
          Autenticacao.notificacao = notificacao;
        } else {
          Autenticacao.notificacao = notificacao;
        }
      } else {
        notificacao = allValues["notificacao"];
        Autenticacao.notificacao = notificacao;
      }
    }
    if (Autenticacao.notificacao == "") {
      Autenticacao.notificacao = notificacao;
    }

    if (Autenticacao.token == "") {
      http.get(Configuracoes.BASE_URL + 'usuario/gerarToken').then((response) {
        responseBody = json.decode(response.body);
        setState(() {
          Autenticacao.token = responseBody['token'];
        });
      });
    }
    if (Autenticacao.codigoUsuario > 0) {
      if (Autenticacao.dataBloqueio == null ||
          Autenticacao.dataBloqueio.isBefore(DateTime.now())) {
        Map<String, String> headers = getHeaders();
        Map<dynamic, dynamic> oMapSalvarNotificacao = {
          'usuario': Autenticacao.codigoUsuario.toString()
        };
        http
            .post(Configuracoes.BASE_URL + 'usuario/getBloqueio/',
                headers: headers, body: oMapSalvarNotificacao)
            .then((response) {
          setState(() {
            if (json.decode(response.body)[0]['dataBloqueio'] != null) {
              Autenticacao.dataBloqueio =
                  DateTime.parse(json.decode(response.body)[0]['dataBloqueio']);
            }

            if (Autenticacao.dataBloqueio == null ||
                Autenticacao.dataBloqueio.isBefore(DateTime.now())) {
              Autenticacao.bloqueado = false;
            } else {
              Autenticacao.bloqueado = true;
            }

            storage.write(
                key: "dataBloqueio",
                value: Autenticacao.dataBloqueio.toString());
          });
        });
      } else {
        Autenticacao.bloqueado = true;
      }
    } else {
      Autenticacao.bloqueado = false;
    }
    /*if (Autenticacao.token != "") {
      setState(() {
        _model.localizarCarrinho(null, Autenticacao.codigoUsuario);
      });
    }*/
  }

  salvarTokenNotificacao() {
    Map<String, String> headers = getHeaders();
    Map<dynamic, dynamic> oMapSalvarNotificacao = {
      'usuario': Autenticacao.codigoUsuario.toString(),
      'notificacao': notificacao
    };
    http.post(Configuracoes.BASE_URL + 'usuario/salvarTokenNotificacao/',
        headers: headers, body: oMapSalvarNotificacao);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.restoreSystemUIOverlays();

    return ScopedModel<MainModel>(
      model: _model,
      child: MaterialApp(
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('pt'),
        ],
        debugShowCheckedModeBanner: false,
        title: 'TheOffer',
        initialRoute: '/cidades',
        routes: {'/cidades': (context) => TelaCidade()},
        theme: ThemeData(
            fontFamily: fontFamily,
            primarySwatch: Colors.secundariaTheOffer,
            accentColor: Colors.principalTheOffer,
            unselectedWidgetColor: Colors.secundariaTheOffer),
        home: TelaCidade(),
      ),
    );
  }
}
