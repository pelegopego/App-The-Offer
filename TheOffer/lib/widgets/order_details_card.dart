import 'package:flutter/material.dart';
import 'package:theoffer/scoped-models/main.dart';
import 'package:scoped_model/scoped_model.dart';


Widget orderDetailCard() {
  return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
    return model.order == null
        ? Container()
        : Container(
            margin: EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
                amountRow('Mercadorias:', model.order.displaySubTotal, model,
                    Colors.grey.shade700),
                amountRow('Entrega:', model.order.shipTotal, model,
                    Colors.grey.shade700),
                amountRow('Taxas:', model.order.displayAdjustmentTotal, model,
                    Colors.grey.shade700),    
                amountRow(
                    'Total do pedido:', model.order.displayTotal, model, Colors.red)
              ],
            ),
          );
  });
}

Widget amountRow(
    String title, String displayAmount, MainModel model, Color textColor) {
  return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Container(
      padding: EdgeInsets.all(10),
      child: Text(
        title,
        style: TextStyle(fontSize: 17, color: Colors.grey.shade700),
      ),
    ),
    Container(
      padding: EdgeInsets.all(10),
      child: Text(
        displayAmount == null ? '' : displayAmount,
        style: TextStyle(
          fontSize: 17,
          color: textColor,
        ),
      ),
    )
  ]);
}
