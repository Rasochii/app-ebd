import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:projeto/widgets/Presenca.dart';

Future<bool> postPresenca(dados) async {
  final url = Uri.parse('http://app.etaure.com.br:3032/auth/presenca');
  var headers = {'Content-Type': 'application/json'};
  final requestBody = json.encode(dados);

  final response = await http.post(url, headers: headers, body: requestBody);

  if (response.statusCode == 200) {
    return true;
  } else {
    throw Exception('Não foi possível marcar as presenças');
  }
}

Future<Presenca> getPresenca(idAula) async {
  final url = Uri.parse('http://app.etaure.com.br:3032/auth/presenca/$idAula');

  final response = await http.get(url);

  if (response.statusCode == 200) {
    var listaPresenca = Presenca.fromJson(json.decode(response.body));

    return listaPresenca;
  } else {
    throw Exception('Não foi possível recuperar os dados das aulas');
  }
}

Future<bool> deletePresAula(idaula) async {
  final url =
      Uri.parse('http://app.etaure.com.br:3032/auth/presencaaula/$idaula');

  final response = await http.delete(url);

  if (response.statusCode == 200) {
    return true;
  } else {
    throw Exception('Não foi possível deletar');
  }
}

Future<bool> putPresenca(id, alunos, visitantes, context) async {
  final url = Uri.parse('http://app.etaure.com.br:3032/auth/presenca/$id');
  var headers = {'Content-Type': 'application/json'};
  final requestBody =
      jsonEncode(Presenca(aula: id, alunos: alunos, visitantes: visitantes));

  final response = await http.put(url, headers: headers, body: requestBody);

  if (response.statusCode == 200) {
    return true;
  } else {
    throw Exception('Não foi possível modificar a presença');
  }
}
