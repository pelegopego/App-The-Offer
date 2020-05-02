import 'package:flutter/material.dart';
import 'package:theoffer/scoped-models/main.dart';
import 'package:theoffer/screens/carrinho.dart';
import 'package:scoped_model/scoped_model.dart';

Widget shoppingCarrinhoIconButton() {
  return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
    return new Padding(
      padding:
          const EdgeInsets.only(top: 10.0, bottom: 10.0, right: 25, left: 10),
      child: new Container(
        height: 150.0,
        width: 30.0,
        child: new GestureDetector(
          onTap: () {
            MaterialPageRoute route =
                MaterialPageRoute(builder: (context) => Carrinho());

            Navigator.push(context, route);
          },
          child: new Stack(
            children: <Widget>[
              new IconButton(
                iconSize: 30,
                icon: new Icon(
                  Icons.shopping_basket,
                  color: Colors.principalTheOffer,
                ),
                onPressed: null,
              ),
              new Positioned(
                child: Container(
                  width: 21.0,
                  height: 21.0,
                  child: new Stack(
                    children: <Widget>[
                      new Icon(Icons.brightness_1,
                          size: 21.0, color: Colors.yellow),
                      new Center(
                        child: new Text(
                          model.pedido == null
                              ? '0'
                              : model.pedido.listaItensPedido.length.toString(),
                          style: new TextStyle(
                              color: Colors.black,
                              fontSize: 11.0,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  });
}
