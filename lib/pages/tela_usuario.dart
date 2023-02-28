import 'package:flutter/material.dart';
import 'package:projeto/pages/registro.dart';
import 'package:projeto/pages/tela_aulas.dart';
import 'package:projeto/service/rotas_usu.dart' as rota_u;
import 'package:projeto/widgets/Usuarios.dart';
import 'package:shared_preferences/shared_preferences.dart';

var ativacao = true;
var usuario;
var corBotao = Colors.green.shade900;

Future buscarUser() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var id = prefs.getString('_id').toString();
  usuario = await rota_u.getUsuario(id);
  if (usuario.tipoUser == 'Professor') {
    ativacao = true;
    corBotao = Colors.green.shade900;
  } else if (usuario.tipoUser == 'Aluno') {
    ativacao = false;
    corBotao = Colors.grey;
  }
}

void showModalbottom(BuildContext context, dadosUsu) {
  showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Wrap(
          children: <Widget>[
            ListTile(
              enabled: ativacao,
              leading: const Icon(Icons.assignment),
              title: const Text('Modificar usuário'),
              onTap: () async {
                var id = dadosUsu.sId.toString();
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => Registro(
                      modelo: 2,
                      idUsu: id,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              enabled: ativacao,
              leading: const Icon(Icons.delete),
              title: const Text('Excluir usuário'),
              onTap: () async {
                var id = dadosUsu.sId.toString();

                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => Registro(
                      modelo: 3,
                      idUsu: id,
                    ),
                  ),
                );
              },
            ),
          ],
        );
      });
}

Future<List<Usuario>> listaUsuarios() async {
  List<Usuario> _dadosUsu = <Usuario>[];

  var dadosUsu = await rota_u.getUsuarios();

  for (var element in dadosUsu) {
    _dadosUsu.add(element);
  }

  if (_dadosUsu.isNotEmpty) {
    return _dadosUsu;
  } else {
    return _dadosUsu;
  }
}

class TelaUsu extends StatefulWidget {
  const TelaUsu({super.key});

  @override
  State<TelaUsu> createState() => _TelaUsuState();
}

class _TelaUsuState extends State<TelaUsu> {
  final ThemeData theme = ThemeData();

  final List<Usuario> _usuarios = <Usuario>[];
  List<Usuario> _usuariosdisplay = <Usuario>[];

  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (_selectedIndex == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (BuildContext context) => const TelaAula()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    buscarUser();
    listaUsuarios().then((value) {
      setState(() {
        _usuarios.addAll(value);
        _usuariosdisplay = _usuarios;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme.copyWith(
          colorScheme: theme.colorScheme.copyWith(
        primary: Colors.green.shade900,
      )),
      home: Scaffold(
        appBar: AppBar(
          title: const CircleAvatar(
            radius: 28,
            backgroundImage: AssetImage('images/logo.jpeg'),
          ),
        ),
        body: Center(
          child: RefreshIndicator(
            onRefresh: () async {
              Future.delayed(const Duration(seconds: 1), () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => const TelaUsu()),
                );
              });
            },
            child: Stack(children: [
              ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: _usuariosdisplay.length + 1,
                itemBuilder: (context, index) {
                  return index == 0 ? _searchBar() : _listItem(index - 1);
                },
                physics: const AlwaysScrollableScrollPhysics(),
              ),
            ]),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.book,
                color: Colors.green.shade900,
              ),
              label: 'Aulas',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.person,
                color: Colors.green.shade900,
              ),
              label: 'Alunos',
            )
          ],
          onTap: _onItemTapped,
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            if (usuario.tipoUser == 'Professor') {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => const Registro(
                    modelo: 1,
                  ),
                ),
              );
            } else if (usuario.tipoUser == 'Aluno') {
              return;
            }
          },
          label: const Text('Cadastro de aluno'),
          icon: const Icon(Icons.add_circle_outline),
          backgroundColor: corBotao,
        ),
      ),
    );
  }

  _searchBar() {
    return Padding(
        padding: const EdgeInsets.all(8),
        child: TextField(
          decoration: const InputDecoration(hintText: 'Pesquisar...'),
          onChanged: (text) {
            text = text.toLowerCase();
            setState(() {
              _usuariosdisplay = _usuarios.where((usuario) {
                var usuariodisplay = usuario.nome!.toLowerCase();
                return usuariodisplay.contains(text);
              }).toList();
            });
          },
        ));
  }

  _listItem(index) {
    return Card(
        child: InkWell(
      onTap: () async {
        showModalbottom(context, _usuariosdisplay[index]);
      },
      child: Padding(
          padding:
              const EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                  '${_usuariosdisplay[index].tipoUser}: ${_usuariosdisplay[index].nome}',
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              Text(
                'Número: ${_usuariosdisplay[index].telefone}',
              ),
            ],
          )),
    ));
  }
}
