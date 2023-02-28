import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

Future<bool> validUser(usuario, senha, context) async {
  var _usuario = usuario.text;
  var _password = Uri.encodeComponent(senha.text);

  var headers = {
    'pk': 'here_a_private_key',
    'authorization':
        'Basic ' + base64Encode(utf8.encode('${usuario.text}:${senha.text}')),
    "Accept": "application/json"
  };

  var requestBody = {'usuario': _usuario, 'password': _password};

  final link = Uri.parse('http://app.etaure.com.br:3032/auth/authenticate');

  final response = await http.post(link, headers: headers, body: requestBody);

  if (response.statusCode == 200) {
    var aresult = json.decode(response.body);

    saveNusu(aresult['user']['nome']);
    saveUsu(aresult['user']['email']);
    savePassword(senha);
    saveIdUser(aresult['user']['_id']);
    saveTypeUser(aresult['user']['tipo_user']);
    saveSalaU(aresult['user']['sala']);

    return true;
  } else {
    return false;
  }
}

Future<bool> saveNusu(nome) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  return prefs.setString('nome', nome);
}

Future<bool> saveUsu(email) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  return prefs.setString('usuario', email);
}

Future<bool> savePassword(senha) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  return prefs.setString('senha', senha.text);
}

Future<bool> saveIdUser(id) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  return prefs.setString('_id', id);
}

Future<bool> saveTypeUser(tipoU) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  return prefs.setString('tipo_user', tipoU);
}

Future<bool> saveSalaU(salaU) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  return prefs.setString('sala', salaU);
}
