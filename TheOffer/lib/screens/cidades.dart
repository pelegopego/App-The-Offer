import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:theoffer/models/Produto.dart';
import 'package:theoffer/scoped-models/main.dart';
import 'package:theoffer/screens/auth.dart';
import 'package:theoffer/screens/categorias.dart';
import 'package:theoffer/utils/connectivity_state.dart';
import 'package:theoffer/utils/constants.dart';
import 'package:theoffer/utils/drawer_homescreen.dart';
import 'package:theoffer/utils/locator.dart';
import 'package:theoffer/utils/imageHelper.dart';
import 'package:theoffer/models/banners.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:theoffer/models/categoria.dart';

class TelaCidade extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TelaCidade();
  }
}

class _TelaCidade extends State<TelaCidade> {
  Size _deviceSize;
  List<DropdownMenuItem<String>> listDrop = [];

  criaDropDownButton() {
    return Container(      
      color: Colors.secundariaTheOffer,
      child: Column(
        children: <Widget>[
          Text("Selecione a cidade"),
          TextField(
            onSubmitted: (String userInput) {
              setState(() {
                debugPrint('chamei setState');
              });
            },
          ),
          DropdownButton<String>(
              items: listDrop,
              onChanged: (value) =>  Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TelaCategorias()),
              ),   
              
              ),          
        ],
      ),
    );
  }

  void carregarDropDown() {
    listDrop = [];
    listDrop.add(new DropdownMenuItem(
        child: new Text('São miguel do oeste'), value: 'São miguel do oeste'));
  }

  @override
  Widget build(BuildContext context) {
    carregarDropDown();
    _deviceSize = MediaQuery.of(context).size;

    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
        appBar: AppBar(
            title: Container(
                padding: EdgeInsets.all(10),
                child: Text(
                  'TheOffer',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontFamily: 'HolyFat',
                      fontSize: 50,
                      color: Colors.principalTheOffer),
                )),
            iconTheme: new IconThemeData(color: Colors.principalTheOffer)),
        drawer: HomeDrawer(),
        body: criaDropDownButton(),
      );
    });
  }
}
