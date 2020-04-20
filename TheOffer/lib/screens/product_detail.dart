import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:theoffer/models/option_type.dart';
import 'package:theoffer/models/option_value.dart';
import 'package:theoffer/models/product.dart';
import 'package:theoffer/models/review.dart';
import 'package:theoffer/scoped-models/main.dart';
import 'package:theoffer/screens/auth.dart';
import 'package:theoffer/screens/review_detail.dart';
import 'package:theoffer/screens/search.dart';
import 'package:theoffer/utils/connectivity_state.dart';
import 'package:theoffer/utils/constants.dart';
import 'package:theoffer/utils/constants.dart' as prefix0;
import 'package:theoffer/utils/headers.dart';
import 'package:theoffer/utils/locator.dart';
import 'package:theoffer/widgets/rating_bar.dart';
import 'package:theoffer/widgets/shopping_cart_button.dart';
import 'package:theoffer/widgets/snackbar.dart';
import 'package:theoffer/screens/cart.dart';
import 'package:theoffer/widgets/todays_deals_card.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  ProductDetailScreen(this.product);
  @override
  State<StatefulWidget> createState() {
    return _ProductDetailtelastate();
  }
}

class _ProductDetailtelastate extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  bool _isFavorite = false;
  bool discount = true;
  bool _isLoading = true;
  TabController _tabController;
  Size _deviceSize;
  int quantity = 1;
  Product selectedProduct;
  String htmlDescription;
  List<Product> similarProducts = List();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String pincode = '';

  @override
  void initState() {
    _tabController = TabController(length: 1, vsync: this);
    if (widget.product.hasVariants != null) {
      if (widget.product.hasVariants) {
        selectedProduct = widget.product.variants.first;
        _isFavorite = widget.product.variants.first.favoritedByUser;
        discount = (double.parse(widget.product.variants.first.costPrice) -
                    double.parse(widget.product.variants.first.price)) >
                0
            ? true
            : false;
        htmlDescription = widget.product.variants.first.description != null
            ? widget.product.variants.first.description
            : '';
      } else {
        _isFavorite = widget.product.favoritedByUser;
        selectedProduct = widget.product;
        discount = (double.parse(widget.product.costPrice) -
                    double.parse(widget.product.price)) >
                0
            ? true
            : false;
        htmlDescription = widget.product.description != null
            ? widget.product.description
            : '';
      }
    } else {
      _isFavorite = widget.product.favoritedByUser;
      selectedProduct = widget.product;
      discount = (double.parse(widget.product.costPrice) -
                  double.parse(widget.product.price)) >
              0
          ? true
          : false;
      htmlDescription =
          widget.product.description != null ? widget.product.description : '';
    }
    getSimilarProducts();
    locator<ConnectivityManager>().initConnectivity(context);
    // _dropDownVariantItems = getVariants();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    locator<ConnectivityManager>().dispose();
  }

  @override
  Widget build(BuildContext context) {
    _deviceSize = MediaQuery.of(context).size;
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.terciariaTheOffer,
          appBar: AppBar(
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                }),
            title: Text('Detalhes do item'),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  MaterialPageRoute route =
                      MaterialPageRoute(builder: (context) => ProductSearch());
                  Navigator.of(context).push(route);
                },
              ),
              shoppingCartIconButton()
            ],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(50),
              child: Column(
                children: [
                  TabBar(
                    indicatorWeight: 1,
                    controller: _tabController,
                    tabs: <Widget>[
                      Tab(
                        text: '',
                      ),
                    ],
                  ),
                  model.isLoading ? LinearProgressIndicator() : Container()
                ],
              ),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: <Widget>[highlightsTab()],
          ),
          floatingActionButton: addToCartFAB());
    });
  }

  Widget writeReview() {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 40.0,
              width: 335,
              child: GestureDetector(
                onTap: () {
                  if (model.isAuthenticated) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            ReviewDetailScreen(selectedProduct)));
                  } else {
                    // Scaffold.of(context).showSnackBar(LoginErroSnackbar);
                    _scaffoldKey.currentState.showSnackBar(SnackBar(
                      content: Text(
                        'Precisa entrar na conta para avaliar.',
                      ),
                      action: SnackBarAction(
                        label: 'LOGIN',
                        onPressed: () {
                          MaterialPageRoute route = MaterialPageRoute(
                              builder: (context) => Authentication(0));
                          Navigator.push(context, route);
                        },
                      ),
                    ));
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.secundariaTheOffer,
                      style: BorderStyle.solid,
                      width: 1.0,
                    ),
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Center(
                        child: Text(
                          "AVALIE O PRODUTO",
                          style: TextStyle(
                            color: Colors.secundariaTheOffer,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ]);
    });
  }

  Widget quantityRow(MainModel model, Product selectedProduct) {
    print(
        "PRODUTO SELECIONADO ---> ${selectedProduct.totalOnHand}  ${selectedProduct.slug}");
    return Container(
        height: 60.0,color: Colors.secundariaTheOffer,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: selectedProduct.totalOnHand > 20
              ? 21
              : selectedProduct.isBackOrderable
                  ? 21
                  : selectedProduct.totalOnHand + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return Container();
            } else {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    quantity = index;
                  });
                },
                child: Container(
                    width: 45,
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: quantity == index
                              ? Colors.principalTheOffer
                              : Colors.principalTheOffer,
                        ),
                        borderRadius: BorderRadius.circular(5)),
                    alignment: Alignment.center,
                    // margin: EdgeInsets.all(10),
                    margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    padding: EdgeInsets.all(10),
                    child: Text(
                      index.toString(),
                      style: TextStyle(
                          color: quantity == index
                              ? Colors.principalTheOffer
                              : Colors.principalTheOffer),
                    )),
              );
            }
          },
        ));
  }

  Widget highlightsTab() {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                    color: Colors.secundariaTheOffer,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        // Expanded(
                        //   child:
                        Center(
                          child: Container(
                            alignment: Alignment.center,    
                            height: 300,
                            width: 220,
                            child: FadeInImage(
                              image: NetworkImage(selectedProduct.image != null
                                  ? selectedProduct.image
                                  : ''),
                              placeholder: AssetImage(
                                  'images/placeholders/no-product-image.png'),
                            ),
                          ),
                        )

                        // ),
                      ],
                    ),
                  ),
                  Container(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      padding: EdgeInsets.only(top: 40, right: 15.0),
                      alignment: Alignment.topRight,
                      icon: Icon(Icons.favorite),
                      color: _isFavorite ? Colors.principalTheOffer : Colors.grey,
                      onPressed: () async {
                        final SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        String authToken = prefs.getString('spreeApiKey');
                        Map<String, String> headers = await getHeaders();

                        if (!_isFavorite) {
                          if (authToken == null) {
                            _scaffoldKey.currentState.showSnackBar(SnackBar(
                              content: Text(
                                'Entre na sua conta para adicionar aos favoritos',
                              ),
                              action: SnackBarAction(
                                label: 'LOGIN',
                                onPressed: () {
                                  MaterialPageRoute route = MaterialPageRoute(
                                      builder: (context) => Authentication(0));
                                  Navigator.push(context, route);
                                },
                              ),
                            ));
                          } else {
                            _scaffoldKey.currentState.showSnackBar(SnackBar(
                              content: Text(
                                'Adicionando aos favoritos aguarde.',
                              ),
                              duration: Duration(seconds: 1),
                            ));
                            http
                                .post(Settings.SERVER_URL + 'favorite_products',
                                    body: json.encode({
                                      'id': widget.product.reviewProductId
                                          .toString()
                                    }),
                                    headers: headers)
                                .then((response) {
                              Map<dynamic, dynamic> responseBody =
                                  json.decode(response.body);
                              setState(() {
                                _isFavorite = true;
                              });
                              _scaffoldKey.currentState.showSnackBar(SnackBar(
                                content: Text('Produto adicionado aos favoritos!'),
                                duration: Duration(seconds: 1),
                              ));
                            });
                          }
                        } else {
                          _scaffoldKey.currentState.showSnackBar(SnackBar(
                            content: Text(
                              'Removendo produto dos favoritos, aguarde.',
                            ),
                            duration: Duration(seconds: 1),
                          ));
                          http
                              .delete(
                                  Settings.SERVER_URL +
                                      'favorite_products/${widget.product.reviewProductId}',
                                  headers: headers)
                              .then((response) {
                            Map<dynamic, dynamic> responseBody =
                                json.decode(response.body);
                            if (responseBody['message'] != null) {
                              setState(() {
                                _isFavorite = false;
                              });
                              _scaffoldKey.currentState.showSnackBar(SnackBar(
                                content: Text(responseBody['message']),
                                duration: Duration(seconds: 1),
                              ));
                            } else {
                              _scaffoldKey.currentState.showSnackBar(SnackBar(
                                content: Text('Ocorreu um erro'),
                                duration: Duration(seconds: 1),
                              ));
                            }
                          });
                        }
                      },
                    ),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Container(
                  color: Colors.secundariaTheOffer,
                  width: _deviceSize.width,
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Text(
                          '${selectedProduct.name.split(' ')[0]}',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.normal,
                              color: Colors.principalTheOffer,
                              fontFamily: fontFamily),
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          ratingBar(selectedProduct.avgRating, 20),
                          Container(
                              margin: EdgeInsets.only(right: 10),
                              child: Text(selectedProduct.reviewsCount, 
                                          style: TextStyle(color: Colors.principalTheOffer)),
                              ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              Container(
                color: Colors.secundariaTheOffer,
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.all(10),
                child: Text(
                  selectedProduct.name,
                  style: TextStyle(
                      fontSize: 17,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.bold,
                      fontFamily: fontFamily,
                      color: Colors.principalTheOffer),
                  textAlign: TextAlign.start,
                ),
              ),
              selectedProduct.isOrderable
                  ? Container(
                      alignment: Alignment.centerLeft,
                      color: Colors.secundariaTheOffer,
                      padding: EdgeInsets.all(10),
                      child: Text(
                        'Quantidade ',
                        style: TextStyle(fontSize: 14, fontFamily: fontFamily, color: Colors.principalTheOffer),
                      ),
                    )
                  : Container(),
              selectedProduct.isOrderable
                  ? quantityRow(model, selectedProduct)
                  : Container(),
              Divider(color: Colors.secundariaTheOffer),
              discount
                  ? SizedBox(
                      height: 18,
                    )
                  : Container(),
              buildPriceRow('Preço: ', selectedProduct.displayPrice,
                  strike: discount,
                  originalPrice:
                      '${selectedProduct.currencySymbol} ${selectedProduct.costPrice}'),
              discount
                  ? Column(
                      children: <Widget>[
                        buildPriceRow(
                            'Economizou: ',
                            '${selectedProduct.currencySymbol}' +
                                (double.parse(selectedProduct.costPrice) -
                                        double.parse(selectedProduct.price))
                                    .toString(),
                            strike: false,
                            discountPercent: '(' +
                                (((double.parse(selectedProduct.costPrice) -
                                                double.parse(
                                                    selectedProduct.price)) /
                                            double.parse(
                                                selectedProduct.costPrice)) *
                                        100)
                                    .round()
                                    .toString() +
                                '%)  '),
                      ],
                    )
                  : Container(),
              Divider(color: Colors.secundariaTheOffer),
              SizedBox(
                height: 12.0,
              ),
              addToCartFlatButton(),
              SizedBox(
                height: 12.0,
              ),
              buyNowFlatButton(),
              Divider(color: Colors.principalTheOffer),
              SizedBox(
                height: 2,
              ),
              Column(
                children: <Widget>[
                  Container(
                      width: _deviceSize.width,
                      color: Colors.secundariaTheOffer,
                      child: ListTile(
                        contentPadding: EdgeInsets.only(left: 10.0),
                        title: Text('Você também pode gostar',
                            style: TextStyle(
                                fontSize: 14,
                                // fontWeight: FontWeight.w600,
                                color: Colors.principalTheOffer)),
                      )),
                ],
              ),
              _isLoading
                  ? Container(
                      height: _deviceSize.height * 0.47,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.secundariaTheOffer,
                      ),
                    )
                  : Container(
                      height: 355,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: similarProducts.length,
                        itemBuilder: (context, index) {
                          return todaysDealsCard(
                              index, similarProducts, _deviceSize, context);
                          // similarProductCard(index, similarProducts,
                          //     _deviceSize, context, true);
                        },
                      ),
                    ),
              Container(
                  color: Colors.secundariaTheOffer,
                  padding: EdgeInsets.only(left: 10.0, top: 20.0),
                  alignment: Alignment.centerLeft,
                  child: Text("Descrição",
                      style: TextStyle(
                          fontSize: 15.0, fontWeight: FontWeight.w600, color: Colors.principalTheOffer))),
              Container(
                  color: Colors.secundariaTheOffer,
                  padding: EdgeInsets.only(left: 10.0, top: 20.0),
                  alignment: Alignment.centerLeft,
                  child: Text(htmlDescription,
                      style: TextStyle(
                          fontSize: 15.0, fontWeight: FontWeight.w600, color: Colors.principalTheOffer))),
            ],
          ),
        ),
      );
    });
  }

  Widget buyNowFlatButton() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Container(
            color: Colors.secundariaTheOffer,
            width: double.infinity,
            height: 45.0,
            child: FlatButton(
              child: Text(
                selectedProduct.isOrderable ? 'COMPRAR AGORA' : 'FORA DE ESTOQUE',
                style: TextStyle(color: Colors.principalTheOffer),
              ),
              onPressed: selectedProduct.isOrderable
                  ? () {
                      Scaffold.of(context).showSnackBar(processSnackbar);
                      if (selectedProduct.isOrderable) {
                        model.addProduct(
                            variantId: selectedProduct.id, quantity: quantity);
                        if (!model.isLoading) {
                          Scaffold.of(context).showSnackBar(completeSnackbar);
                          MaterialPageRoute route =
                              MaterialPageRoute(builder: (context) => Cart());

                          Navigator.push(context, route);
                        }
                      }
                    }
                  : () {},
            ),
          ),
        );
      },
    );
  }

  Widget addToCartFlatButton() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Container(
            color: Colors.secundariaTheOffer,
            width: double.infinity,
            height: 45.0,
            child: FlatButton(
              child: Text(
                selectedProduct.isOrderable ? 'ADICIONAR AO CARRINHO' : 'FORA DE ESTOQUE',
                style: TextStyle(
                    color: selectedProduct.isOrderable
                        ? Colors.principalTheOffer
                        : Colors.principalTheOffer),
              ),
              onPressed: selectedProduct.isOrderable
                  ? () {
                      Scaffold.of(context).showSnackBar(processSnackbar);
                      if (selectedProduct.isOrderable) {
                        model.addProduct(
                            variantId: selectedProduct.id, quantity: quantity);
                        if (!model.isLoading) {
                          Scaffold.of(context).showSnackBar(completeSnackbar);
                        }
                      }
                    }
                  : () {},
            ),
          ),
        );
      },
    );
  }

  Widget addToCartFAB() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return _tabController.index == 0
            ? FloatingActionButton(
                child: Icon(
                  Icons.shopping_cart,
                  color: Colors.secundariaTheOffer,
                ),
                onPressed: selectedProduct.isOrderable
                    ? () {
                        Scaffold.of(context).showSnackBar(processSnackbar);
                        selectedProduct.isOrderable
                            ? model.addProduct(
                                variantId: selectedProduct.id,
                                quantity: quantity)
                            : null;
                        if (!model.isLoading) {
                          Scaffold.of(context).showSnackBar(completeSnackbar);
                        }
                      }
                    : () {},
                backgroundColor: selectedProduct.isOrderable
                    ? Colors.principalTheOffer
                    : Colors.principalTheOffer,
              )
            : FloatingActionButton(
                child: Icon(
                  Icons.add,
                  color: Colors.blue,
                ),
                onPressed: () {
                  if (model.isAuthenticated) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            ReviewDetailScreen(selectedProduct)));
                  } else {
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text(
                        'Por favor, entre em sua conta para avaliar.',
                      ),
                      action: SnackBarAction(
                        label: 'LOGIN',
                        onPressed: () {
                          MaterialPageRoute route = MaterialPageRoute(
                              builder: (context) => Authentication(0));
                          Navigator.push(context, route);
                        },
                      ),
                    ));
                  }
                },
                backgroundColor: Colors.orange);
      },
    );
  }

  Widget buildPriceRow(String key, String value,
      {bool strike, String originalPrice, String discountPercent}) {
      return Container(
            color: Colors.secundariaTheOffer,
            child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.all(10),
          child: Text(
            key,
            style: TextStyle(
              fontSize: 17,
              fontFamily: fontFamily,
              color: Colors.principalTheOffer,
            ),
          ),
        ),
        Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.all(10),
          child: strike
              ? RichText(
                  text: TextSpan(children: [
                    TextSpan(
                        text: originalPrice,
                        style: TextStyle(
                            color: Colors.principalTheOffer,
                            decoration: TextDecoration.lineThrough)),
                    TextSpan(text: '   '),
                    TextSpan(
                        text: value,
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.principalTheOffer,
                            fontFamily: fontFamily,
                            fontWeight: FontWeight.bold)),
                  ]),
                )
              : discount
                  ? RichText(
                      text: TextSpan(children: [
                        TextSpan(
                            text: discountPercent,
                            style: TextStyle(
                              color: Colors.principalTheOffer,
                            )),
                        TextSpan(
                            text: value,
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.principalTheOffer,
                                fontFamily: fontFamily,
                                fontWeight: FontWeight.bold)),
                      ]),
                    )
                  : Text(
                      value,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.principalTheOffer,
                        fontWeight: FontWeight.bold,
                        fontFamily: fontFamily,
                      ),
                    ),
        ),
      ],
    ));
  }

  Widget pincodeBox(MainModel model, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Container(
          width: _deviceSize.width * 0.60,
          height: 70,
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(bottom: 15, left: 10),
          child: Form(
            key: _formKey,
            child: TextFormField(
              initialValue: pincode,
              decoration: InputDecoration(
                  labelText: 'Codigo',
                  labelStyle: TextStyle(color: Colors.grey),
                  contentPadding: EdgeInsets.all(0.0)),
              onSaved: (String value) {
                setState(() {
                  pincode = value;
                });
              },
            ),
          ),
        ),
        FlatButton(
            child: Container(
              child: Text(
                'VERIFICAR',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.secundariaTheOffer),
              ),
            ),
            onPressed: () async {
              FocusScope.of(context).requestFocus(new FocusNode());
              _formKey.currentState.save();
              if (pincode != '') {
                bool available =
                    await model.shipmentAvailability(pincode: pincode);
                if (available) {
                  Scaffold.of(context).showSnackBar(codAvailable);
                } else {
                  Scaffold.of(context).showSnackBar(codNotAvailable);
                }
              } else {
                Scaffold.of(context).showSnackBar(codEmpty);
              }
            }),
      ],
    );
  }

  getSimilarProducts() {
    Map<String, dynamic> responseBody = Map();
    List<Product> variants = [];
    List<OptionValue> optionValues = [];
    List<OptionType> optionTypes = [];
    http
        .get(Settings.SERVER_URL +
            'api/v1/taxons/products?id=${widget.product.taxonId}&per_page=15&data_set=small')
        .then((response) {
      responseBody = json.decode(response.body);
      responseBody['products'].forEach((product) {
        int reviewProductId = product["id"];
        variants = [];
        if (product['has_variants']) {
          product['variants'].forEach((variant) {
            optionValues = [];
            optionTypes = [];
            variant['option_values'].forEach((option) {
              setState(() {
                optionValues.add(OptionValue(
                  id: option['id'],
                  name: option['name'],
                  optionTypeId: option['option_type_id'],
                  optionTypeName: option['option_type_name'],
                  optionTypePresentation: option['option_type_presentation'],
                ));
              });
            });
            setState(() {
              variants.add(Product(
                  id: variant['id'],
                  name: variant['name'],
                  description: variant['description'],
                  slug: variant['slug'],
                  optionValues: optionValues,
                  displayPrice: variant['display_price'],
                  image: variant['images'][0]['product_url'],
                  isOrderable: variant['is_orderable'],
                  avgRating: double.parse(product['avg_rating']),
                  reviewsCount: product['reviews_count'].toString(),
                  reviewProductId: reviewProductId));
            });
          });
          product['option_types'].forEach((optionType) {
            setState(() {
              optionTypes.add(OptionType(
                  id: optionType['id'],
                  name: optionType['name'],
                  position: optionType['position'],
                  presentation: optionType['presentation']));
            });
          });
          setState(() {
            similarProducts.add(Product(
                taxonId: product['taxon_ids'].first,
                id: product['id'],
                name: product['name'],
                slug: product['slug'],
                displayPrice: product['display_price'],
                avgRating: double.parse(product['avg_rating']),
                reviewsCount: product['reviews_count'].toString(),
                image: product['master']['images'][0]['product_url'],
                variants: variants,
                reviewProductId: reviewProductId,
                hasVariants: product['has_variants'],
                optionTypes: optionTypes));
          });
        } else {
          setState(() {
            similarProducts.add(Product(
              taxonId: product['taxon_ids'].first,
              id: product['id'],
              name: product['name'],
              slug: product['slug'],
              displayPrice: product['display_price'],
              avgRating: double.parse(product['avg_rating']),
              reviewsCount: product['reviews_count'].toString(),
              image: product['master']['images'][0]['product_url'],
              hasVariants: product['has_variants'],
              isOrderable: product['master']['is_orderable'],
              reviewProductId: reviewProductId,
              description: product['description'],
            ));
          });
        }
      });
      setState(() {
        _isLoading = false;
      });
    });
  }
}
