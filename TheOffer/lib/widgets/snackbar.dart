import 'package:flutter/material.dart';
import 'package:theoffer/utils/constants.dart';
import 'package:theoffer/screens/update_address.dart';

final processSnackbar = SnackBar(
  content: Text('Adicionando produto ao carrinho...'),
  duration: Duration(seconds: 1),
);
final completeSnackbar = SnackBar(
  content: Text('Produto adicionado com sucesso!'),
  duration: Duration(seconds: 1),
);
final codAvailable = SnackBar(
  content: Text('Pagar na entrega disponível!'),
  duration: Duration(seconds: 1),
);
final codNotAvailable = SnackBar(
  content: Text('Pagar na entrega não disponível!'),
  duration: Duration(seconds: 1),
);

final insufficientAmt = SnackBar(
  content: Text(
      'Preço por item $CURRENCY_SYMBOL ${FREE_SHIPPING_AMOUNT.toString()} for COD'),
  duration: Duration(seconds: 3),
);
final codEmpty = SnackBar(
  content: Text('Informe um código PIN!'),
  duration: Duration(seconds: 1),
);
final promoEmpty = SnackBar(
  content: Text('Informe um código promocional!'),
  duration: Duration(seconds: 1),
);
final ErrorSnackbar = SnackBar(
  content: Text('Informe o título da avaliação'),
  duration: Duration(seconds: 1),
);
final LoginErroSnackbar = SnackBar(
  content: Text('Entre em sua conta para avaliar.'),
  duration: Duration(seconds: 1),
);
