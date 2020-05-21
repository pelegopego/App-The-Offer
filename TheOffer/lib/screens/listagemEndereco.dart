import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:theoffer/scoped-models/main.dart';
import 'package:theoffer/screens/finalizarPedido.dart';
import 'package:theoffer/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:theoffer/utils/connectivity_state.dart';
import 'package:theoffer/utils/locator.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:theoffer/models/endereco.dart';
import 'package:theoffer/models/cidade.dart';
import 'package:theoffer/screens/cadastroEndereco.dart';
import 'package:theoffer/models/bairro.dart';

class ListagemEndereco extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ListagemEnderecoState();
  }
}

class _ListagemEnderecoState extends State<ListagemEndereco> {
  bool _enderecosLoading = true;
  List<Endereco> listaEnderecos = [];
  @override
  void initState() {
    super.initState();
    getEnderecos();
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
                icon: Icon(Icons.arrow_back_ios, color: Colors.principalTheOffer),
                onPressed: () => Navigator.pop(context)
              ),
              title: Text('Endereços', style: TextStyle(color: Colors.principalTheOffer),),
              bottom: _enderecosLoading
                  ? PreferredSize(
                      child: LinearProgressIndicator(),
                      preferredSize: Size.fromHeight(10),
                    )
                  : PreferredSize(
                      child: Container(),
                      preferredSize: Size.fromHeight(10),
                    )),
          body: !_enderecosLoading || listaEnderecos != null 
                ? Container(
                    child: body()
                  ) 
                : Container(),
          );
    });
  }
/*
  Widget botaoDeletar(int index) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Text(model.pedido.listaItensPedido[index].produto.quantidade.toString());
    });
  }
*/
  Widget body() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return CustomScrollView(
            shrinkWrap: true,
          slivers: <Widget>[
                SliverToBoxAdapter(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.865, 
                    child:  CustomScrollView(
                        slivers: <Widget>[
                          items(),
                        ],
                    )
                  )
            )
          ]
        );
      }
    );
  }

  Widget items() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return SliverList(
          delegate:
              SliverChildBuilderDelegate((BuildContext context, int index) {
            return GestureDetector(              
              onTap: () {
                alterarEnderecoPedido(model.pedido.id, Autenticacao.CodigoUsuario, listaEnderecos[index].id);
                model.pedido.endereco.id              = listaEnderecos[index].id;
                model.pedido.endereco.nome            = listaEnderecos[index].nome;
                model.pedido.endereco.usuarioId       = listaEnderecos[index].usuarioId;
                model.pedido.endereco.cidade.id       = listaEnderecos[index].cidade.id;
                model.pedido.endereco.cidade.nome     = listaEnderecos[index].cidade.nome;
                model.pedido.endereco.bairro.id       = listaEnderecos[index].id;
                model.pedido.endereco.bairro.nome     = listaEnderecos[index].nome;
                model.pedido.endereco.rua             = listaEnderecos[index].rua;
                model.pedido.endereco.numero          = listaEnderecos[index].numero;
                model.pedido.endereco.complemento     = listaEnderecos[index].complemento;
                model.pedido.endereco.referencia      = listaEnderecos[index].referencia;
                model.pedido.endereco.dataCadastro    = listaEnderecos[index].dataCadastro;
                model.pedido.endereco.dataConfirmacao = listaEnderecos[index].dataConfirmacao;
                MaterialPageRoute route =
                      MaterialPageRoute(builder: (context) => TelaFinalizarPedido());

                Navigator.push(context, route);
              },
                child: _enderecosLoading
            ? Container()
            : index != listaEnderecos.length 
                ? Container (
                    color: Colors.terciariaTheOffer,
                    child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Card(
                      child: Container(
                        height: 90,
                        color: listaEnderecos[index].id == model.pedido.endereco.id 
                               ?Colors.principalTheOffer
                               :Colors.secundariaTheOffer,
                        child: GestureDetector(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
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
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Container(
                                          width: 250,
                                          child: RichText(
                                            text: TextSpan(
                                                text: listaEnderecos[index].nome,
                                                style: TextStyle(
                                                    color: listaEnderecos[index].id == model.pedido.endereco.id 
                                                           ?Colors.secundariaTheOffer
                                                           :Colors.principalTheOffer,
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Container(
                                                alignment: Alignment.centerRight,
                                                child: IconButton(
                                                  iconSize: 24,
                                                  color: listaEnderecos[index].id == model.pedido.endereco.id 
                                                         ?Colors.secundariaTheOffer
                                                         :Colors.principalTheOffer,
                                                  icon: Icon(Icons.close),
                                                  onPressed: () {
                                                    deletarEndereco(Autenticacao.CodigoUsuario,
                                                        listaEnderecos[index].id);
                                                  },
                                                ),
                                              ),
                                            ]
                                          )
                                        ), 
                                      ],
                                    ),
                                  ),
                                  Container(
                                    child: Row(
                                      children: <Widget>[
                                        Container(
                                          alignment: Alignment.topLeft,
                                          child: RichText(
                                              text: TextSpan(
                                                  text: listaEnderecos[index].rua  + ', ' + listaEnderecos[index].numero.toString(),
                                                  style: TextStyle(
                                                      color: listaEnderecos[index].id == model.pedido.endereco.id 
                                                             ?Colors.secundariaTheOffer
                                                             :Colors.principalTheOffer,
                                                      fontSize: 15.0
                                                  ),
                                              )
                                          ),
                                        ),
                                      ]
                                    )
                                  ),
                                  Container(
                                    child: Row(
                                      children: <Widget>[
                                        Container(
                                        alignment: Alignment.topLeft,
                                        child: RichText(
                                            text: TextSpan(
                                                text: listaEnderecos[index].cidade.nome + ', Bairro ' + listaEnderecos[index].bairro.nome,
                                                style: TextStyle(
                                                    color: listaEnderecos[index].id == model.pedido.endereco.id 
                                                           ?Colors.secundariaTheOffer
                                                           :Colors.principalTheOffer,
                                                    fontSize: 15.0, 
                                                    fontWeight: FontWeight.bold),
                                              ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                      ]
                                    )
                                  ),
                                ],
                              )),
                            ],
                          ),
                        ),
                      ),
                    )
                  ]
                  )
                )
              : Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.secundariaTheOffer,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                               iconSize: 24,
                               color: Colors.principalTheOffer,
                               icon: Icon(Icons.add),
                               onPressed: () {
                                    MaterialPageRoute route =
                                      MaterialPageRoute(builder: (context) => TelaCadastroEndereco(null));
 
                                    Navigator.push(context, route);
                               },
                             ),
                    )
          );
          }, childCount: listaEnderecos.length +1),
        );
      },
    );
  }
  
  void deletarEndereco(int usuarioId, int enderecoId) async {
    Map<dynamic, dynamic> objetoEndereco = Map();
    print("DELETANDO ENDERECO");
        objetoEndereco = {
          "usuario": usuarioId.toString(), "endereco": enderecoId.toString()
        };
    http.post(Configuracoes.BASE_URL + 'enderecos/deletar', body: objetoEndereco).then((response) {
      print("REMOVENDO PRODUTO DO CARRINHO _______");
      getEnderecos();
    });
  }

  getEnderecos() async {    
    List<Endereco> _listaEnderecos = [];
    Cidade cidade;
    Bairro bairro;
    Map<dynamic, dynamic> responseBody;
    Map<dynamic, dynamic> objetoEndereco = Map();

    setState(() {
      _enderecosLoading = true;
      listaEnderecos = [];
      _listaEnderecos = [];
    });

    objetoEndereco = {
          "usuario": Autenticacao.CodigoUsuario.toString(), "cidade": CidadeSelecionada.id.toString()
        };
    http.post(Configuracoes.BASE_URL + 'enderecos', body: objetoEndereco).then((response) {
      responseBody = json.decode(response.body);
      responseBody['enderecos'].forEach((enderecoJson) {
          setState(() { 
                cidade = Cidade(id:   int.parse(enderecoJson['cidade_id']),
                                nome: enderecoJson['nomeCidade']);

                bairro = Bairro(id:   int.parse(enderecoJson['bairro_id']),
                                nome: enderecoJson['nomeBairro']);

                _listaEnderecos.add(Endereco(
                  id:              int.parse(enderecoJson['id']),
                  nome:            enderecoJson['nome'],
                  cidade:          cidade,
                  bairro:          bairro,
                  rua:             enderecoJson['rua'],
                  numero:          int.parse(enderecoJson['numero']),
                  complemento:     enderecoJson['complemento'],
                  referencia:      enderecoJson['referencia'],
                  usuarioId:       int.parse(enderecoJson['usuario_id']),
                  dataCadastro:    DateTime.parse(enderecoJson['dataCadastro']),
                  dataConfirmacao: DateTime.parse(enderecoJson['dataConfirmacao'])
                ));
          });
        }
      );
      listaEnderecos = _listaEnderecos;
      setState(() {
        _enderecosLoading = false;
      });
    });
  }


  void alterarEnderecoPedido(int pedidoId, int usuarioId, int enderecoId) async {
    Map<dynamic, dynamic> objetoPedido = Map();
    Map<dynamic, dynamic> responseBody;
    print("ALTERANDO ENDERECO");
        objetoPedido = {
          "pedido": pedidoId.toString(), "usuario": Autenticacao.CodigoUsuario.toString(), "endereco": enderecoId.toString()
        };
    http
        .post(
            Configuracoes.BASE_URL + 'pedido/alterarEndereco/',
            body: objetoPedido)
        .then((response) {
      print("ALTERANDO ENDERECO");
      print(json.decode(response.body).toString());
      responseBody = json.decode(response.body);
      return responseBody['message'];  
    });
  }

/*
  void removerEndereco(int pedidoId, int usuarioId, int produtoId) async {
    Map<dynamic, dynamic> responseBody;
    print("REMOVENDO Endereco");
        objetoEndereco = {
          "pedido": pedidoId.toString(), "produto": produtoId.toString()
        };
    http
        .post(
            Configuracoes.BASE_URL + 'pedido/removerProdutoCarrinho/',
            body: objetoItemPedido)
        .then((response) {
      print("REMOVENDO PRODUTO DO CARRINHO _______");
      print(json.decode(response.body).toString());
      responseBody = json.decode(response.body);
      localizarCarrinho(null, usuarioId);
      return responseBody['message'];  
    });
  }
*/
}
