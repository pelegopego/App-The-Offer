import 'package:flutter/material.dart';
import 'package:theoffer/scoped-models/main.dart';
import 'package:theoffer/screens/address.dart';
import 'package:theoffer/screens/auth.dart';
import 'package:theoffer/utils/connectivity_state.dart';
import 'package:theoffer/utils/locator.dart';
import 'package:scoped_model/scoped_model.dart';

class Cart extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CartState();
  }
}

class _CartState extends State<Cart> {
  List<int> quantities = [];
  bool stateChanged = false;
  static const _ITEM_HEIGHT = 40;
  @override
  void initState() {
    super.initState();
    locator<ConnectivityManager>().initConnectivity(context);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    locator<ConnectivityManager>().dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
          backgroundColor: Colors.terciariaTheOffer,
          appBar: AppBar(
              centerTitle: false,
              leading: IconButton(
                icon: Icon(Icons.close, color: Colors.principalTheOffer),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text('Carrinho', style: TextStyle(color: Colors.principalTheOffer),),
              bottom: model.isLoading
                  ? PreferredSize(
                      child: LinearProgressIndicator(),
                      preferredSize: Size.fromHeight(10),
                    )
                  : PreferredSize(
                      child: Container(),
                      preferredSize: Size.fromHeight(10),
                    )),
          body: !model.isLoading || model.order != null ? body() : Container(),
          bottomNavigationBar: BottomAppBar(
              child: Container(
                  color: Colors.secundariaTheOffer,
                  height: 100,
                  child: Column(children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: itemTotalContainer(model),
                    ),
                    proceedToCheckoutButton(),
                  ]))));
    });
  }

  Widget deleteButton(int index) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Text(model.lineItems[index].variant.quantity.toString());
    });
  }

  Widget body() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return CustomScrollView(
          slivers: <Widget>[
            items(),
          ],
        );
      },
    );
  }

  Widget itemTotalContainer(MainModel model) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[cartData(true), cartData(false)],
    );
  }

  Widget cartData(bool total) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      String getText() {
        return model.order == null
            ? ''
            : model.order.itemTotal == '0.0'
                ? ''
                : total
                    ? 'Valor do carrinho (${model.order.totalQuantity} items): '
                    : model.order.displaySubTotal;
      }

      return getText() == null
          ? Text('')
          : Text(
              getText(),
              style: total
                  ? TextStyle(
                      fontSize: 15,
                      color: Colors.principalTheOffer,
                      fontWeight: FontWeight.bold)
                  : TextStyle(
                      fontSize: 16.5,
                      color: Colors.principalTheOffer,
                      fontWeight: FontWeight.bold),
            );
    });
  }

  Widget proceedToCheckoutButton() {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Padding(
        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 58.0,
          padding: EdgeInsets.all(10),
          child: model.isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.secundariaTheOffer,
                  ),
                )
              : FlatButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2)),
                  color: Colors.principalTheOffer,
                  child: Text(
                    model.order == null
                        ? 'PROCURAR ITENS'
                        : model.order.itemTotal == '0.0'
                            ? 'PROCURAR ITENS'
                            : 'FINALIZAR',
                    style: TextStyle(
                        fontSize: 15,
                        color: Colors.secundariaTheOffer),
                  ),
                  onPressed: () async {
                    print("ESTADO DO PEDIDO ___________ ${model.order.state}");
                    if (model.order != null) {
                      if (model.order.itemTotal != '0.0') {
                        if (model.isAuthenticated) {
                          if (model.order.state == 'cart') {
                            print('NO CARRINHO, MUDAR');
                            bool _stateischanged = await model.changeState();
                            if (_stateischanged) {
                              if (model.order.state == 'address') {
                                print(
                                    'EM ENTREGA');
                                _stateischanged = await model.changeState();
                              }
                            }
                            setState(() {
                              stateChanged = _stateischanged;
                            });
                            if (stateChanged) {
                              // print('STATE IS CHANGED, FETCH CURRENT ORDER');
                              // model.fetchCurrentOrder();
                              MaterialPageRoute addressRoute =
                                  MaterialPageRoute(
                                      builder: (context) => AddressPage());
                              Navigator.push(context, addressRoute);
                            } else {
                              print("OCORREU UM ERRO AO BUSCAR O PEDIDO");
                            }
                          } else {
                            stateChanged = await model.fetchCurrentOrder();
                            if (stateChanged) {
                              // print('STATE IS CHANGED, FETCH CURRENT ORDER');
                              // model.fetchCurrentOrder();
                              MaterialPageRoute addressRoute =
                                  MaterialPageRoute(
                                      builder: (context) => AddressPage());
                              Navigator.push(context, addressRoute);
                            } else {
                              print("OCORREU UM ERRO AO BUSCAR O PEDIDO");
                            }
                          }
                        } else {
                          MaterialPageRoute authRoute = MaterialPageRoute(
                              builder: (context) => Authentication(0));
                          Navigator.push(context, authRoute);
                        }
                      } else {
                        Navigator.popUntil(context,
                            ModalRoute.withName(Navigator.defaultRouteName));
                      }
                    } else {
                      Navigator.popUntil(context,
                          ModalRoute.withName(Navigator.defaultRouteName));
                    }
                  },
                ),
        ),
      );
    });
  }

  Widget items() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return SliverList(
          delegate:
              SliverChildBuilderDelegate((BuildContext context, int index) {
            return GestureDetector(
                onTap: () {},
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 1,
                  margin: EdgeInsets.all(8.0),
                  child: Container(
                    color: Colors.secundariaTheOffer,
                    child: GestureDetector(
                      onTap: () {},
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Stack(
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.all(15),
                                height: 150,
                                width: 100,
                                color: Colors.secundariaTheOffer,
                                child: FadeInImage(
                                  image: NetworkImage(
                                      model.lineItems[index].variant.image !=
                                              null
                                          ? model.lineItems[index].variant.image
                                          : ''),
                                  placeholder: AssetImage(
                                      'images/placeholders/no-product-image.png'),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                              child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    // Expanded(
                                    // child:
                                    Container(
                                      padding: EdgeInsets.only(top: 10),
                                      width: 150,
                                      child: RichText(
                                        text: TextSpan(children: [
                                          TextSpan(
                                            text:
                                                '${model.lineItems[index].variant.name.split(' ')[0]} ',
                                            style: TextStyle(
                                                color: Colors.principalTheOffer,
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          TextSpan(
                                            text: model
                                                .lineItems[index].variant.name
                                                .substring(
                                                    model.lineItems[index]
                                                            .variant.name
                                                            .split(' ')[0]
                                                            .length +
                                                        1,
                                                    model.lineItems[index]
                                                        .variant.name.length),
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.principalTheOffer),
                                          ),
                                        ]),
                                      ),
                                    ),
                                    // ),
                                    // Expanded(
                                    // child:
                                    Container(
                                      padding: EdgeInsets.only(top: 0),
                                      child: IconButton(
                                        iconSize: 24,
                                        color: Colors.principalTheOffer,
                                        icon: Icon(Icons.close),
                                        onPressed: () {
                                          model.removeProduct(
                                              model.lineItems[index].id);
                                        },
                                      ),
                                    ),
                                    // )
                                  ],
                                ),
                              ),
                              SizedBox(height: 10),
                              Container(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  model.lineItems[index].variant.displayPrice,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      color: Colors.principalTheOffer,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                              ),
                              SizedBox(height: 12),
                              quantityRow(model, index),
                            ],
                          )),
                        ],
                      ),
                    ),
                  ),
                ));
          }, childCount: model.lineItems.length),
        );
      },
    );
  }

  Widget quantityRow(MainModel model, int lineItemIndex) {
    print(
        "QUANTIDADE DE ITENS NO CARRINHO, ${model.lineItems[lineItemIndex].variant.totalOnHand} ISBACKORDERABLE ${model.lineItems[lineItemIndex].variant.isBackOrderable}");
    return Container(
        height: 60.0,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          // itemExtent: 50,
          itemCount: model.lineItems[lineItemIndex].variant.totalOnHand > 38
              ? 39
              : model.lineItems[lineItemIndex].variant.isBackOrderable
                  ? 39
                  : model.lineItems[lineItemIndex].variant.totalOnHand + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return Container();
            } else {
              return GestureDetector(
                onTap: () {
                  model.adicionarProduto(
                    variantId: model.lineItems[lineItemIndex].variantId,
                    quantidade: index - model.lineItems[lineItemIndex].quantity,
                  );
                },
                child: Container(
                    width: 40,
                    decoration: BoxDecoration(
                        border: Border.all(
                          color:
                              model.lineItems[lineItemIndex].quantity == index
                                  ? Colors.principalTheOffer
                                  : Colors.principalTheOffer,
                        ),
                        borderRadius: BorderRadius.circular(5)),
                    alignment: Alignment.center,
                    margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    child: Text(
                      index.toString(),
                      style: TextStyle(
                          color:
                              model.lineItems[lineItemIndex].quantity == index
                                  ? Colors.principalTheOffer
                                  : Colors.principalTheOffer),
                    )),
              );
            }
          },
        ));
  }
}
