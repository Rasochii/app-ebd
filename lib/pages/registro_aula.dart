import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projeto/pages/tela_aulas.dart';
import 'package:projeto/service/rotas_aulas.dart';
import 'package:projeto/service/rotas_presenca.dart';

var textoButtonSalvar = TextEditingController(text: 'Salvar');
var corFloatButton = Colors.green.shade900;
var iconFloatButton = const Icon(Icons.thumb_up);

class RegAula extends StatefulWidget {
  final int? modelo;
  final String? idAula;

  const RegAula({Key? key, this.modelo, this.idAula}) : super(key: key);

  @override
  State<RegAula> createState() => _RegAulaState();
}

class _RegAulaState extends State<RegAula> {
  TextEditingController temaAula = TextEditingController();
  TextEditingController dataAula = TextEditingController();
  TextEditingController obsAula = TextEditingController();

  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        cancelText: 'CANCELAR',
        initialDate: selectedDate,
        firstDate: DateTime(1901, 1),
        lastDate: DateTime(2100));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        var data = DateFormat('dd/MM/yyyy').format(picked);
        dataAula.value = TextEditingValue(text: data.toString());
      });
    }
  }

  void funcoes() async {
    //Salvar aula
    if (widget.modelo == 1) {
      var presmarcada = 'false';
      var result =
          await postAulas(temaAula, dataAula, obsAula, presmarcada, context);

      if (result) {
        temaAula.clear();
        dataAula.clear();
        obsAula.clear();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => const TelaAula()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível postar a aula.'),
          ),
        );
      }
      //Modificar aula
    } else if (widget.modelo == 2) {
      var id = widget.idAula.toString();
      var tema = temaAula.text;
      var data = dataAula.text;
      var obs = obsAula.text;

      var result = await putAula(id, tema, data, obs, context);

      if (result) {
        temaAula.clear();
        dataAula.clear();
        obsAula.clear();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => const TelaAula()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível modificar a aula.'),
          ),
        );
      }

      //Excluir aula
    } else if (widget.modelo == 3) {
      var id = widget.idAula.toString();
      var result = await deleteAula(id);
      await deletePresAula(id);

      if (result) {
        temaAula.clear();
        dataAula.clear();
        obsAula.clear();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => const TelaAula()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível deletar a aula.'),
          ),
        );
      }
    }
  }

  void dadosAula(idAula) async {
    var dadosAula = await getAula(idAula);

    setState(() {
      temaAula.text = dadosAula.tema!;
      dataAula.text = dadosAula.data!;
      obsAula.text = dadosAula.observacoes!;
    });
  }

  @override
  void initState() {
    // Salvar Aula
    if (widget.modelo == 1) {
      setState(() {
        textoButtonSalvar = TextEditingController(text: 'Salvar');
        corFloatButton = Colors.green.shade900;
        iconFloatButton = const Icon(Icons.change_circle);
      });
      // Modificar Aula
    } else if (widget.modelo == 2) {
      dadosAula(widget.idAula);

      setState(() {
        textoButtonSalvar = TextEditingController(text: 'Confirmar');
        corFloatButton = Colors.lime;
        iconFloatButton = const Icon(Icons.change_circle);
      });
      // Excluir Aula
    } else if (widget.modelo == 3) {
      dadosAula(widget.idAula);

      setState(() {
        textoButtonSalvar = TextEditingController(text: 'Deletar');
        corFloatButton = Colors.red;
        iconFloatButton = const Icon(Icons.delete);
      });
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CircleAvatar(
          radius: 28,
          backgroundImage: AssetImage('images/logo.jpeg'),
        ),
      ),
      body: Column(
        children: [
          const Padding(padding: EdgeInsets.all(15)),
          TextFormField(
            controller: temaAula,
            keyboardType: TextInputType.text,
            validator: (value) {
              if (value!.isEmpty) {
                return 'Preencha com um tema';
              }
              return null;
            },
            style: TextStyle(
                color: Colors.black,
                fontSize: MediaQuery.of(context).size.height / 40),
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              icon: Icon(
                Icons.book,
                color: Colors.green.shade900,
              ),
              hintText: "Tema",
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 18),
            ),
          ),
          GestureDetector(
            onTap: () => _selectDate(context),
            child: AbsorbPointer(
              child: TextFormField(
                controller: dataAula,
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Preencha com uma data!';
                  }
                  return null;
                },
                style: TextStyle(
                    color: Colors.black,
                    fontSize: MediaQuery.of(context).size.height / 40),
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  icon: Icon(
                    Icons.calendar_today,
                    color: Colors.green.shade900,
                  ),
                  hintText: "Data",
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 18),
                ),
              ),
            ),
          ),
          TextFormField(
            maxLines: 3,
            controller: obsAula,
            keyboardType: TextInputType.text,
            style: TextStyle(
                color: Colors.black,
                fontSize: MediaQuery.of(context).size.height / 40),
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              icon: Icon(
                Icons.bookmark,
                color: Colors.green.shade900,
              ),
              hintText: "Observações",
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 18),
            ),
          ),
          const Divider(),
          const Padding(padding: EdgeInsets.only(top: 10)),
          ElevatedButton(
            onPressed: funcoes,
            style: ElevatedButton.styleFrom(
              backgroundColor: corFloatButton,
              fixedSize: Size(
                (MediaQuery.of(context).size.height / 6),
                (MediaQuery.of(context).size.width / 10),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
            child: Text(textoButtonSalvar.text),
          ),
          const Padding(padding: EdgeInsets.only(right: 10)),
        ],
      ),
    );
  }
}
