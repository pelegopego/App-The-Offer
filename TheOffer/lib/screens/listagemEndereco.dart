import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:theoffer/scoped-models/main.dart';
import 'package:theoffer/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:theoffer/utils/connectivity_state.dart';
import 'package:theoffer/utils/locator.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:theoffer/models/endereco.dart';
import 'package:theoffer/models/cidade.dart';
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
          body: !_enderecosLoading || listaEnderecos != null ? body() : Container(),
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
            slivers: <Widget>[
              items(),
            ],
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
                onTap: () {},
                child: _enderecosLoading
            ? Container()
            : index != listaEnderecos.length 
                ? Container (
                    color: Colors.terciariaTheOffer,
                    child: CustomScrollView(
                        shrinkWrap: true,
                      slivers: [ 
                      SliverToBoxAdapter(
                        child: Card(
                      child: Container(
                        height: 90,
                        color: Colors.secundariaTheOffer,
                        child: GestureDetector(
                          onTap: () {
                          },
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
                                                    color: Colors.principalTheOffer,
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
                                                  color: Colors.principalTheOffer,
                                                  icon: Icon(Icons.edit),
                                                  onPressed: () {
                                                      MaterialPageRoute route =
                                                          MaterialPageRoute(builder: (context) => ListagemEndereco());

                                                      Navigator.push(context, route);
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
                                                      color: Colors.principalTheOffer,
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
                                                    color: Colors.principalTheOffer,
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
                  ),
                  ])
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
                                      MaterialPageRoute(builder: (context) => ListagemEndereco());
 
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

}
