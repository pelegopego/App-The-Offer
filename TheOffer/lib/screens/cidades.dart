import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:theoffer/scoped-models/main.dart';
import 'package:theoffer/screens/categorias.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:theoffer/utils/headers.dart';
import 'package:http/http.dart' as http;
import 'package:theoffer/utils/constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class TelaCidade extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TelaCidade();
  }
}

class _TelaCidade extends State<TelaCidade> {
  List<DropdownMenuItem<int>> listaCidades = [];
  bool cidadesLoading;

  criaDropDownButton() {
    if (cidadesLoading) {
      return Container(
        color: Colors.secundariaTheOffer,
        child: Center(
          child: CircularProgressIndicator(
            backgroundColor: Colors.secundariaTheOffer,
          ),
        ),
      );
    } else {
      return Container(
        color: Colors.secundariaTheOffer,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Column(
          children: <Widget>[
            SizedBox(height: 280),
            Text(
              "Selecione a cidade",
              style: TextStyle(color: Colors.principalTheOffer),
            ),
            Container(
                decoration: BoxDecoration(
                    color: Colors.principalTheOffer,
                    borderRadius: BorderRadius.circular(5)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton(
                    isExpanded: true,
                    items: listaCidades,
                    style: TextStyle(color: Colors.secundariaTheOffer),
                    onChanged: (value) => mudouCidade(value),
                  ),
                ))
          ],
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    cidadesLoading = true;
    getCidadeStorage();
  }    

 getCidadeStorage() async {
    final storage = FlutterSecureStorage();
    String cidadeSelecionadaAuxiliar;
    cidadeSelecionadaAuxiliar = await storage.read(key: "CidadeSelecionada");
    if (cidadeSelecionadaAuxiliar != null) {
      CidadeSelecionada.id = int. parse(cidadeSelecionadaAuxiliar);
    }
 }

 mudarRota() async {
    await Future.delayed(Duration(seconds: 0), () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TelaCategorias()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (CidadeSelecionada.id > 0) {
      if (cidadesLoading) {
        mudarRota();
      }
      return Container(
        color: Colors.secundariaTheOffer,
      );
    } else {
      getCidades();
      return ScopedModelDescendant<MainModel>(
          builder: (BuildContext context, Widget child, MainModel model) {
        return Scaffold(
          body: criaDropDownButton(),
        );
      });
    }
  }

  mudouCidade(int idCidade) {
    CidadeSelecionada.id = idCidade;
    writeStorageCidade();
    Navigator.push(context, MaterialPageRoute(builder: (context) => TelaCategorias()));
  }
  
  writeStorageCidade() async {
    final storage = FlutterSecureStorage();
    await storage.write(key: "CidadeSelecionada", value: CidadeSelecionada.id.toString());
  }
                
  getCidades() {
  Map<dynamic, dynamic> responseBody;
    Map<String, String> headers = getHeaders();
    http.get(Configuracoes.BASE_URL + 'cidades/', headers: headers)
    .then((response) {
    setState(() {
      listaCidades = [];
    });
      if (headers['authorization'] != '') {
        responseBody = json.decode(response.body);
        responseBody['cidades'].forEach((categoriaJson) {
          setState(() { 
              listaCidades.add(new DropdownMenuItem(
                  child: new Text(categoriaJson['nome']), value: int.parse(categoriaJson['id'])));
          });
        });
        if (listaCidades.length > 0) {
          setState(() {
            cidadesLoading = false;
          });
        }
      }
    });
  }

}
