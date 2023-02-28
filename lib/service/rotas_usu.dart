import 'dart:convert';
import 'dart:async';
import 'package:projeto/widgets/Usuarios.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

Future<List<Usuario>> getUsuarios() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var sala = prefs.getString('sala').toString();

  final url = Uri.parse('http://app.etaure.com.br:3032/auth/usuariosala/$sala');

  final response = await http.get(url);

  if (response.statusCode == 200) {
    List listaUsu = json.decode(response.body);
    return listaUsu.map((json) => Usuario.fromJson(json)).toList();
  } else {
    throw Exception('Não foi possível recuperar os dados dos usuários');
  }
}

Future<Usuario> getUsuario(id) async {
  final url = Uri.parse('http://app.etaure.com.br:3032/auth/usuario/$id');

  final response = await http.get(url);

  if (response.statusCode == 200) {
    var usuario = Usuario.fromJson(json.decode(response.body));

    return usuario;
  } else {
    throw Exception('Não foi possível recuperar os dados dos usuários');
  }
}

Future<bool> postUsu(
    nome, sexo, email, nascimento, telefone, senha, tipoU, context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var sala = prefs.getString('sala').toString();
  var _nome = nome.text;
  var _sexo = sexo;
  var _email = email.text;
  var _nascimento = nascimento.text;
  var _telefone = telefone.text;
  var _senha = senha.text;
  var _tipoU = tipoU;

  if (_nome == "" ||
      _sexo == '--------' ||
      _email == '' ||
      _nascimento == '' ||
      _telefone == '' ||
      _senha == '') {
    return false;
  } else {
    final url = Uri.parse('http://app.etaure.com.br:3032/auth/usuario');

    final requestBody = {
      'nome': _nome,
      'email': _email,
      'password': _senha,
      'tipo_user': _tipoU,
      'nascimento': _nascimento,
      'sexo': _sexo,
      'telefone': _telefone,
      'sala': sala
    };

    final response = await http.post(url, body: requestBody);

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Não foi possível registrar o usuário');
    }
  }
}

Future<bool> deleteUsu(id) async {
  final url = Uri.parse('http://app.etaure.com.br:3032/auth/usuario/$id');

  final response = await http.delete(url);

  if (response.statusCode == 200) {
    return true;
  } else {
    throw Exception('Não foi possível deletar o usuário');
  }
}

Future<bool> putUsu(
    id, nome, sexo, email, nascimento, telefone, context) async {
  final requestBody = {
    'nome': nome,
    'email': email,
    'nascimento': nascimento,
    'sexo': sexo,
    'telefone': telefone,
  };

  final url = Uri.parse('http://app.etaure.com.br:3032/auth/usuario/$id');

  final response = await http.put(url, body: requestBody);

  if (response.statusCode == 200) {
    return true;
  } else {
    throw Exception('Não foi possível modificar o usuário');
  }
}
