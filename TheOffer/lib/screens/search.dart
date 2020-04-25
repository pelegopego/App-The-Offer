import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:theoffer/models/brand.dart';
import 'package:theoffer/models/category.dart';
import 'package:theoffer/models/Produto.dart';
import 'package:theoffer/scoped-models/main.dart';
import 'package:theoffer/utils/connectivity_state.dart';
import 'package:theoffer/utils/constants.dart';
import 'package:theoffer/utils/headers.dart';
import 'package:theoffer/utils/locator.dart';
import 'package:theoffer/widgets/product_container.dart';
import 'package:scoped_model/scoped_model.dart';

class ProductSearch extends StatefulWidget {
  final String slug;
  ProductSearch({this.slug});
  @override
  State<StatefulWidget> createState() {
    return _ProductSearchState();
  }
}

class _ProductSearchState extends State<ProductSearch> {
  String slug = '';
  TextEditingController _controller = TextEditingController();
  // List<SearchProduct> searchProducts = [];
  List<Produto> listaProdutosPesquisa = [];
  bool _isLoading = false;
  Produto produtoSelecionado = Produto();
  final int perPage = TWENTY;
  int currentPage = ONE;
  int subCatId = ZERO;
  bool isSearched = false;
  Size _deviceSize;
  int totalCount = 0;
  static const int PAGE_SIZE = 20;
  final scrollController = ScrollController();
  bool hasMore = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<Category> _listViewData = [];
  List<DropdownMenuItem<String>> _dropDownMenuItems;
  String _currentItem;
  Map<dynamic, dynamic> responseBody;
  List<Brand> brands = [];
  List<Produto> produtosPorMarca = [];
  String sortBy = '';
  List filterItems = [
    "Newest",
    "Avg.Customer Review",
    "Most Reviews",
    "A TO Z",
    "Z TO A"
  ];
  List<DropdownMenuItem<String>> getDropDownMenuItems() {
    List<DropdownMenuItem<String>> items = new List();
    for (String city in filterItems) {
      items.add(new DropdownMenuItem(
        value: city,
        child: Text(
          city,
        ),
      ));
    }
    return items;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    sortBy = '';
    _dropDownMenuItems = getDropDownMenuItems();
    _currentItem = _dropDownMenuItems[0].value;
    if (widget.slug != null) {
      print("SLUG AVAILABLE ${widget.slug}");
      setState(() {
        slug = widget.slug;
        isSearched = true;
        listaProdutosPesquisa = [];
        currentPage = 1;
      });
      pesquisarProduto();
    }
    scrollController.addListener(() {
      if (scrollController.offset >=
              scrollController.position.maxScrollExtent &&
          !scrollController.position.outOfRange) {
        pesquisarProduto();
      }
    });
    getBrandsList();
    locator<ConnectivityManager>().initConnectivity(context);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    locator<ConnectivityManager>().dispose();
  }

  @override
  Widget build(BuildContext mainContext) {
    _deviceSize = MediaQuery.of(mainContext).size;
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            elevation: 1.0,
            backgroundColor: Colors.principalTheOffer,
            leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.pop(context);
                }),
            title: Container(
              padding: EdgeInsets.only(left: 15),
              child: TextField(
                controller: _controller,
                onChanged: (value) {
                  setState(() {
                    slug = value;
                  });
                },
                onSubmitted: (value) {
                  isSearched = true;
                  listaProdutosPesquisa = [];
                  currentPage = 1;
                  pesquisarProduto();
                  // print("ENTER PRESSED ------> $value");
                },
                autofocus: true,
                decoration: InputDecoration(
                    hintText: 'Search',
                    border: InputBorder.none,
                    labelStyle:
                        TextStyle(fontWeight: FontWeight.w300, fontSize: 18)),
              ),
            ),
            actions: <Widget>[
              Visibility(
                visible: slug != null && slug.isNotEmpty,
                child: IconButton(
                  icon: const Icon(
                    Icons.clear,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _controller.clear();
                      slug = '';
                      setState(() {
                        listaProdutosPesquisa.clear();
                      });
                    });
                  },
                ),
              ),
            ],
          ),
          endDrawer: filterDrawer(),
          body: Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 90.0),
                child: isSearched && !model.isLoading
                    ? Theme(
                        data: ThemeData(primarySwatch: Colors.secundariaTheOffer),
                        child: ListView.builder(
                            controller: scrollController,
                            itemCount: listaProdutosPesquisa.length + 1,
                            itemBuilder: (mainContext, index) {
                              if (index < listaProdutosPesquisa.length) {
                                return productContainer(
                                    _scaffoldKey.currentContext,
                                    listaProdutosPesquisa[index],
                                    index);
                              }
                              if (hasMore && listaProdutosPesquisa.length == 0) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 50.0),
                                  child: Center(
                                    child: Text(
                                      'No Product Found',
                                      style: TextStyle(fontSize: 20.0),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                );
                              }
                              if (!hasMore || model.isLoading) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 25.0),
                                  child: Center(
                                      child: CircularProgressIndicator(
                                    backgroundColor: Colors.principalTheOffer,
                                  )),
                                );
                              } else {
                                return Container();
                              }
                            }),
                      )
                    : Container(),
              ),
              Visibility(
                  visible: listaProdutosPesquisa.length > 0,
                  child: Material(
                    elevation: 2.0,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      color: Colors.principalTheOffer,
                      height: 50.0,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 18.0, left: 16.0),
                        child: Text(
                          '$totalCount Results',
                          textAlign: TextAlign.left,
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ),
                    ),
                  )),
              Visibility(
                visible: listaProdutosPesquisa.length > 0,
                child: Container(
                  padding: EdgeInsets.only(right: 20.0, top: 20.0),
                  alignment: Alignment.topRight,
                  child: FloatingActionButton(
                    onPressed: () {
                      _scaffoldKey.currentState.openEndDrawer();
                    },
                    child: Icon(
                      Icons.filter_list,
                      color: Colors.principalTheOffer,
                    ),
                    backgroundColor: Colors.orange,
                  ),
                ),
              ),
              Visibility(
                  visible: model.isLoading,
                  child: Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.secundariaTheOffer,
                    ),
                  )),
              // )
            ],
          ));
    });
  }

  Future<List<Produto>> pesquisarProduto() async {
    Map<String, String> headers = await getHeaders();
    Map<String, dynamic> responseBody = Map();
    print('SENDING REQUEST $slug');
    setState(() {
      hasMore = false;
    });
    print(Settings.SERVER_URL +
        'api/v1/products?q[name_cont_all]=$slug&page=$currentPage&per_page=$perPage&q[s]=$sortBy&data_set=small');
    http.Response response;
    if (sortBy != null) {
      response = await http.get(
          Settings.SERVER_URL +
              'api/v1/products?q[name_cont_all]=$slug&page=$currentPage&per_page=$perPage&q[s]=$sortBy&data_set=small',
          headers: headers);
    } else {
      print("searching $slug");
      response = await http.get(
          Settings.SERVER_URL +
              'api/v1/products?q[name_cont_all]=$slug&page=$currentPage&per_page=$perPage&data_set=small',
          headers: headers);
    }
    currentPage++;
    responseBody = json.decode(response.body);
    responseBody['data'].forEach((searchObj) {
      listaProdutosPesquisa.add(Produto(
        id                    : int.parse(searchObj['data']['included']['id']),
        titulo                : searchObj['data']['attributes']['titulo'],
        descricao             : searchObj['data']['attributes']['descricao'],
        imagem                : searchObj['data']['attributes']['imagem'],
        valor                 : searchObj['data']['attributes']['valor'],
        quantidade            : int.parse(searchObj['data']['attributes']['quantidade']),
        dataInicial           : searchObj['data']['attributes']['dataInicial'],
        dataFinal             : searchObj['data']['attributes']['dataFinal'],
        dataCadastro          : searchObj['data']['attributes']['dataCadastro'],
        modalidadeRecebimento1: int.parse(searchObj['data']['attributes']['modalidadeRecebimento1']),
        modalidadeRecebimento2: int.parse(searchObj['data']['attributes']['modalidadeRecebimento2']),
        usuarioId             : int.parse(searchObj['data']['attributes']['usuario_id'])));
      });
    totalCount = responseBody['pagination']['total_count'];
    setState(() {
      hasMore = true;
      _isLoading = false;
    });

    print(hasMore);
    print(listaProdutosPesquisa.length);

    return listaProdutosPesquisa;
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
                        'Sort By:  ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.principalTheOffer,
                            fontSize: 18.0),
                      ),
                      DropdownButton(
                        underline: Container(),
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 15.0,
                            fontWeight: FontWeight.normal),
                        hint: Text(
                          _currentItem,
                          style: TextStyle(
                              color: Colors.principalTheOffer,
                              fontWeight: FontWeight.bold),
                        ),
                        value: null,
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: Colors.principalTheOffer,
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
                data: ThemeData(primarySwatch: Colors.secundariaTheOffer),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.all(8.0),
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          produtosPorMarca = [];
                          setState(() {
                            _isLoading = true;
                            slug = brands[index].name;
                            isSearched = true;
                            listaProdutosPesquisa = [];
                            currentPage = 1;
                            pesquisarProduto();
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
    });
  }

  void changedDropDownItem(String selectedCity) {
    String sortingWith = '';
    setState(() {
      _currentItem = selectedCity;
      switch (_currentItem) {
        case 'Newest':
          sortingWith = 'updated_at+asc';
          break;
        case 'Avg.Customer Review':
          sortingWith = 'avg_rating+desc ';
          break;
        case 'Most Reviews':
          sortingWith = 'reviews_count+desc';
          break;
        case 'A TO Z':
          sortingWith = 'name+asc';
          break;
        case 'Z TO A':
          sortingWith = 'name+desc';
          break;
      }
      isSearched = true;
      listaProdutosPesquisa = [];
      currentPage = 1;
      this.sortBy = sortingWith;
      pesquisarProduto();
    });
  }
}
