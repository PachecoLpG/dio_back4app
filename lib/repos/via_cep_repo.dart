import 'dart:convert';

import 'package:dio_back4app/models/cep_model.dart';
import 'package:http/http.dart' as http;

class ViaCepRepo {
  String baseUri = 'https://viacep.com.br/ws/';

  Future<CepModel> getCep(String cep) async {
    final Uri path = Uri.parse('$baseUri$cep/json');

    final http.Response response = await http.get(path);

    final decoded = jsonDecode(response.body);

    final CepModel cepModel = CepModel.fromJson(decoded);

    return cepModel;
  }
}
