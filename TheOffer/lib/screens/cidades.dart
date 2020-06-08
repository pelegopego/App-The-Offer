import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:theoffer/scoped-models/main.dart';
import 'package:theoffer/screens/categorias.dart';
import 'package:theoffer/utils/drawer_homescreen.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:theoffer/models/cidade.dart';
import 'package:http/http.dart' as http;
import 'package:theoffer/utils/constants.dart';


class TelaCidade extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TelaCidade();
  }
}

class _TelaCidade extends State<TelaCidade> {
  List<DropdownMenuItem<int>> listaCidades = [];

  criaDropDownButton() {
    return Container(      
      color: Colors.secundariaTheOffer,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),  
      child: Column(
        children: <Widget>[
          SizedBox(height: 200),
          Text("Selecione a cidade",
          style: TextStyle(color: Colors.principalTheOffer),
          ),
           Container(   
             decoration: BoxDecoration(
             color: Colors.principalTheOffer,
             borderRadius: BorderRadius.circular(5)),   
             child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              isExpanded: true,
              items: listaCidades,
              style: 
              TextStyle(color: Colors.secundariaTheOffer),
              onChanged: (value) => mudouCidade(value),   
              ),
              )     
              )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    getCidades();
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
        appBar: AppBar(
            title: Image.asset(
                    'images/logos/appBar.png',
                    fit: BoxFit.fill,
                    height: 55,
            ),
            iconTheme: new IconThemeData(color: Colors.principalTheOffer)),
        drawer: HomeDrawer(),
        body: criaDropDownButton(),
      );
    });
  }

  mudouCidade(int idCidade) {
    CidadeSelecionada.id = idCidade;
    Navigator.push(context, MaterialPageRoute(builder: (context) => TelaCategorias()));
  }

                
  getCidades() async {
  Map<dynamic, dynamic> responseBody;
    http.get(Configuracoes.BASE_URL + 'cidades/').then((response) {
    setState(() {
      listaCidades = [];
    });
      responseBody = json.decode(response.body);
      responseBody['cidades'].forEach((categoriaJson) {
          setState(() { 
          listaCidades.add(new DropdownMenuItem(
              child: new Text(categoriaJson['nome']), value: int.parse(categoriaJson['id'])));
          });
        }
      );
    });
  }

}
