// ignore_for_file: prefer_typing_uninitialized_variables, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:projeto/pages/tela_usuario.dart';
import 'package:projeto/service/rotas_usu.dart';
import 'package:masked_text/masked_text.dart';

var textoButtonSalvar = TextEditingController(text: 'Salvar');
var corFloatButton = Colors.green.shade900;
var iconFloatButton = const Icon(Icons.thumb_up);

class Registro extends StatefulWidget {
  final int? modelo;
  final String? idUsu;

  const Registro({Key? key, this.modelo, this.idUsu}) : super(key: key);

  @override
  State<Registro> createState() => _RegistroState();
}

class _RegistroState extends State<Registro> {
  bool isLoading = false;
  bool pressionado1 = true;
  bool pressionado2 = false;

  final formKey = GlobalKey<FormState>();
  final TextEditingController _senha = TextEditingController();
  final TextEditingController _usuario = TextEditingController();
  final TextEditingController _telefone = TextEditingController();
  final TextEditingController _nome = TextEditingController();
  final TextEditingController _nascimento = TextEditingController();

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.green.shade700;
    }
    return Colors.green.shade900;
  }

  bool _obscureText = true;

  String cargoValor = "Professor";

  String _valorSelecionado = '--------';
  List<String> sexo = [
    '--------',
    'Masculino',
    'Feminino',
  ];

  void funcoes() async {
    //Salvar usuario
    if (widget.modelo == 1) {
      var result = await postUsu(_nome, _valorSelecionado, _usuario,
          _nascimento, _telefone, _senha, cargoValor, context);

      if (result) {
        _nome.clear();
        _usuario.clear();
        _nascimento.clear();
        _telefone.clear();
        _senha.clear();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (BuildContext context) => const TelaUsu()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível registrar o usuário.'),
          ),
        );
      }
      //Modificar aula
    } else if (widget.modelo == 2) {
      var id = widget.idUsu.toString();
      var sexo = _valorSelecionado;
      var email = _usuario.text;
      var nome = _nome.text;
      var telefone = _telefone.text;
      var nascimento = _nascimento.text;

      var result =
          await putUsu(id, nome, sexo, email, nascimento, telefone, context);

      if (result) {
        _usuario.clear();
        _nome.clear();
        _telefone.clear();
        _nascimento.clear();
        _usuario.clear();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (BuildContext context) => const TelaUsu()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível modificar o usuário.'),
          ),
        );
      }

      //Excluir aula
    } else if (widget.modelo == 3) {
      var id = widget.idUsu.toString();
      var result = await deleteUsu(id);

      if (result) {
        _usuario.clear();
        _nome.clear();
        _telefone.clear();
        _nascimento.clear();
        _usuario.clear();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (BuildContext context) => const TelaUsu()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível deletar o usuário.'),
          ),
        );
      }
    }
  }

  void dadosUsuario(idUsu) async {
    var dadosUsuario = await getUsuario(idUsu);

    setState(() {
      cargoValor = dadosUsuario.tipoUser!;
      _valorSelecionado = dadosUsuario.sexo!;
      _usuario.text = dadosUsuario.email!;
      _nome.text = dadosUsuario.nome!;
      _telefone.text = dadosUsuario.telefone!;
      _nascimento.text = dadosUsuario.nascimento!;
    });
  }

  String texto = 'Registro';

  @override
  void initState() {
    if (widget.modelo == 1) {
      setState(() {
        texto = 'Registro';
        textoButtonSalvar = TextEditingController(text: 'Salvar');
        corFloatButton = Colors.green.shade900;
        iconFloatButton = const Icon(Icons.change_circle);
      });
      // Alterar Usuário
    } else if (widget.modelo == 2) {
      dadosUsuario(widget.idUsu);

      setState(() {
        texto = 'Alterar';
        textoButtonSalvar = TextEditingController(text: 'Confirmar');
        corFloatButton = Colors.lime;
        iconFloatButton = const Icon(Icons.change_circle);
      });
      // Excluir Usuário
    } else if (widget.modelo == 3) {
      dadosUsuario(widget.idUsu);

      setState(() {
        texto = 'Excluir';
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
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            children: [
              const SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Text(
                      texto,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 35,
                      ),
                    ),
                  )
                ],
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextFormField(
                  controller: _nome,
                  autofocus: true,
                  keyboardType: TextInputType.name,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Informe o seu nome';
                    }
                    return null;
                  },
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: MediaQuery.of(context).size.height / 40),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    icon: Icon(Icons.person),
                    labelText: "Nome",
                    labelStyle: TextStyle(color: Colors.black),
                    hintText: 'Informe o seu nome',
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: DropdownButtonFormField(
                  decoration: const InputDecoration(
                    labelText: 'Sexo',
                    labelStyle: TextStyle(color: Colors.black, fontSize: 22),
                    icon: Icon(Icons.face),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  value: _valorSelecionado,
                  isExpanded: true,
                  items: sexo.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(fontSize: 20),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _valorSelecionado = value!;
                    });
                  },
                  onSaved: (value) {
                    setState(() {
                      _valorSelecionado = value!;
                    });
                  },
                  validator: (value) {
                    if (value == sexo.first) {
                      return 'Informe o sexo';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextFormField(
                  controller: _usuario,
                  autofocus: true,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Informe o email corretamente';
                    }
                    return null;
                  },
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: MediaQuery.of(context).size.height / 40),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    icon: Icon(Icons.mail),
                    labelText: "E-mail",
                    labelStyle: TextStyle(color: Colors.black),
                    hintText: 'Informe seu email de acesso',
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: MaskedTextField(
                  mask: '##/##/####',
                  controller: _nascimento,
                  autofocus: true,
                  keyboardType: TextInputType.datetime,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Informe sua data de nascimento';
                    } else if (value.length < 10 || value.length > 10) {
                      return 'Informe a data corretamente';
                    }
                    return null;
                  },
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: MediaQuery.of(context).size.height / 40),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    icon: Icon(Icons.calendar_month),
                    labelText: "Data de nascimento",
                    labelStyle: TextStyle(color: Colors.black),
                    hintText: 'Informe sua data de nascimento',
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: MaskedTextField(
                  mask: '(##)#####-####',
                  controller: _telefone,
                  autofocus: true,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Informe seu telefone';
                    } else if (value.length < 14 || value.length > 14) {
                      return 'Informe seu telefone corretamente';
                    }
                    return null;
                  },
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: MediaQuery.of(context).size.height / 40),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    icon: Icon(Icons.phone),
                    labelText: "Telefone",
                    labelStyle: TextStyle(color: Colors.black),
                    hintText: 'Informe seu telefone',
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextFormField(
                  controller: _senha,
                  autofocus: true,
                  obscureText: _obscureText,
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Informe uma senha!';
                    } else if (value.length < 6) {
                      return 'A senha deve ter, no mínimo, 6 dígitos';
                    }
                    return null;
                  },
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: MediaQuery.of(context).size.height / 40),
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                      child: Icon(_obscureText
                          ? Icons.visibility_off
                          : Icons.visibility),
                    ),
                    icon: const Icon(Icons.lock),
                    labelText: "Senha",
                    labelStyle: const TextStyle(color: Colors.black),
                    hintText: 'informe sua senha de acesso',
                    hintStyle:
                        const TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    fillColor: MaterialStateProperty.resolveWith(getColor),
                    value: pressionado1,
                    onChanged: (bool? value) {
                      if (pressionado2 = true) {
                        setState(
                          () {
                            pressionado2 = false;
                            pressionado1 = value!;
                            cargoValor = "Professor";
                          },
                        );
                      }
                    },
                  ),
                  const Text(
                    "Professor",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(
                    width: 50,
                  ),
                  Checkbox(
                    fillColor: MaterialStateProperty.resolveWith(getColor),
                    value: pressionado2,
                    onChanged: (bool? value) {
                      if (pressionado1 = true) {
                        setState(
                          () {
                            pressionado1 = false;
                            pressionado2 = value!;
                            cargoValor = "Aluno";
                          },
                        );
                      }
                    },
                  ),
                  const Text(
                    'Aluno',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  )
                ],
              ),
              ElevatedButton(
                onPressed: funcoes,
                style: ElevatedButton.styleFrom(
                  backgroundColor: corFloatButton,
                  fixedSize: Size(
                    (MediaQuery.of(context).size.height / 4),
                    (MediaQuery.of(context).size.width / 19),
                  ),
                  alignment: Alignment.center,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  textoButtonSalvar.text,
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height / 40),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
