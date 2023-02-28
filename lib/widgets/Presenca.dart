class Presenca {
  String? aula;
  List? alunos;
  int? visitantes;

  Presenca({this.aula, this.alunos, this.visitantes});

  Presenca.fromJson(Map<String, dynamic> json) {
    aula = json['aula'];
    alunos = json['alunos'];
    visitantes = json['visitantes'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['aula'] = this.aula;
    data['alunos'] = this.alunos;
    data['visitantes'] = this.visitantes;
    return data;
  }
}
