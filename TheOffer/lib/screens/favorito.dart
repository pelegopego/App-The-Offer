import 'package:flutter/material.dart';
import 'package:theoffer/models/favorito.dart';
import 'package:theoffer/scoped-models/main.dart';
import 'package:theoffer/utils/connectivity_state.dart';
import 'package:theoffer/utils/drawer_homescreen.dart';
import 'package:theoffer/utils/locator.dart';
import 'package:theoffer/widgets/botaoCarrinho.dart';
import 'package:scoped_model/scoped_model.dart';

class TelaFavorito extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TelaFavorito();
  }
}

class _TelaFavorito extends State<TelaFavorito> {
  List<Favorito> favoriteProducts = [];
  List<Favorito> deletedProducts = [];
  Future<List<Favorito>> futureFavoriteProducts;
  bool _isLoading = false;
  final scrollController = ScrollController();

  bool hasMore = false;
  @override
  void initState() {
    super.initState();
    locator<ConnectivityManager>().initConnectivity(context);
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.offset) {
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    locator<ConnectivityManager>().dispose();
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          centerTitle: false,
          title: Text('Favoritos'),
          actions: <Widget>[
            shoppingCarrinhoIconButton(),
          ],
          bottom: _isLoading
              ? PreferredSize(
                  child: LinearProgressIndicator(),
                  preferredSize: Size.fromHeight(10),
                )
              : PreferredSize(
                  child: Container(),
                  preferredSize: Size.fromHeight(10),
                ),
        ),
        drawer: HomeDrawer(),
        body: Padding(
            padding: const EdgeInsets.only(top: 3.0),
            child: model.isLoading
                ? LinearProgressIndicator()
                : Theme(
                    data: ThemeData(primarySwatch: Colors.secundariaTheOffer),
                    child: ListView.builder(
                        controller: scrollController,
                        itemCount: favoriteProducts.length + 1,
                        itemBuilder: (mainContext, index) {
                          if (index < favoriteProducts.length) {
                            // return favoriteCard(
                            //     context, searchProducts[index], index);
                            return favoriteCardPaginated(
                                _scaffoldKey.currentContext,
                                favoriteProducts[index],
                                index);
                          }
                          if (hasMore && favoriteProducts.length == 0) {
                            return noProductFoundWidget();
                          }
                          if (!hasMore || _isLoading) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.0),
                              child: Center(
                                  child: CircularProgressIndicator(
                                backgroundColor: Colors.principalTheOffer,
                              )),
                            );
                          } else {
                            return Container();
                          }
                        }),
                  )),
      );
    });
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
                  Icons.favorite_border,
                  size: 80.0,
                  color: Colors.grey,
                ),
                SizedBox(
                  height: 10.0,
                ),
                Text(
                  'Favoritos',
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
                    "Salve e organize, seus produtos favoritos!",
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
                      'INICIAR COMPRAS',
                      style: TextStyle(color: Colors.principalTheOffer),
                    )),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget favoriteCardPaginated(
      BuildContext context, Favorito favorito, int index) {
    bool isDeleted = false;
    deletedProducts.forEach((deletedItem) {
      if (deletedItem.id == favorito.id) {
        isDeleted = true;
      }
    });
    if (isDeleted) {
      return Container();
    } else {
      return ScopedModelDescendant<MainModel>(
          builder: (BuildContext context, Widget child, MainModel model) {
        return GestureDetector(
          onTap: () {
            // getProductDetail(favorite.slug);
            model.getProdutoDetalhe(1, context);//*bug
          },
          child: Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            margin: EdgeInsets.all(4),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: EdgeInsets.all(10),
                height: 150,
                width: 150,
                color: Colors.principalTheOffer,
                child: Image(
                  image: NetworkImage(
                      favorito.image != null ? favorito.image : ''),
                ),
              ),
              Expanded(
                child: Container(
                  height: 150.0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    right: 10.0, top: 10.0),
                                child: RichText(
                                  text: TextSpan(children: [
                                    TextSpan(
                                      text: '${favorito.name.split(' ')[0]} ',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text: favorito.name.substring(
                                          favorito.name.split(' ')[0].length +
                                              1,
                                          favorito.name.length),
                                      style: TextStyle(
                                          fontSize: 15, color: Colors.black),
                                    ),
                                  ]),
                                ),
                              ),
                            ),
                            IconButton(
                              color: Colors.grey,
                              icon: Icon(Icons.clear),
                              onPressed: () async {
                                //Map<String, String> headers = getHeaders();
                                _scaffoldKey.currentState.showSnackBar(SnackBar(
                                  content: Text(
                                    'Removendo dos favoritos, aguarde.',
                                  ),
                                  duration: Duration(seconds: 1),
                                ));/*
                                http
                                    .delete(
                                        Settings.SERVER_URL +
                                            'favorite_products/${favorite.id}',
                                        headers: headers)
                                    .then((response) {
                                  Map<dynamic, dynamic> responseBody =
                                      json.decode(response.body);
                                  if (responseBody['message'] != null) {
                                    setState(() {
                                      addItemtoDeleteList(favorite);
                                    });
                                    _scaffoldKey.currentState
                                        .showSnackBar(SnackBar(
                                      content: Text(responseBody['message']),
                                      duration: Duration(seconds: 1),
                                    ));
                                  } else {
                                    _scaffoldKey.currentState
                                        .showSnackBar(SnackBar(
                                      content:
                                          Text('Ocorreu algum erro'),
                                      duration: Duration(seconds: 1),
                                    ));
                                  }
                                });*/
                              },
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Preço',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: 15, color: Colors.grey.shade700),
                            ),
                            Container(
                              padding: EdgeInsets.only(right: 10.0),
                              child: Text(
                                favorito.currencySymbol + favorito.price,
                                textAlign: TextAlign.left,
                                style:
                                    TextStyle(fontSize: 15, color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]),
          ),
        );
      });
    }
  }

  void addItemtoDeleteList(Favorito favorito) {
    deletedProducts.add(favorito);
  }

}
