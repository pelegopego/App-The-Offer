import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:theoffer/scoped-models/main.dart';
import 'package:theoffer/screens/cidades.dart';
import 'package:theoffer/utils/locator.dart';
import 'package:theoffer/utils/constants.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:theoffer/utils/headers.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';


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
  Future<void> initPlatformState() async {
    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

    OneSignal.shared.setRequiresUserPrivacyConsent(true);

    var settings = {
      OSiOSSettings.autoPrompt: false,
      OSiOSSettings.promptBeforeOpeningPushUrl: true
    };

    // TheOffer
    await OneSignal.shared
        .init("060cfdde-6123-4086-b569-9d03093a5e08", iOSSettings: settings);

    OneSignal.shared
        .setInFocusDisplayType(OSNotificationDisplayType.notification);

    await OneSignal.shared.requiresUserPrivacyConsent();
    OneSignal().setSubscription(true);
    var status = await OneSignal.shared.getPermissionSubscriptionState();
    var playerId = status.subscriptionStatus.userId;
    notificacao = playerId;
  }

  getUser() async {
    Map<dynamic, dynamic> responseBody;
    final storage = FlutterSecureStorage();
    String codigoUsuarioAuxiliar;
    String nomeUsuarioAuxiliar;
    String token;

    Map<String, String> allValues = await storage.readAll();
    if (allValues.length > 0) {
      codigoUsuarioAuxiliar = allValues["codigoUsuario"];
      nomeUsuarioAuxiliar = allValues["nomeUsuario"];
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

      notificacao =
          'euA78Knk2CU:APA91bG_O4fYBWhDCnyApV3t5HoiR36keEout_DWQ1Dh-DMpxdi_95kdByKtsrNtt9AEvbjCmOOOJLtFq9h80GXTTQyu5n6c31Re_fl6z2EuUhlyXFxtOlxIMdePYARQRJr3moFDx59l';
      if ((notificacao != allValues["notificacao"]) && (notificacao != '')) {
        if (Autenticacao.codigoUsuario > 0) {
          salvarTokenNotificacao();
          storage.write(key: "notificacao", value: notificacao);
          Autenticacao.notificacao = notificacao;
        }
      } else {
        notificacao = allValues["notificacao"];
        Autenticacao.notificacao = notificacao;
      }
    }

    if (Autenticacao.token == "") {
      http.get(Configuracoes.BASE_URL + 'usuario/gerarToken').then((response) {
        responseBody = json.decode(response.body);
        setState(() {
          Autenticacao.token = responseBody['token'];
        });
      });
    }

    if (Autenticacao.token != "") {
      setState(() {
        _model.localizarCarrinho(null, Autenticacao.codigoUsuario);
      });
    }
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
