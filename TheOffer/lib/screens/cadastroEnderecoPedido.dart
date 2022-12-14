/*import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:theoffer/scoped-models/main.dart';
import 'package:theoffer/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:theoffer/utils/connectivity_state.dart';
import 'package:theoffer/utils/locator.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:theoffer/screens/listagemEnderecoPedido.dart';
import 'package:theoffer/utils/headers.dart';

class TelaCadastroEnderecoPedido extends StatefulWidget {
  TelaCadastroEnderecoPedido();
  @override
  State<StatefulWidget> createState() {
    return _TelaCadastroEnderecoPedido();
  }
}

class _TelaCadastroEnderecoPedido extends State<TelaCadastroEnderecoPedido> {
  List<DropdownMenuItem<int>> listaBairros = [];
  bool _salvando = false;
  final Map<String, dynamic> _camposForm = {
    'nome': null,
    'rua': null,
    'numero': null,
    'complemento': null,
    'referencia': null
  };
  final GlobalKey<FormState> _formKeyEndereco = GlobalKey<FormState>();
  int bairroSelecionado = 0;
  bool favorito = false;
  @override
  void initState() {
    super.initState();
    locator<ConnectivityManager>().initConnectivity(context);
  }

  @override
  void dispose() {
    super.dispose();
    locator<ConnectivityManager>().dispose();
  }

  @override
  Widget build(BuildContext context) {
    getBairros();
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
        appBar: AppBar(
            centerTitle: false,
            leading: IconButton(
                icon:
                    Icon(Icons.arrow_back_ios, color: Colors.principalTheOffer),
                onPressed: () => Navigator.pop(context)),
            title: Text('Cadastro de Endereço',
                style: TextStyle(color: Colors.principalTheOffer))),
        body: body(),
      );
    });
  }

  Widget body() {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SingleChildScrollView(
                child: Container(
                    width: MediaQuery.of(context).size.width > 550.0
                        ? 500.0
                        : MediaQuery.of(context).size.width * 0.95,
                    child: Form(
                        key: _formKeyEndereco,
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: 25.0,
                            ),
                            montarCampoNomeTexto(),
                            SizedBox(
                              height: 25.0,
                            ),
                            montarCampoRuaTexto(),
                            SizedBox(
                              height: 25.0,
                            ),
                            montarCampoNumeroNumber(),
                            SizedBox(
                              height: 25.0,
                            ),
                            montarCampoComplementoTexto(),
                            SizedBox(
                              height: 25.0,
                            ),
                            montarCampoReferenciaTexto(),
                            SizedBox(
                              height: 25.0,
                            ),
                            montarCampoBairroDropDown(),
                            SizedBox(
                              height: 25.0,
                            ),
                            montarCampoFavoritoCheckBox(),
                            _salvando
                                ? CircularProgressIndicator(
                                    backgroundColor: Colors.secundariaTheOffer)
                                : montarBotaoSalvar()
                          ],
                        ))))
          ]);
    });
  }

  Widget montarBotaoSalvar() {
    return Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(15),
        child: FlatButton(
          textColor: Colors.principalTheOffer,
          color: Colors.secundariaTheOffer,
          child: Text(
            'SALVAR',
            style: TextStyle(fontSize: 17.0),
          ),
          onPressed: () {
            salvarEndereco();
            MaterialPageRoute route = MaterialPageRoute(
                builder: (context) => ListagemEnderecoPedido());

            Navigator.push(context, route);
          },
        ));
  }

  void salvarEndereco() {
    Map<String, String> headers = getHeaders();

    _formKeyEndereco.currentState.save();
    Map<dynamic, dynamic> objetoEndereco = {
      'nome': _camposForm['nome'],
      'rua': _camposForm['rua'],
      'numero': _camposForm['numero'],
      'complemento': _camposForm['complemento'],
      'referencia': _camposForm['referencia'],
      'bairro': bairroSelecionado.toString(),
      'favorito': favorito.toString(),
      'usuario': Autenticacao.codigoUsuario.toString()
    };

    http
        .post(Configuracoes.BASE_URL + 'enderecos/salvar',
            headers: headers, body: objetoEndereco)
        .then((response) {
      print("SALVOU ENDEREÇO: " + _camposForm['nome']);
    });
  }

  Widget montarCampoBairroDropDown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Text("Bairro",
                style:
                    TextStyle(fontSize: 17, color: Colors.secundariaTheOffer)),
          ),
          Container(
              decoration: BoxDecoration(color: Colors.secundariaTheOffer),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  isExpanded: true,
                  items: listaBairros,
                  style: TextStyle(color: Colors.principalTheOffer),
                  onChanged: (value) => mudouBairro(value),
                ),
              ))
        ],
      ),
    );
  }

  getBairros() async {
    Map<dynamic, dynamic> responseBody;
    Map<String, String> headers = getHeaders();

    Map<dynamic, dynamic> objetoCidade = {
      'cidade': CidadeSelecionada.id.toString()
    };
    http
        .post(Configuracoes.BASE_URL + 'bairros',
            headers: headers, body: objetoCidade)
        .then((response) {
      setState(() {
        listaBairros = [];
      });
      responseBody = json.decode(response.body);
      responseBody['bairros'].forEach((categoriaJson) {
        setState(() {
          listaBairros.add(new DropdownMenuItem(
              child: new Text(
                categoriaJson['nome'],
                style: TextStyle(color: Colors.principalTheOffer),
              ),
              value: int.parse(categoriaJson['id'])));
        });
      });
    });
  }

  mudouBairro(int idBairro) {
    bairroSelecionado = idBairro;
  }

  Widget montarCampoNomeTexto() {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: TextFormField(
          style: TextStyle(
            color: Colors.secundariaTheOffer,
          ),
          decoration: InputDecoration(
              labelStyle: TextStyle(color: Colors.secundariaTheOffer),
              labelText: 'Nome',
              contentPadding: EdgeInsets.all(0.0),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.secundariaTheOffer))),
          keyboardType: TextInputType.text,
          validator: (String value) {
            if (value.isEmpty) {
              return 'Informe um nome válido';
            }
            return null;
          },
          onSaved: (String value) {
            _camposForm['nome'] = value;
          },
        ));
  }

  Widget montarCampoRuaTexto() {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: TextFormField(
          style: TextStyle(
            color: Colors.secundariaTheOffer,
          ),
          decoration: InputDecoration(
              labelStyle: TextStyle(color: Colors.secundariaTheOffer),
              labelText: 'Rua',
              contentPadding: EdgeInsets.all(0.0),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.secundariaTheOffer))),
          keyboardType: TextInputType.text,
          validator: (String value) {
            if (value.isEmpty) {
              return 'Informe uma rua válida';
            }
            return null;
          },
          onSaved: (String value) {
            _camposForm['rua'] = value;
          },
        ));
  }

  Widget montarCampoNumeroNumber() {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: TextFormField(
          style: TextStyle(
            color: Colors.secundariaTheOffer,
          ),
          decoration: InputDecoration(
              labelStyle: TextStyle(color: Colors.secundariaTheOffer),
              labelText: 'Número',
              contentPadding: EdgeInsets.all(0.0),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.secundariaTheOffer))),
          keyboardType: TextInputType.number,
          validator: (String value) {
            if (value.isEmpty) {
              return 'Informe um número válido';
            }
            return null;
          },
          onSaved: (String value) {
            _camposForm['numero'] = value;
          },
        ));
  }

  Widget montarCampoComplementoTexto() {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: TextFormField(
          style: TextStyle(
            color: Colors.secundariaTheOffer,
          ),
          decoration: InputDecoration(
              labelStyle: TextStyle(color: Colors.secundariaTheOffer),
              labelText: 'Complemento',
              contentPadding: EdgeInsets.all(0.0),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.secundariaTheOffer))),
          keyboardType: TextInputType.text,
          validator: (String value) {
            if (value.isEmpty) {
              return 'Informe um complemento válido';
            }
            return null;
          },
          onSaved: (String value) {
            _camposForm['complemento'] = value;
          },
        ));
  }

  Widget montarCampoReferenciaTexto() {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: TextFormField(
          style: TextStyle(
            color: Colors.secundariaTheOffer,
          ),
          decoration: InputDecoration(
              labelStyle: TextStyle(color: Colors.secundariaTheOffer),
              labelText: 'Referência',
              contentPadding: EdgeInsets.all(0.0),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.secundariaTheOffer))),
          keyboardType: TextInputType.text,
          validator: (String value) {
            if (value.isEmpty) {
              return 'Informe um referência válido';
            }
            return null;
          },
          onSaved: (String value) {
            _camposForm['referencia'] = value;
          },
        ));
  }

  void alterouCheckbox(bool newValue) => setState(() {
        favorito = newValue;
      });

  Widget montarCampoFavoritoCheckBox() {
    return CheckboxListTile(
      title: Text(
        "ENDEREÇO FAVORITO",
        style: TextStyle(color: Colors.secundariaTheOffer),
      ),
      value: favorito,
      onChanged: alterouCheckbox,
      checkColor: Colors.principalTheOffer,
      activeColor: Colors.secundariaTheOffer,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}
*/
