import 'package:scoped_model/scoped_model.dart';
import './carrinho.dart';
import './user.dart';

class MainModel extends Model with CarrinhoModel, UserModel {
}
