import 'package:projeto/pages/registro_aula.dart';
import 'package:flutter/material.dart';
import 'package:projeto/pages/tela_presenca.dart';
import 'package:projeto/pages/tela_usuario.dart';
import 'package:projeto/service/rotas_aulas.dart' as rota_a;
import 'package:projeto/service/rotas_presenca.dart' as rota_p;
import 'package:projeto/service/rotas_usu.dart' as rota_u;
import 'package:projeto/widgets/Aulas.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

var titulo = const Text('Marcar presenças');

var excluirpresenca = false;
var ativacao = true;
var downloadArq = false;
var envioArq = true;
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

void showModalbottom(BuildContext context, dadosAulas) {
  showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Wrap(
          children: <Widget>[
            ListTile(
              enabled: ativacao,
              leading: const Icon(Icons.assignment),
              title: const Text('Modificar Aula'),
              onTap: () async {
                var id = dadosAulas.sId.toString();
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => RegAula(
                      modelo: 2,
                      idAula: id,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              enabled: ativacao,
              leading: const Icon(Icons.delete),
              title: const Text('Excluir aula'),
              onTap: () async {
                var id = dadosAulas.sId.toString();

                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => RegAula(
                      modelo: 3,
                      idAula: id,
                    ),
                  ),
                );
              },
            ),
            ListTile(
                enabled: ativacao,
                leading: const Icon(Icons.analytics),
                title: titulo,
                onTap: () {
                  var id = dadosAulas.sId.toString();
                  var marcado = dadosAulas.presmarcada.toString();

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            cad_presenca(idAula: id, marcada: marcado)),
                  );
                }),
            ListTile(
              enabled: excluirpresenca,
              leading: const Icon(Icons.delete_forever),
              title: const Text('Excluir presenças'),
              onTap: () async {
                var id = dadosAulas.sId.toString();
                await rota_p.deletePresAula(id);
                await rota_a.putPresMarcada(id, 'false', context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => const TelaAula()),
                );
              },
            ),
            ListTile(
              enabled: envioArq,
              leading: const Icon(Icons.upload_file_outlined),
              title: const Text("Enviar arquivo"),
              onTap: () async {
                var id = dadosAulas.sId.toString();

                var enviardoc = await pegarDocumento(id);

                if (enviardoc != true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Não foi possível enviar o arquivo!'),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Arquivo enviado! Atualize a página.'),
                    ),
                  );
                }
              },
            ),
            ListTile(
              enabled: downloadArq,
              leading: const Icon(Icons.file_download),
              title: const Text("Baixar arquivo"),
              onTap: () async {
                var id = dadosAulas.sId.toString();

                await lerDocumento(id);
              },
            ),
          ],
        );
      });
}

pegarDocumento(id) async {
  final FilePickerResult? docTemporario = await FilePicker.platform.pickFiles(
      type: FileType.custom, allowedExtensions: ['jpg', 'pdf', 'doc', 'jpeg']);
  if (docTemporario != null) {
    var documentopath = docTemporario.paths.first;
    await rota_a.enviarDocumento(documentopath, id);
  }
}

lerDocumento(sId) async {
  _launchInBrowser(
      Uri.parse('http://app.etaure.com.br:3032/auth/download/$sId'));
}

Future<void> _launchInBrowser(Uri url) async {
  if (!await launchUrl(
    url,
    mode: LaunchMode.externalApplication,
  )) {
    throw 'Could not launch $url';
  }
}

var corCard = const Color.fromARGB(255, 247, 121, 121);
var corLetra = Colors.black;

Future<List<Aulas>> listaAulas() async {
  List<Aulas> _dadosAula = <Aulas>[];

  var dadosAula = await rota_a.getAulas();

  for (var element in dadosAula) {
    _dadosAula.add(element);
  }

  if (_dadosAula.isNotEmpty) {
    return _dadosAula;
  } else {
    return _dadosAula;
  }
}

class TelaAula extends StatefulWidget {
  const TelaAula({super.key});

  @override
  State<TelaAula> createState() => _TelaAulaState();
}

class _TelaAulaState extends State<TelaAula> {
  final ThemeData theme = ThemeData();

  final List<Aulas> _aulas = <Aulas>[];
  List<Aulas> _aulasdisplay = <Aulas>[];

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (_selectedIndex == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (BuildContext context) => const TelaUsu()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    buscarUser();
    listaAulas().then((value) {
      setState(() {
        _aulas.addAll(value);
        _aulasdisplay = _aulas;
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
                      builder: (BuildContext context) => const TelaAula()),
                );
              });
            },
            child: Stack(children: [
              ListView.builder(
                padding: const EdgeInsets.only(top: 15),
                scrollDirection: Axis.vertical,
                itemCount: _aulasdisplay.length + 1,
                itemBuilder: (context, index) {
                  return index == 0 ? _searchBar() : _listItem(index - 1);
                },
                physics: const AlwaysScrollableScrollPhysics(),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Presença marcada ',
                    ),
                    Container(
                      color: Colors.green,
                      width: 10,
                      height: 10,
                    ),
                    const SizedBox(
                      width: 10,
                      height: 10,
                    ),
                    const Text(
                      'Presença não marcada ',
                    ),
                    Container(
                      color: const Color.fromARGB(255, 247, 121, 121),
                      width: 10,
                      height: 10,
                    )
                  ],
                ),
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
          onPressed: () async {
            if (usuario.tipoUser == 'Professor') {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => const RegAula(
                    modelo: 1,
                  ),
                ),
              );
            } else if (usuario.tipoUser == 'Aluno') {
              return;
            }
          },
          label: const Text('Incluir Aula'),
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
              _aulasdisplay = _aulas.where((aula) {
                var aulasdisplay = aula.tema!.toLowerCase();
                return aulasdisplay.contains(text);
              }).toList();
            });
          },
        ));
  }

  _listItem(index) {
    if (_aulasdisplay[index].presmarcada == 'true') {
      corCard = Colors.green;
      corLetra = Colors.white;
    } else {
      corCard = const Color.fromARGB(255, 247, 121, 121);
      corLetra = Colors.black;
    }
    return Card(
        color: corCard,
        child: InkWell(
          onTap: () async {
            if (_aulasdisplay[index].presmarcada == 'true') {
              titulo = const Text('Modificar presenças');
              if (usuario.tipoUser == 'Professor') {
                excluirpresenca = false;
              } else if (usuario.tipoUser == 'Professor') {
                excluirpresenca = true;
              }
            } else {
              titulo = const Text('Marcar presenças');
              excluirpresenca = false;
            }

            showModalbottom(context, _aulasdisplay[index]);

            if (_aulasdisplay[index].anexo == true) {
              downloadArq = true;
              envioArq = false;
            } else {
              downloadArq = false;
              envioArq = true;
            }
          },
          child: Padding(
              padding: const EdgeInsets.only(
                  top: 10, bottom: 10, left: 16, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(
                        _aulasdisplay[index].anexo == true
                            ? Icons.attach_file
                            : Icons.attachment,
                        color: _aulasdisplay[index].anexo == true
                            ? Colors.black
                            : Colors.white.withOpacity(0.0),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tema: ${_aulasdisplay[index].tema}',
                              style: TextStyle(
                                  color: corLetra,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold)),
                          Text(
                            'Data: ${_aulasdisplay[index].data}',
                            style: TextStyle(
                              color: corLetra,
                            ),
                          ),
                        ],
                      )
                    ],
                  )
                ],
              )),
        ));
  }
}
