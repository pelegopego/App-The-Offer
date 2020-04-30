import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:theoffer/models/Produto.dart';
import 'package:theoffer/scoped-models/main.dart';
import 'package:theoffer/screens/auth.dart';
import 'package:theoffer/screens/produtos.dart';
import 'package:theoffer/utils/connectivity_state.dart';
import 'package:theoffer/utils/constants.dart';
import 'package:theoffer/utils/drawer_homescreen.dart';
import 'package:theoffer/utils/locator.dart';
import 'package:theoffer/utils/imageHelper.dart';
import 'package:theoffer/models/banners.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:theoffer/models/categoria.dart';

class TelaCategorias extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TelaCategorias();
  }
}

class _TelaCategorias extends State<TelaCategorias> {
  final MainModel _model = MainModel();
  Size _deviceSize;
  Map<dynamic, dynamic> responseBody;
  bool _carregandoCategoria = true;
  List<Categoria> listaCategoria = [];
  List<Produto> listaProdutos = [];
  List<BannerImage> banners = [];
  List<String> bannerImageUrls = [];
  List<String> bannerLinks = [];
  int favCount;

  @override
  void initState() {
    super.initState();
    getCategorias();
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
      return Scaffold( 
        appBar: AppBar(
          title: Container(
              padding: EdgeInsets.all(10),
              child: Text(
                'TheOffer',
                textAlign: TextAlign.start,
                style: TextStyle(fontFamily: 'HolyFat', fontSize: 50, color:  Colors.principalTheOffer),
              )),
        iconTheme: new IconThemeData(color: Colors.principalTheOffer)
        ),
        drawer: HomeDrawer(),
        body: Container(
          color: Colors.secundariaTheOffer,
          child: CustomScrollView(slivers: [
            _carregandoCategoria
                ? SliverList(
                    delegate: SliverChildListDelegate([
                    Container(
                      height: _deviceSize.height * 0.5,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.secundariaTheOffer,
                      ),
                    )
                  ]))
                : listaCategoria.length > 0
                    ? SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2),
                        delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                          return cardCategoria(
                              index, context, _deviceSize, listaCategoria);
                        }, childCount: listaCategoria.length),
                      )
                    : SliverList(
                        delegate: SliverChildListDelegate([
                          Container(
                            width: _deviceSize.width,
                            color: Colors.white,
                            child: Center(
                              child: Text('Sem categorias.'),
                            ),
                          ),
                        ]),
                      ),
          ]),
        ),  
      );
    });
  }

Widget cardCategoria(int index, BuildContext context, Size _deviceSize,
    List<Categoria> listaCategoria) {
  if (index == 0) {
    return GestureDetector(
        onTap: () {
          MaterialPageRoute route =
              MaterialPageRoute(builder: (context) => TelaProdutos(idCategoria: 0));
          Navigator.push(context, route);
        },
        child: Container(
            margin: EdgeInsets.all(5.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),  
              border: Border.all(
                color: Colors.principalTheOffer, 
                width: 1,
              ),
              color: Colors.secundariaTheOffer,
            ),
            child: Stack(children: [
              Container(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('Tudo',
                            style: TextStyle(
                                color: Colors.principalTheOffer,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                        ]),
                  )),
            ])));
  }
  return GestureDetector(
      onTap: () {
        MaterialPageRoute route = MaterialPageRoute(
            builder: (context) => TelaProdutos(idCategoria: listaCategoria[index].id));
        Navigator.push(context, route);
      },
      child: Container(
          margin: EdgeInsets.all(5.0),
          width: _deviceSize.width * 0.4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: Colors.principalTheOffer, 
              width: 1,
            ),
            color: Colors.secundariaTheOffer,
          ),
          child: Stack(children: [
            Container(
                alignment: Alignment.bottomRight,
                 child: FadeInImage(
                    image: MemoryImage(dataFromBase64String(listaCategoria[index].imagem)),
                    placeholder: AssetImage(
                        'images/placeholders/no-product-image.png'),
                    ),
                  ),
            Container(
              padding: EdgeInsets.only(left: 10, top: 10),
              child: Text(
                listaCategoria[index].nome,
                style: TextStyle(
                    color: Colors.principalTheOffer,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ])));
}

  getCategorias() async {
    http.get(Configuracoes.BASE_URL + 'categorias/').then((response) {
    String imagemJson = ''; 
    setState(() {
      _carregandoCategoria = true;
      listaProdutos = [];
    });
      responseBody = json.decode(response.body);
      responseBody['categorias'].forEach((categoriaJson) {
      imagemJson = categoriaJson['imagem'].replaceAll('\/', '/');
      imagemJson = imagemJson.substring(imagemJson.indexOf('base64,') + 7, imagemJson.length);
          setState(() { 
            listaCategoria.add(Categoria(
              id    : int.parse(categoriaJson['id']),
              nome  : categoriaJson['nome'],
              imagem: imagemJson
            ));
          });
        }
      );
      setState(() {
        _carregandoCategoria = false;
      });
    });

  }

}
