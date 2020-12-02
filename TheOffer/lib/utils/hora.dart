import 'package:intl/intl.dart';
import 'package:theoffer/models/Produto.dart';
import 'package:theoffer/models/EmpresaDetalhada.dart';

String getHora(double hora) {
  String horaEditada = ('00' + (hora / 60).toString() + '00');

  horaEditada = horaEditada.replaceAll('.', ':');
  String minutos = ((int.parse(horaEditada.substring(
                  (horaEditada.indexOf(':') + 1),
                  horaEditada.indexOf(':') + 3)) /
              100) *
          60)
      .round()
      .toString();

  if (int.parse(minutos) <= 9) {
    minutos = '0' + minutos;
  }

  horaEditada = horaEditada.substring(
          (horaEditada.indexOf(':') - 2), horaEditada.indexOf(':') + 1) +
      minutos;
  horaEditada.replaceAll('.', ':');
  return horaEditada;
}

double getHoraInicioProdutoHoje(Produto produto) {
  double hora;
  switch (DateFormat('EEEE').format(DateTime.now().toLocal())) {
    //Segunda-Feira
    case "Monday":
      hora = produto.empresaSegundaInicio;
      break;
    //Terça-Feira
    case "Tuesday":
      hora = produto.empresaTercaInicio;
      break;
    //Quarta-Feira
    case "Wednesday":
      hora = produto.empresaQuartaInicio;
      break;
    //Quinta-Feira
    case "Thursday":
      hora = produto.empresaQuintaInicio;
      break;
    //Sexta-Feira
    case "Friday":
      hora = produto.empresaSextaInicio;
      break;
    //Sábado
    case "Saturday":
      hora = produto.empresaSabadoInicio;
      break;
    //Domingo
    case "Sunday":
      hora = produto.empresaDomingoInicio;
      break;
  }
  return hora;
}

double getHoraFimProdutoHoje(Produto produto) {
  double hora;
  switch (DateFormat('EEEE').format(DateTime.now().toLocal())) {
    //Segunda-Feira
    case "Monday":
      hora = produto.empresaSegundaFim;
      break;
    //Terça-Feira
    case "Tuesday":
      hora = produto.empresaTercaFim;
      break;
    //Quarta-Feira
    case "Wednesday":
      hora = produto.empresaQuartaFim;
      break;
    //Quinta-Feira
    case "Thursday":
      hora = produto.empresaQuintaFim;
      break;
    //Sexta-Feira
    case "Friday":
      hora = produto.empresaSextaFim;
      break;
    //Sábado
    case "Saturday":
      hora = produto.empresaSabadoFim;
      break;
    //Domingo
    case "Sunday":
      hora = produto.empresaDomingoFim;
      break;
  }
  return hora;
}

double getHoraInicioEmpresaHoje(EmpresaDetalhada empresa) {
  double hora;
  switch (DateFormat('EEEE').format(DateTime.now().toLocal())) {
    //Segunda-Feira
    case "Monday":
      hora = empresa.segundaInicio;
      break;
    //Terça-Feira
    case "Tuesday":
      hora = empresa.tercaInicio;
      break;
    //Quarta-Feira
    case "Wednesday":
      hora = empresa.quartaInicio;
      break;
    //Quinta-Feira
    case "Thursday":
      hora = empresa.quintaInicio;
      break;
    //Sexta-Feira
    case "Friday":
      hora = empresa.sextaInicio;
      break;
    //Sábado
    case "Saturday":
      hora = empresa.sabadoInicio;
      break;
    //Domingo
    case "Sunday":
      hora = empresa.domingoInicio;
      break;
  }
  return hora;
}

double getHoraFimEmpresaHoje(EmpresaDetalhada empresa) {
  double hora;
  switch (DateFormat('EEEE').format(DateTime.now().toLocal())) {
    //Segunda-Feira
    case "Monday":
      hora = empresa.segundaFim;
      break;
    //Terça-Feira
    case "Tuesday":
      hora = empresa.tercaFim;
      break;
    //Quarta-Feira
    case "Wednesday":
      hora = empresa.quartaFim;
      break;
    //Quinta-Feira
    case "Thursday":
      hora = empresa.quintaFim;
      break;
    //Sexta-Feira
    case "Friday":
      hora = empresa.sextaFim;
      break;
    //Sábado
    case "Saturday":
      hora = empresa.sabadoFim;
      break;
    //Domingo
    case "Sunday":
      hora = empresa.domingoFim;
      break;
  }
  return hora;
}

String getDiaSemana() {
  String dia;
  switch (DateFormat('EEEE').format(DateTime.now().toLocal())) {
    //Segunda-Feira
    case "Monday":
      dia = 'Segunda-Feira';
      break;
    //Terça-Feira
    case "Tuesday":
      dia = 'Terça-Feira';
      break;
    //Quarta-Feira
    case "Wednesday":
      dia = 'Quarta-Feira';
      break;
    //Quinta-Feira
    case "Thursday":
      dia = 'Quinta-Feira';
      break;
    //Sexta-Feira
    case "Friday":
      dia = 'Sexta-Feira';
      break;
    //Sábado
    case "Saturday":
      dia = 'Sábado';
      break;
    //Domingo
    case "Sunday":
      dia = 'Domingo';
      break;
  }
  return dia;
}
