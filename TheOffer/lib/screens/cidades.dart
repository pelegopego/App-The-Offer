import 'package:flutter/material.dart';
import 'package:theoffer/scoped-models/main.dart';
import 'package:theoffer/screens/categorias.dart';
import 'package:theoffer/utils/drawer_homescreen.dart';
import 'package:scoped_model/scoped_model.dart';

class TelaCidade extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TelaCidade();
  }
}

class _TelaCidade extends State<TelaCidade> {
  List<DropdownMenuItem<String>> listDrop = [];

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
            child: DropdownButton<String>(
              isExpanded: true,
              items: listDrop,
              style: 
              TextStyle(color: Colors.secundariaTheOffer),
              focusColor: Colors.principalTheOffer,
              onChanged: (value) =>  Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TelaCategorias()),
              ),   
              ),
              )     
              )     
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
