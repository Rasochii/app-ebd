import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:projeto/pages/tela_aulas.dart';
import 'package:projeto/service/rotas_aulas.dart' as rota_a;
import 'package:projeto/service/rotas_presenca.dart' as rota_p;
import 'package:projeto/service/rotas_usu.dart';
import 'package:projeto/widgets/Presenca.dart';

//Models
import 'package:projeto/widgets/Usuarios.dart';

var textoButtonSalvar = TextEditingController(text: 'Salvar');
var corFloatButton = Colors.green.shade900;
var iconFloatButton = const Icon(Icons.thumb_up);
var isChecked = [];
var presencas = [];

Future<List<Usuario>> listaUsuarios() async {
  List<Usuario> _dadosUsu = <Usuario>[];

  var dadosUsu = await getUsuarios();

  for (var element in dadosUsu) {
    _dadosUsu.add(element);
    isChecked.add(false);
    presencas.add([element.sId.toString(), element.nome.toString(), false]);
  }

  if (_dadosUsu.isNotEmpty) {
    return _dadosUsu;
  } else {
    return _dadosUsu;
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class cad_presenca extends StatefulWidget {
  final int? modelo;
  final String? idUsu;
  final String? idAula;
  final String? marcada;

  const cad_presenca(
      {Key? key, this.modelo, this.idUsu, this.idAula, this.marcada})
      : super(key: key);

  @override
  _Presenca createState() => _Presenca();
}

class _Presenca extends State<cad_presenca> {
  final List _usuarios = [];
  List _usuariosdisplay = [];

  int _visitantes = 1;

  Future listaPresenca() async {
    //List<Presenca> _dadosPresenca = <Presenca>[];
    List _dadosUsu = [];

    var dadosPresenca = await rota_p.getPresenca(widget.idAula.toString());

    _visitantes = dadosPresenca.visitantes!;

    for (var element in dadosPresenca.alunos!) {
      _dadosUsu.add(element);
      isChecked.add(element[2]);
      presencas.add([element[0].toString(), element[1].toString(), element[2]]);
    }
    if (dadosPresenca.alunos!.isNotEmpty) {
      return _dadosUsu;
    } else {
      return _dadosUsu;
    }
  }

  void mostrarPresencas() async {
    if (widget.marcada == 'true') {
      listaPresenca().then((value) {
        setState(() {
          _usuarios.addAll(value);
          _usuariosdisplay = _usuarios;
        });
      });
      setState(() {
        titulo = const Text('Alterar Presentes');
        textoButtonSalvar.text = 'Alterar';
        corFloatButton = Colors.lime;
      });
    } else {
      listaUsuarios().then((value) {
        setState(() {
          _usuarios.addAll(value);
          _usuariosdisplay = _usuarios;
        });
      });
      setState(() {
        titulo = const Text('Marcação de Presentes');
        textoButtonSalvar.text = 'Salvar';
        corFloatButton = Colors.green.shade900;
      });
    }
  }

  @override
  void initState() {
    isChecked.clear();
    presencas.clear();

    mostrarPresencas();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: titulo,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                return index == 0 ? _searchBar() : _listItem(index - 1);
              },
              itemCount: _usuariosdisplay.length + 1,
            ),
          ),
          SizedBox(
              child: Slider(
            value: _visitantes.toDouble(),
            max: 10,
            label: _visitantes.toString(),
            onChanged: (double value) {
              setState(() {
                _visitantes = value.toInt();
              });
            },
          )),
          Expanded(
              child: Container(
                  margin: const EdgeInsets.only(left: 10),
                  child: Text(
                    'Visitantes : ${_visitantes.round()}',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ))),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          var idAula = widget.idAula;

          if (widget.marcada == 'false') {
            await rota_a.putPresMarcada(idAula, 'true', context);
            final List<Presenca> _press = <Presenca>[];
            _press.add(Presenca(
                aula: idAula, alunos: presencas, visitantes: _visitantes));
            final presencaPost = await rota_p.postPresenca(_press);

            if (presencaPost) {
              _press.clear();
              presencas.clear();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => const TelaAula()),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Informação faltante!'),
                ),
              );
            }
          } else {
            var presencaPut = await rota_p.putPresenca(
                idAula, presencas, _visitantes, context);
            if (presencaPut) {
              presencas.clear();

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => const TelaAula()),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Informação faltante!'),
                ),
              );
            }
          }
        },
        label: Text(textoButtonSalvar.value.text),
        icon: iconFloatButton,
        backgroundColor: corFloatButton,
      ),
    );
  }

  _searchBar() {
    return const Padding(
      padding: EdgeInsets.all(8),
    );
  }

  _listItem(index) {
    return Card(
        child: InkWell(
      onTap: () {},
      child: Padding(
          padding:
              const EdgeInsets.only(top: 0, bottom: 0, left: 10, right: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CheckboxListTile(
                activeColor: Colors.green.shade900,
                title: Text(presencas[index][1]),
                value: isChecked[index],
                onChanged: (bool? value) {
                  setState(() {
                    isChecked[index] = value!;
                    presencas[index][2] = isChecked[index];
                  });
                },
              ),
            ],
          )),
    ));
  }
}
