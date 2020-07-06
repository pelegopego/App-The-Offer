import 'package:theoffer/utils/constants.dart';


Map<String, String> getHeaders() {
  Map<String, String> headers = {
       'authorization': Autenticacao.token
  };
  return headers;
}
