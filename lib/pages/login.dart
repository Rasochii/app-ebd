import 'package:flutter/material.dart';
import 'package:projeto/pages/tela_aulas.dart';
import 'package:projeto/service/validacao.dart' as validacao;
import 'package:shared_preferences/shared_preferences.dart';

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final ThemeData tema = ThemeData();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EBD Config',
      theme: tema.copyWith(
          colorScheme: tema.colorScheme.copyWith(
        primary: Colors.green.shade900,
      )),
      home: const MyHomePage(title: 'Escola Bíblica Dominical'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final formKey = GlobalKey<FormState>();
  TextEditingController usuario = TextEditingController();
  TextEditingController senha = TextEditingController();

  bool _obscureText = true;

  _recuperar() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("nome")) {
      setState(() {
        usuario.text = prefs.getString("usuario")!;
      });
    }
  }

  @override
  void initState() {
    _recuperar();
    super.initState();
  }

  bool isLoading = false;
  final loading = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(25),
                      child: Text(
                        "Bem-vindo!",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 35,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: TextFormField(
                    controller: usuario,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: MediaQuery.of(context).size.height / 40),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      icon: Icon(Icons.person),
                      labelText: "E-mail",
                      labelStyle: TextStyle(color: Colors.black),
                      hintText: 'Informe seu email de acesso',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                  ), //TextField
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: TextFormField(
                    controller: senha,
                    obscureText: _obscureText,
                    keyboardType: TextInputType.text,
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
                ElevatedButton(
                  onPressed: () async {
                    var result =
                        await validacao.validUser(usuario, senha, context);
                    if (result) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const TelaAula()),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Usuário/senha incorreto.'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(
                      (MediaQuery.of(context).size.height / 4),
                      (MediaQuery.of(context).size.width / 24),
                    ),
                    alignment: Alignment.center,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Acessar',
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height / 40),
                  ),
                ),
                const SizedBox(
                  height: 80,
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Image.asset(
                          'images/ipbcg_logo.jpeg',
                          width: 150,
                        )
                      ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
