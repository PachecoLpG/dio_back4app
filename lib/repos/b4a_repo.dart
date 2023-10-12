import 'dart:convert';

import 'package:dio_back4app/models/cep_model.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class B4aRepo {
  ParseObject cepDB = ParseObject('cepDB');

  Future<void> createCep(CepModel cep) async {
    cepDB.set('cep', cep.cep);
    cepDB.set('logradouro', cep.logradouro);
    cepDB.set('complemento', cep.complemento);
    cepDB.set('bairro', cep.bairro);
    cepDB.set('localidade', cep.localidade);
    cepDB.set('uf', cep.uf);
    cepDB.set('ibge', cep.ibge);
    cepDB.set('gia', cep.gia);
    cepDB.set('ddd', cep.ddd);
    cepDB.set('siafi', cep.siafi);

    await cepDB.save();
  }

  Future<bool> verifyCep(String cep) async {
    final QueryBuilder<ParseObject> parseQuery =
        QueryBuilder<ParseObject>(cepDB);
    parseQuery.whereContains('cep', cep);

    final ParseResponse apiResponse = await parseQuery.query();

    if (apiResponse.success && apiResponse.results != null) {
      return true;
    }

    return false;
  }

  Future<List<CepModel>> getCepList() async {
    final QueryBuilder<ParseObject> parseQuery =
        QueryBuilder<ParseObject>(cepDB);
    final ParseResponse apiResponse = await parseQuery.query();

    List<CepModel> cepList = [];
    if (apiResponse.success && apiResponse.results != null) {
      for (var result in apiResponse.results!) {
        cepList.add(CepModel.fromJson(jsonDecode(result.toString())));
      }

      return cepList;
    }

    return [];
  }

  Future<void> delete(String id) async {
    await cepDB.delete(id: id);
  }

  Future<void> edit(String id, String novoLogradouro) async {
    cepDB
      ..objectId = id
      ..set('logradouro', novoLogradouro);
    await cepDB.save();
  }
}
