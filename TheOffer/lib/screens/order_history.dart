import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:theoffer/models/Pedido.dart';
import 'package:theoffer/screens/order_response.dart';
import 'package:theoffer/utils/connectivity_state.dart';
import 'package:theoffer/utils/locator.dart';
import 'package:theoffer/widgets/botaoCarrinho.dart';

class OrderList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _OrderList();
  }
}

class _OrderList extends State<OrderList> {
  List<dynamic> orderListResponse = List();
  var formatter = new DateFormat('dd-MMM-yyyy hh:mm a');
  List<Pedido> listaPedidos = [];
  Map<dynamic, dynamic> responseBody;
  final scrollController = ScrollController();
  bool hasMore = false;
  void initState() {
    super.initState();
    locator<ConnectivityManager>().initConnectivity(context);
    getOrdersLists();
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.offset) {
        getOrdersLists();
      }
    });
  }

  Size _deviceSize;

  Future<List<Pedido>> getOrdersLists() async {
    print("Lista de pedidos");
    setState(() {
      hasMore = false;
    });
/*
    Map<String, String> headers = getHeaders();
    final response = (await http.get(
            Settings.SERVER_URL +
                '/api/v1/orders/mine?desc&page=$currentPage&per_page=$perPage',
            headers: headers))
        .body;

    currentPage++;
    responseBody = json.decode(response);
    print('RETORNO HISTÓRICO DE PEDIDOS $responseBody');

    responseBody['pedidos'].forEach((pedido) {
      setState(() {
        listaPedidos.add(Pedido(
            id: pedido["completed_at"],
            dataInclusao: pedido['dataInclusao'],
            dataConfirmacao: pedido['dataConfirmacao'],
            status: pedido["status"]
            /* listaItenspedido */));
        orderListResponse.add(pedido);
      });
    });
    setState(() {
      hasMore = true;
    });*/
    return listaPedidos;
  }

  @override
  void dispose() {
    super.dispose();
    locator<ConnectivityManager>().dispose();
  }

  Widget build(BuildContext context) {
    _deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text('Histórico de pedidos'),
        actions: <Widget>[shoppingCarrinhoIconButton()],
      ),
      body: Padding(
          padding: const EdgeInsets.only(top: 3.0),
          child: Theme(
            data: ThemeData(primarySwatch: Colors.secundariaTheOffer),
            child: ListView.builder(
                controller: scrollController,
                itemCount: listaPedidos.length + 1,
                itemBuilder: (mainContext, index) {
                  if (index < listaPedidos.length) {
                    // return favoriteCard(
                    //     context, searchProducts[index], index);
                    return orderItem(context,listaPedidos[index], index);
                  }
                  if (hasMore && listaPedidos.length == 0) {
                    return noProductFoundWidget();
                  }
                  if (!hasMore) {
                    return Container(
                        height: _deviceSize.height,
                        child: Center(
                            child: CircularProgressIndicator(
                          backgroundColor: Colors.principalTheOffer,
                        )));
                  } else {
                    return Container();
                  }
                }),
          )),
      /*Theme(
        data: ThemeData(primarySwatch: Colors.secundariaTheOffer),
        child: PagewiseListView(
          pageSize: PAGE_SIZE,
          itemBuilder: orderItem,
          pageFuture: (pageIndex) => getOrdersLists(),
        ),
      ),*/
    );
  }

  Widget orderItem(BuildContext context, Pedido pedido, int index) {
    return GestureDetector(
      onTap: () {
        goToDetailsPage(orderListResponse[index]);
      },
      child: Card(
        child: new Container(
          width: _deviceSize.width,
          margin: EdgeInsets.all(5),
          child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ListTile(
                    //leading: orderVariantImage(pedido.imageUrl),
                    title: Text('${pedido.id}'),
                    subtitle: Text((formatter.format(DateTime.parse(
                        (pedido.dataInclusao.split('+05:30')[0]))))),
                    trailing: trailingSpace(pedido),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10.0)),
              ]),
        ),
      ),
    );
  }

  Widget noProductFoundWidget() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(top: 220.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Icon(
                  Icons.card_giftcard,
                  size: 80.0,
                  color: Colors.grey,
                ),
                SizedBox(
                  height: 10.0,
                ),
                Text(
                  'Não possui pedidos efetuados',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 25.0),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 10.0,
                ),
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 35.0, vertical: 5),
                  child: Text(
                    'Compre aqui!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black, fontSize: 16.0),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 150,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 40.0,
              child: Padding(
                padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                child: RaisedButton(
                    color: Colors.deepOrange,
                    onPressed: () {
                      // Navigator.pop(context);
                      Navigator.popUntil(context,
                          ModalRoute.withName(Navigator.defaultRouteName));
                    },
                    child: Text(
                      'IR AS COMPRAS',
                      style: TextStyle(color: Colors.principalTheOffer),
                    )),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget orderVariantImage(imageUrl) {
    return FadeInImage(
      image: NetworkImage(imageUrl != null ? imageUrl : ''),
      placeholder: AssetImage(
        'images/placeholders/no-product-image.png',
      ),
      width: 35,
    );
  }

  goToDetailsPage(detailOrder) {
    MaterialPageRoute orderResponse = MaterialPageRoute(
        builder: (context) =>
            OrderResponse(orderNumber: null, detailOrder: detailOrder));
    Navigator.push(context, orderResponse);
  }

  trailingSpace(detailOrder) {
    return new Container(
      margin: EdgeInsets.only(top: 8),
      child: new Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text('${detailOrder.displayTotal}'),
            SizedBox(height: 8),
            getOrderStatus(detailOrder)
          ]),
    );
  }

  getOrderStatus(detailOrder) {
    if (detailOrder.paymentState == 'balance_due' &&
        detailOrder.shipState == 'shipped') {
      return Text('Comprado', style: TextStyle(color: Colors.secundariaTheOffer));
    } else if (detailOrder.paymentState == 'balance_due') {
      return Text('Pendente', style: TextStyle(color: Colors.blue));
    } else if (detailOrder.paymentState == 'void') {
      return Text('Cancelado', style: TextStyle(color: Colors.red));
    } else if (detailOrder.paymentState == 'paid' &&
        detailOrder.shipState == 'shipped') {
      return Text('Finalizado', style: TextStyle(color: Colors.grey));
    } else {
      return Text('Em processo', style: TextStyle(color: Colors.amber));
    }
  }
}
