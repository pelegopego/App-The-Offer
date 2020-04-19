import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:theoffer/models/category.dart';
import 'package:theoffer/models/option_type.dart';
import 'package:theoffer/models/option_value.dart';
import 'package:theoffer/models/product.dart';
import 'package:theoffer/scoped-models/main.dart';
import 'package:theoffer/screens/auth.dart';
import 'package:theoffer/screens/search.dart';
import 'package:theoffer/utils/connectivity_state.dart';
import 'package:theoffer/utils/constants.dart';
import 'package:theoffer/utils/drawer_homescreen.dart';
import 'package:theoffer/utils/locator.dart';
import 'package:theoffer/widgets/shopping_cart_button.dart';
import 'package:theoffer/widgets/todays_deals_card.dart';
import 'package:theoffer/models/banners.dart';
import 'package:scoped_model/scoped_model.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Hometelastate();
  }
}

class _Hometelastate extends State<HomeScreen> {
  final MainModel _model = MainModel();
  Size _deviceSize;
  Map<dynamic, dynamic> responseBody;
  bool _isBannerLoading = true;
  bool _isCategoryLoading = true;
  bool _isDealsLoading = true;
  bool _isAuthenticated = false;
  List<Product> todaysDealProducts = [];
  List<Category> categories = [];
  List<BannerImage> banners = [];
  List<String> bannerImageUrls = [];
  List<String> bannerLinks = [];
  int favCount;

  @override
  void initState() {
    super.initState();
    // getFavoritesCount();
    getBanners();
    getCategories();
    getTodaysDeals();
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
    List<Widget> actions = [];

    for (int i = 0; i < banners.length; i++) {
      actions.add(bannerCards(i));
    }

    Widget bannerCarousel = CarouselSlider(
      items: _isBannerLoading ? [bannerCards(0)] : actions,
      autoPlay: true,
      enlargeCenterPage: true,
    );
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold( 
        appBar: AppBar(
          title: Container(
              padding: EdgeInsets.all(10),
              child: Text(
                'TheOffer',
                textAlign: TextAlign.start,
                style: TextStyle(fontFamily: 'HolyFat', fontSize: 50, color:  Colors.principalTheOffer),
              )),
          actions: <Widget>[
            shoppingCartIconButton(),
          ],
          bottom: PreferredSize(
            preferredSize: Size(_deviceSize.width, 70),
            child: searchBar(),
          ),
        iconTheme: new IconThemeData(color: Colors.principalTheOffer)
        ),
        drawer: HomeDrawer(),
        body: Container(
          color: Colors.terciariaTheOffer,
          child: CustomScrollView(slivers: [
            SliverList(
              delegate: SliverChildListDelegate([
                Container(
                    color: Colors.grey.withOpacity(0.1), child: bannerCarousel)
              ]),
            ),
            SliverToBoxAdapter(
              child: Divider(
                height: 1.0,
              ),
            ),
            _isDealsLoading
                ? SliverList(
                    delegate: SliverChildListDelegate([
                    Container(
                      height: _deviceSize.height * 0.47,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.secundariaTheOffer,
                      ),
                    )
                  ]))
                : SliverToBoxAdapter(
                    child: Container(
                      height: 355,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: todaysDealProducts.length,
                        itemBuilder: (context, index) {
                          return todaysDealsCard(
                              index, todaysDealProducts, _deviceSize, context);
                        },
                      ),
                    ),
                  ),
            SliverToBoxAdapter(
              child: Divider(),
            ),
          ]),
        ),
        bottomNavigationBar:
            !model.isAuthenticated ? bottomNavigationBar() : null,
      );
    });
  }

  Widget bottomNavigationBar() {
    return BottomNavigationBar(
      backgroundColor: Colors.secundariaTheOffer,
      onTap: (index) {
        MaterialPageRoute route =
            MaterialPageRoute(builder: (context) => Authentication(index));

        Navigator.push(context, route);
      },
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline, color: Colors.principalTheOffer),
          title: Text('ENTRAR',
              style: TextStyle(
                    color: Colors.principalTheOffer,
                    fontSize: 15,
                    fontWeight: FontWeight.w600))),
        BottomNavigationBarItem(
            icon: Icon(
              Icons.person_outline,
              color: Colors.principalTheOffer,
            ),
            title: Text('CRIAR CONTA',
                style: TextStyle(
                    color: Colors.principalTheOffer,
                    fontSize: 15,
                    fontWeight: FontWeight.w600))),
      ],
    );
  }

  Widget bannerCards(int index) {
    if (_isBannerLoading) {
      return Container(
        width: _deviceSize.width * 0.8,
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          elevation: 2,
          margin: EdgeInsets.symmetric(
              vertical: _deviceSize.height * 0.05,
              horizontal: _deviceSize.width * 0.02),
          child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              child: Image.asset(
                'images/placeholders/slider1.jpg',
                fit: BoxFit.fill,
              )),
        ),
      );
    } else {
      return GestureDetector(
          onTap: () {
            MaterialPageRoute route = MaterialPageRoute(
                builder: (context) => ProductSearch(
                      // slug: bannerLinks[index],
                      slug: banners[index].imageSlug,
                    ));
            Navigator.of(context).push(route);
          },
          child: Container(
            width: _deviceSize.width * 0.8,
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
              elevation: 2,
              margin: EdgeInsets.symmetric(
                  vertical: _deviceSize.height * 0.05,
                  horizontal: _deviceSize.width * 0.02),
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(4)),
                child: FadeInImage(
                  image: NetworkImage(banners[index].imageUrl != null
                      ? banners[index].imageUrl
                      : ''),
                  placeholder: AssetImage('images/placeholders/slider1.jpg'),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ));
    }
  }

  getCategories() async {
    int petsId;
    http.Response response = await http
        .get(Settings.SERVER_URL + 'api/v1/taxonomies?q[name_cont]=Pets');
    responseBody = json.decode(response.body);
    petsId = responseBody['taxonomies'][0]['id'];
    http
        .get(Settings.SERVER_URL +
            'api/v1/taxonomies?q[name_cont]=Pets&set=nested')
        .then((response) {
      responseBody = json.decode(response.body);
      responseBody['taxonomies'][0]['root']['taxons'].forEach((category) {
        setState(() {
          categories.add(Category(
              parentId: petsId,
              name: category['name'],
              image: category['icon'],
              id: category['id']));
        });
      });
      setState(() {
        _isCategoryLoading = false;
      });
    });
  }

  getTodaysDeals() async {
    String todaysDealsId;
    http.Response response = await http.get(
        Settings.SERVER_URL + 'api/v1/taxonomies?q[name_cont]=Today\'s Deals');
    responseBody = json.decode(response.body);
    todaysDealsId = responseBody['taxonomies'][0]['id'].toString();
    List<Product> variants = [];
    List<OptionValue> optionValues = [];
    List<OptionType> optionTypes = [];
    setState(() {
      _isDealsLoading = true;
      todaysDealProducts = [];
    });
    http
        .get(Settings.SERVER_URL +
            'api/v1/taxons/products?id=$todaysDealsId&per_page=20&data_set=small')
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
                  slug: variant['slug'],
                  description: variant['description'],
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
            todaysDealProducts.add(Product(
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
            todaysDealProducts.add(Product(
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
        _isDealsLoading = false;
      });
    });
  }

  Widget searchBar() {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return GestureDetector(
          onTap: () {
            MaterialPageRoute route =
                MaterialPageRoute(builder: (context) => ProductSearch());
            Navigator.of(context).push(route);
          },
          child: Column(children: [
            Container(
              decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5)),
              width: _deviceSize.width,
              height: 49,
              margin: EdgeInsets.all(010),
              child: ListTile(
                leading: Icon(Icons.search, color: Colors.secundariaTheOffer),
                title: Text(
                  'Encontrar produtos...',
                  style: TextStyle(fontWeight: FontWeight.w300, color: Colors.secundariaTheOffer),
                ),
              ),
            ),
            model.isLoading ? LinearProgressIndicator() : Container()
          ]));
    });
  }

  getBanners() async {
    http
        .get(Settings.SERVER_URL +
            'api/v1/taxonomies?q[name_cont]=Landing_Banner&set=nested')
        .then((response) {
      responseBody = json.decode(response.body);
      responseBody['taxonomies'][0]['root']['taxons'].forEach((banner) {
        setState(() {
          banners.add(BannerImage(
              imageSlug: banner['meta_title'], imageUrl: banner['icon']));
          bannerImageUrls.add(banner['icon']);
          bannerLinks.add(banner['meta_title']); //  meta_title
        });
      });
      setState(() {
        _isBannerLoading = false;
      });
    });
  }
}
