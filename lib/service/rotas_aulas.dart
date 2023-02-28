import 'dart:convert';
import 'dart:async';
import 'package:projeto/widgets/Aulas.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

Future<bool> postAulas(tema, data, observacoes, presmarcada, context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var sala = prefs.getString('sala').toString();
  var temaAula = tema.text;
  var dataAula = data.text;
  var obsAula = observacoes.text;

  if (temaAula == "" || dataAula == "") {
    return false;
  } else {
    final url = Uri.parse('http://app.etaure.com.br:3032/auth/aula');

    final requestBody = {
      'sala': sala,
      'tema': temaAula,
      'data': dataAula,
      'observacoes': obsAula,
      'presmarcada': presmarcada,
      'anexo': 'false'
    };

    final response = await http.post(url, body: requestBody);

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Não foi possível postar a aula');
    }
  }
}

Future<List<Aulas>> getAulas() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var sala = prefs.getString('sala').toString();

  final url = Uri.parse('http://app.etaure.com.br:3032/auth/aulasala/$sala');

  final response = await http.get(url);

  if (response.statusCode == 200) {
    List listaAulas = json.decode(response.body);
    return listaAulas.map((json) => Aulas.fromJson(json)).toList();
  } else {
    throw Exception('Não foi possível recuperar os dados das aulas');
  }
}

Future<Aulas> getAula(id) async {
  final url = Uri.parse('http://app.etaure.com.br:3032/auth/aula/$id');

  final response = await http.get(url);

  if (response.statusCode == 200) {
    var listaAulas = Aulas.fromJson(json.decode(response.body));

    return listaAulas;
  } else {
    throw Exception('Não foi possível recuperar os dados das aulas');
  }
}

Future<bool> deleteAula(id) async {
  final url = Uri.parse('http://app.etaure.com.br:3032/auth/aula/$id');

  final response = await http.delete(url);

  if (response.statusCode == 200) {
    return true;
  } else {
    throw Exception('Não foi possível deletar a aula');
  }
}

Future<bool> putAula(id, tema, data, obs, context) async {
  final requestBody = {'tema': tema, 'data': data, 'observacoes': obs};

  final url = Uri.parse('http://app.etaure.com.br:3032/auth/aula/$id');

  final response = await http.put(url, body: requestBody);

  if (response.statusCode == 200) {
    return true;
  } else {
    throw Exception('Não foi possível modificar a aula');
  }
}

Future<bool> putPresMarcada(id, presmarcada, context) async {
  final requestBody = {'presmarcada': presmarcada};

  final url = Uri.parse('http://app.etaure.com.br:3032/auth/aula/$id');

  final response = await http.put(url, body: requestBody);

  if (response.statusCode == 200) {
    return true;
  } else {
    throw Exception('Não foi possível modificar a aula');
  }
}

Future enviarDocumento(arquivo, idAula) async {
  //Envio do documento
  final link = Uri.parse('http://app.etaure.com.br:3032/auth/upload/$idAula');

  http.MultipartRequest request = http.MultipartRequest("POST", link);

  http.MultipartFile multipartFile =
      await http.MultipartFile.fromPath('file', arquivo);

  request.files.add(multipartFile);

  http.StreamedResponse response = await request.send();

  if (response.statusCode == 200) {
    //Alteração do valor 'anexo' na aula
    final requestBody = {'anexo': 'true'};

    final url = Uri.parse('http://app.etaure.com.br:3032/auth/aula/$idAula');

    final response2 = await http.put(url, body: requestBody);
    return true;
  } else {
    throw Exception('Não foi possível enviar o arquivo');
  }
}
