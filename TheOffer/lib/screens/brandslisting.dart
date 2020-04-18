import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:theoffer/models/brand.dart';
import 'package:theoffer/models/option_type.dart';
import 'package:theoffer/models/option_value.dart';
import 'package:theoffer/models/product.dart';
import 'package:theoffer/scoped-models/main.dart';
import 'package:theoffer/screens/search.dart';
import 'package:theoffer/utils/connectivity_state.dart';
import 'package:theoffer/utils/constants.dart';
import 'package:theoffer/utils/drawer_homescreen.dart';
import 'package:theoffer/utils/headers.dart';
import 'package:theoffer/utils/locator.dart';
import 'package:theoffer/widgets/product_container.dart';
import 'package:theoffer/widgets/shopping_cart_button.dart';
import 'package:scoped_model/scoped_model.dart';

class BrandList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BrandListState();
  }
}

class _BrandListState extends State<BrandList> {
  Map<dynamic, dynamic> responseBody;
  List<Brand> brands = [];
  List<Product> productsByBrand = [];
  bool _isLoading = true;
  bool _isSelected = false;
  Size _deviceSize;
  String _brandName = '';
  String _heading = 'By Brand';
  final int perPage = TWENTY;
  int currentPage = ONE;
  int subCatId = ZERO;
  int brandId = 0;
  String sortBy = '';
  final scrollController = ScrollController();
  bool hasMore = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<DropdownMenuItem<String>> _dropDownMenuItems;
  static const int PAGE_SIZE = 20;
  String _currentItem;
  List filterItems = [
    "Novos",
    "Média de avaliação dos compradores",
    "Mais vistos",
    "A até Z",
    "Z até A"
  ];
  List<DropdownMenuItem<String>> getDropDownMenuItems() {
    List<DropdownMenuItem<String>> items = new List();
    for (String city in filterItems) {
      items.add(new DropdownMenuItem(
          value: city,
          child: Text(
            city,
          )));
    }
    return items;
  }

  @override
  void initState() {
    super.initState();
    sortBy = '';
    _dropDownMenuItems = getDropDownMenuItems();
    _currentItem = _dropDownMenuItems[0].value;
    getBrandsList();
    scrollController.addListener(() {
      if (scrollController.offset >=
              scrollController.position.maxScrollExtent &&
          !scrollController.position.outOfRange) {
        getBrandProducts(0);
      }
    });
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
    _deviceSize = MediaQuery.of(context).size;

    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return WillPopScope(
          onWillPop: () => _canLeave(),
          child: Scaffold(
              key: _scaffoldKey,
              appBar: AppBar(
                elevation: 0.0,
                title: Text('Comprar'),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      MaterialPageRoute route = MaterialPageRoute(
                          builder: (context) => ProductSearch());
                      Navigator.of(context).push(route);
                    },
                  ),
                  shoppingCartIconButton()
                ],
              ),
              drawer: HomeDrawer(),
              endDrawer: filterDrawer(),
              body: Stack(
                children: <Widget>[
                  Scrollbar(
                      child: _isLoading
                          ? Container(
                              height: _deviceSize.height,
                            )
                          : !_isSelected
                              ? Padding(
                                  child: ListView.builder(
                                      itemCount: brands.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return Container(
                                            color: Colors.white,
                                            child: Column(children: [
                                              GestureDetector(
                                                  onTap: () {
                                                    productsByBrand = [];
                                                    currentPage = 1;
                                                    brandId = brands[index].id;
                                                    setState(() {
                                                      _isSelected = true;
                                                      //_isLoading = true;
                                                      _brandName =
                                                          brands[index].name;
                                                    });
                                                    getBrandProducts(0);
                                                  },
                                                  child: Container(
                                                      color: Colors.white,
                                                      width: _deviceSize.width,
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      margin:
                                                          EdgeInsets.all(10),
                                                      padding:
                                                          EdgeInsets.all(10),
                                                      child: Text(
                                                        brands[index].name,
                                                        style: TextStyle(
                                                          fontSize: 20,
                                                        ),
                                                      ))),
                                              Divider()
                                            ]));
                                      }),
                                  padding: EdgeInsets.only(top: 59.0))
                              : Theme(
                                  data: ThemeData(primarySwatch: Colors.green),
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 90.0),
                                    child: ListView.builder(
                                        controller: scrollController,
                                        itemCount: productsByBrand.length + 1,
                                        itemBuilder: (context, index) {
                                          if (index < productsByBrand.length) {
                                            return productContainer(context,
                                                productsByBrand[index], index);
                                          }
                                          if (hasMore &&
                                              productsByBrand.length == 0) {
                                            print("Comprimento 00000000");
                                            return Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 50.0),
                                              child: Center(
                                                child: Text(
                                                  'Não foi encontrado produto',
                                                  style:
                                                      TextStyle(fontSize: 20.0),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            );
                                          }
                                          if (!hasMore) {
                                            return Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 25.0),
                                              child: Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                backgroundColor: Colors.white,
                                              )),
                                            );
                                          } else {
                                            return Container();
                                          }
                                        }),
                                  ),
                                )),
                  Container(
                      color: Colors.green,
                      height: 60.0,
                      child: Column(children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isSelected = false;
                                  });
                                },
                                child: Container(
                                  margin: EdgeInsets.only(
                                    left: 70,
                                    bottom: 20,
                                  ),
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    _heading,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: _isSelected
                                            ? FontWeight.w200
                                            : FontWeight.bold),
                                  ),
                                )),
                            _isSelected
                                ? Container(
                                    margin: EdgeInsets.only(
                                      bottom: 20,
                                    ),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      ' > ',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w200),
                                    ),
                                  )
                                : Container(),
                            _isSelected
                                ? Container(
                                    margin: EdgeInsets.only(
                                      bottom: 20,
                                    ),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      _brandName,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )
                                : Container()
                          ],
                        ),
                        _isLoading || model.isLoading
                            ? Padding(
                                child: LinearProgressIndicator(),
                                padding: EdgeInsets.only(top: 10.0))
                            : Container()
                      ])),
                  _isSelected
                      ? Container(
                          padding: EdgeInsets.only(right: 20.0, top: 30.0),
                          alignment: Alignment.topRight,
                          child: FloatingActionButton(
                            onPressed: () {
                              _scaffoldKey.currentState.openEndDrawer();
                            },
                            child: Icon(
                              Icons.filter_list,
                              color: Colors.white,
                            ),
                            backgroundColor: Colors.orange,
                          ),
                        )
                      : Container(),
                ],
              )));
    });
  }

  Widget filterDrawer() {
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Material(
            elevation: 3.0,
            child: Container(
                alignment: Alignment.centerLeft,
                color: Colors.orange,
                height: 150.0,
                child: ListTile(
                  title: Row(
                    children: <Widget>[
                      Text(
                        'Ordenar por:  ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 18.0),
                      ),
                      DropdownButton(
                        underline: Container(),
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 15.0,
                            fontWeight: FontWeight.normal),
                        value: null,
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: Colors.white,
                        ),
                        hint: Text(
                          _currentItem,
                          style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold),
                        ),
                        items: _dropDownMenuItems,
                        onChanged: changedDropDownItem,
                      )
                    ],
                  ),
                )),
          ),
          Expanded(
            child: Theme(
                data: ThemeData(primarySwatch: Colors.green),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.all(8.0),
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            productsByBrand = [];
                            currentPage = 1;
                            brandId = brands[index].id;
                            _brandName = brands[index].name;
                            getBrandProducts(0);
                          });
                        },
                        child: Container(
                            width: _deviceSize.width,
                            alignment: Alignment.centerLeft,
                            margin: EdgeInsets.all(10),
                            padding: EdgeInsets.all(10),
                            child: Text(
                              brands[index].name,
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            )));
                  },
                  itemCount: brands.length,
                )),
          ),
        ],
      ),
    );
  }

  getBrandsList() {
    http
        .get(Settings.SERVER_URL +
            'api/v1/taxonomies?q[name_cont]=Brands&set=nested')
        .then((response) {
      responseBody = json.decode(response.body);
      responseBody['taxonomies'][0]['root']['taxons'].forEach((brandObj) {
        setState(() {
          brands.add(Brand(name: brandObj['name'], id: brandObj['id']));
        });
      });
      setState(() {
        _isLoading = false;
      });
    });
  }

  void getBrandProducts(int id) async {
    List<Product> variants = [];
    List<OptionValue> optionValues = [];
    List<OptionType> optionTypes = [];
    Map<String, String> headers = await getHeaders();
    setState(() {
      hasMore = false;
    });
    print(
        "Ver produtos por marca +${Settings.SERVER_URL + 'api/v1/taxons/products?id=$brandId&page=$currentPage&per_page=$perPage&data_set=small'}");
    var response;

    if (sortBy != null) {
      response = (await http.get(
              Settings.SERVER_URL +
                  'api/v1/taxons/products?id=$brandId&page=$currentPage&per_page=$perPage&q[s]=$sortBy&data_set=small',
              headers: headers))
          .body;
    } else {
      response = (await http.get(
              Settings.SERVER_URL +
                  'api/v1/taxons/products?id=$brandId&page=$currentPage&per_page=$perPage&data_set=small',
              headers: headers))
          .body;
    }

    currentPage++;
    responseBody = json.decode(response);
    responseBody['data'].forEach((product) {
      productsByBrand.add(Product(
          reviewProductId: product['id'],
          name: product['attributes']['name'],
          image: product['attributes']['product_url'],
          currencySymbol: product['attributes']['currency_symbol'],
          displayPrice: product['attributes']['currency_symbol'] +
              product['attributes']['price'],
          price: product['attributes']['price'],
          costPrice: product['attributes']['cost_price'],
          slug: product['attributes']['slug'],
          avgRating: double.parse(product['attributes']['avg_rating']),
          reviewsCount: product['attributes']['reviews_count'].toString()));
    });
    setState(() {
      hasMore = true;
    });
    /*setState(() {
        _isLoading = false;
      });
    });*/
  }

  Future<bool> _canLeave() {
    if (!_isSelected) {
      return Future<bool>.value(true);
    } else {
      setState(() {
        _isSelected = false;
      });
      return Future<bool>.value(false);
    }
  }

  void changedDropDownItem(String selectedCity) {
    String sortingWith = '';
    setState(() {
      _currentItem = selectedCity;
      switch (_currentItem) {
        case 'Novos':
          sortingWith = 'updated_at+asc';
          break;
        case 'Média de avaliação dos compradore':
          sortingWith = 'avg_rating+desc ';
          break;
        case 'Mais vistos':
          sortingWith = 'reviews_count+desc';
          break;
        case 'A até Z':
          sortingWith = 'name+asc';
          break;
        case 'Z até A':
          sortingWith = 'name+desc';
          break;
      }

      productsByBrand = [];
      currentPage = 1;
      this.sortBy = sortingWith;
      getBrandProducts(0);
    });
  }
}
