import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:theoffer/models/Produto.dart';
import 'package:theoffer/scoped-models/main.dart';
import 'package:theoffer/widgets/rating_bar.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:theoffer/widgets/snackbar.dart';
import 'package:theoffer/utils/ImageHelper.dart';

class AddToCart extends StatefulWidget {
  List<Produto> todaysDealProducts;
  int index;
  Produto produto;
  AddToCart(this.produto, this.index, this.todaysDealProducts);
  @override
  State<StatefulWidget> createState() {
    return _AddToCartState();
  }
}

class _AddToCartState extends State<AddToCart> {
  int selectedIndex;
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return FlatButton (
        onPressed: widget.produto.quantidade > 0
            ? () async {
                print('selectedProductIndex');
                print(widget.index);
                setState(() {
                  selectedIndex = widget.index;
                });
                if (widget.produto.quantidade > 0) {
                  Scaffold.of(context).showSnackBar(processSnackbar);
                  model.adicionarProduto(
                           usuarioId: 1,//user 
                           produtoId: widget.produto.id, 
                           quantidade: 1);
                  if (!model.isLoading) {
                    Scaffold.of(context).showSnackBar(completeSnackbar);
                  }
                }
              }
            : () {},
        child: !model.isLoading
            ? buttonContent(widget.index, widget.produto)
            : widget.index == selectedIndex
                ? Center(
                    child: CircularProgressIndicator(
                    backgroundColor: Colors.principalTheOffer,
                  ))
                : buttonContent(widget.index, widget.produto),
      );
    });
  }
}

Widget buttonContent(int index, Produto produto) {
  return Text(
    produto.quantidade > 0 ? 'ADICIONAR AO CARRINHO' : 'FORA DE ESTOQUE',
    style: TextStyle(
        color: Colors.principalTheOffer,
        fontSize: 14,
        fontWeight: FontWeight.w500),
  );
}

Widget cardProdutos(int index, List<Produto> listaProdutos,
    Size _deviceSize, BuildContext context) {
  Produto produtoDetalhado = listaProdutos[index];
  return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
    return GestureDetector(
        onTap: () {
          model.getProdutoDetalhe(listaProdutos[index].id, context);
        },
        child: SizedBox(
            width: _deviceSize.width * 0.4,
            child: Card(
              color: Colors.secundariaTheOffer, 
              shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.withOpacity(0.4)),
                  borderRadius: BorderRadius.circular(4.0)),
              child: Column(
                children: <Widget>[
                  Container(
                    child: FadeInImage(
                      image: MemoryImage(dataFromBase64String(produtoDetalhado.imagem)),
                      placeholder: AssetImage(
                          'images/placeholders/no-product-image.png'),
                      height: 140,
                      width: 140,
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 30,
                    padding: EdgeInsets.only(left: 12.0, right: 12.0),
                    child: Text(
                      produtoDetalhado.titulo,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3, 
                      style: TextStyle(color: Colors.principalTheOffer),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12.0, top: 10.0),
                      child: Text(
                        produtoDetalhado.valor.toString(),
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15, color: Colors.principalTheOffer),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 12.0, top: 5.0, bottom: 5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        ratingBar(5, 20),
                        Text('10',  
                             style: TextStyle(color: Colors.principalTheOffer)),
                      ],
                    ),
                  ),
                  Divider(
                    height: 1.0,
                    color: Colors.principalTheOffer,
                  ),
                  AddToCart(produtoDetalhado, index, listaProdutos),
                ],
              ),
            )));
  });
}