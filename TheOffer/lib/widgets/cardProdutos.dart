import 'package:theoffer/screens/sabores.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:theoffer/models/Produto.dart';
import 'package:theoffer/models/ProdutoEmpresa.dart';
import 'package:theoffer/screens/empresaDetalhada.dart';
import 'package:theoffer/models/EmpresaDetalhada.dart';
import 'package:theoffer/scoped-models/main.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:theoffer/utils/constants.dart';
import 'package:theoffer/screens/autenticacao.dart';
import 'package:theoffer/utils/Hora.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:theoffer/utils/headers.dart';

class AddToCarrinho extends StatefulWidget {
  final List<Produto> todaysDealProducts;
  final int index;
  final Produto produto;
  AddToCarrinho(this.produto, this.index, this.todaysDealProducts);
  @override
  State<StatefulWidget> createState() {
    return _AddToCarrinhoState();
  }
}

class _AddToCarrinhoState extends State<AddToCarrinho> {
  getBloqueio() {
    if (Autenticacao.codigoUsuario > 0) {
      if (Autenticacao.dataBloqueio == null ||
          Autenticacao.dataBloqueio.isBefore(DateTime.now())) {
        Map<String, String> headers = getHeaders();
        Map<dynamic, dynamic> oMapSalvarNotificacao = {
          'usuario': Autenticacao.codigoUsuario.toString()
        };
        http
            .post(Configuracoes.BASE_URL + 'usuario/getBloqueio/',
                headers: headers, body: oMapSalvarNotificacao)
            .then((response) {
          setState(() {
            if (json.decode(response.body)[0]['dataBloqueio'] != null) {
              Autenticacao.dataBloqueio =
                  DateTime.parse(json.decode(response.body)[0]['dataBloqueio']);
            }

            if (Autenticacao.dataBloqueio == null ||
                Autenticacao.dataBloqueio.isBefore(DateTime.now())) {
              Autenticacao.bloqueado = false;
            } else {
              Autenticacao.bloqueado = true;
            }
          });
        });
      } else {
        Autenticacao.bloqueado = true;
      }
    } else {
      Autenticacao.bloqueado = false;
    }
  }

  int selectedIndex;
  int horaAtual =
      (DateTime.now().toLocal().hour * 60) + (DateTime.now().toLocal().minute);
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return RawMaterialButton(
        constraints: BoxConstraints(),
        padding: EdgeInsets.all(5.0),
        onPressed: getHoraInicioProdutoHoje(widget.produto) < horaAtual &&
                getHoraFimProdutoHoje(widget.produto) > horaAtual &&
                widget.produto.quantidadeRestante > 0 &&
                !Autenticacao.bloqueado &&
                (widget.produto.dataInicial == '' ||
                    widget.produto.dataInicial == null ||
                    !(DateTime.parse(widget.produto.dataInicial)
                        .isAfter(DateTime.now().toLocal())))
            ? () async {
                print('selectedProductIndex');
                print(widget.index);
                setState(() {
                  selectedIndex = widget.index;
                });
                if (getHoraInicioProdutoHoje(widget.produto) < horaAtual &&
                    getHoraFimProdutoHoje(widget.produto) > horaAtual &&
                    widget.produto.quantidadeRestante > 0 &&
                    (widget.produto.dataInicial == '' ||
                        widget.produto.dataInicial == null ||
                        !(DateTime.parse(widget.produto.dataInicial)
                            .isAfter(DateTime.now().toLocal())))) {
                  if (Autenticacao.codigoUsuario > 0 &&
                      !Autenticacao.bloqueado) {
                    setState(() {
                      if (widget.produto.possuiSabores) {
                        MaterialPageRoute pagamentoRoute = MaterialPageRoute(
                            builder: (context) =>
                                TelaSabores(widget.produto.id, 1));
                        Navigator.push(context, pagamentoRoute);
                      } else {
                        getBloqueio();
                        model.pegarCupom(
                            usuarioId: Autenticacao.codigoUsuario,
                            produtoId: widget.produto.id,
                            context: context);
                      }
                    });
                  } else {
                    MaterialPageRoute authRoute = MaterialPageRoute(
                        builder: (context) => Authentication(0));
                    Navigator.push(context, authRoute);
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
  int horaAtual =
      (DateTime.now().toLocal().hour * 60) + (DateTime.now().toLocal().minute);
  return Text(
    Autenticacao.bloqueado
        ? 'USUÁRIO BLOQUEADO'
        : produto.dataInicial != '' &&
                produto.dataInicial != null &&
                (DateTime.parse(produto.dataInicial)
                    .isAfter(DateTime.now().toLocal()))
            ? 'EM BREVE'
            : getHoraInicioProdutoHoje(produto) < horaAtual &&
                    getHoraFimProdutoHoje(produto) > horaAtual
                ? produto.quantidadeRestante > 0
                    ? 'ADQUIRIR CUPOM'
                    : 'FORA DE ESTOQUE'
                : 'ESTABELECIMENTO FECHADO',
    /*
        ? produto.quantidadeRestante > 0
            ? 'ADICIONAR AO CARRINHO'
            : 'FORA DE ESTOQUE'
        : 'ESTABELECIMENTO FECHADO',*/
    style: TextStyle(
        color: getHoraInicioProdutoHoje(produto) < horaAtual &&
                getHoraFimProdutoHoje(produto) > horaAtual &&
                produto.quantidadeRestante > 0 &&
                !Autenticacao.bloqueado &&
                (produto.dataInicial == '' ||
                    produto.dataInicial == null ||
                    !(DateTime.parse(produto.dataInicial)
                        .isAfter(DateTime.now().toLocal())))
            ? Colors.principalTheOffer
            : Colors.grey,
        fontSize: 12,
        fontWeight: FontWeight.w500),
  );
}

Widget cardProdutosEmpresa(int index, List<ProdutoEmpresa> listaProdutoEmpresa,
    Size _deviceSize, BuildContext context) {
  return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
    return GestureDetector(
        onTap: () {
          MaterialPageRoute route = MaterialPageRoute(
              builder: (context) => TelaEmpresaDetalhada(
                  idCategoria: 0,
                  idEmpresa: listaProdutoEmpresa[index].empresaId));
          Navigator.push(context, route);
        },
        child: SizedBox(
            width: _deviceSize.width * 0.4,
            child: Column(children: <Widget>[
              Container(
                  width: _deviceSize.width,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.business,
                          color: Colors.secundariaTheOffer,
                        ),
                        SizedBox(
                          width: 8.0,
                        ),
                        Text(
                            listaProdutoEmpresa[index]
                                    .fantasia[0]
                                    .toUpperCase() +
                                listaProdutoEmpresa[index]
                                    .fantasia
                                    .toLowerCase()
                                    .substring(1),
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.secundariaTheOffer)),
                      ],
                    ),
                  )),
              Container(
                height: 260,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: listaProdutoEmpresa[index].listaProduto.length,
                    itemBuilder: (context, index2) {
                      if (listaProdutoEmpresa[index].listaProduto.length > 0) {
                        return Container(
                            child: cardProdutos(
                                index2,
                                listaProdutoEmpresa[index].listaProduto,
                                _deviceSize,
                                context));
                      } else {
                        return Container();
                      }
                    }),
              ),
              Divider(
                height: 5,
              ),
            ])));
  });
}

Widget cardProdutosCategoria(
    int index,
    List<CategoriaDetalhada> listaProdutoCategoria,
    Size _deviceSize,
    BuildContext context) {
  return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
    return GestureDetector(
        child: SizedBox(
            width: _deviceSize.width * 0.4,
            child: Column(children: <Widget>[
              Container(
                  width: _deviceSize.width,
                  child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.bookmark_border,
                          color: Colors.secundariaTheOffer,
                        ),
                        SizedBox(
                          width: 8.0,
                        ),
                        Text(
                            listaProdutoCategoria[index].nome[0].toUpperCase() +
                                listaProdutoCategoria[index]
                                    .nome
                                    .toLowerCase()
                                    .substring(1),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.secundariaTheOffer)),
                      ],
                    ),
                  )),
              Container(
                height: 290,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: listaProdutoCategoria[index].listaProduto.length,
                    itemBuilder: (context, index2) {
                      if (listaProdutoCategoria[index].listaProduto.length >
                          0) {
                        return Container(
                            child: cardProdutos(
                                index2,
                                listaProdutoCategoria[index].listaProduto,
                                _deviceSize,
                                context));
                      } else {
                        return Container();
                      }
                    }),
              ),
              Divider(
                height: 5,
              ),
            ])));
  });
}

Widget cardProdutos(int index, List<Produto> listaProdutos, Size _deviceSize,
    BuildContext context) {
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
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(5)),
                    margin: EdgeInsets.all(5),
                    child: produtoDetalhado.imagem != null
                        ? CachedNetworkImage(imageUrl: produtoDetalhado.imagem)
                        : Container(),
                    height: 140,
                    width: 140,
                  ),
                  Container(
                    width: double.infinity,
                    height: 30,
                    padding: EdgeInsets.only(left: 12.0, right: 12.0),
                    child: Text(
                      produtoDetalhado.titulo[0].toUpperCase() +
                          produtoDetalhado.titulo.toLowerCase().substring(1),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                      style: TextStyle(color: Colors.principalTheOffer),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12.0, top: 5.0),
                      child: Text(
                        produtoDetalhado.valor.toString(),
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.principalTheOffer),
                      ),
                    ),
                  ),
                  Divider(
                    height: 1.0,
                    color: Colors.principalTheOffer,
                  ),
                  AddToCarrinho(produtoDetalhado, index, listaProdutos),
                ],
              ),
            )));
  });
}
