class Usuario {
  String? sId;
  String? nome;
  String? email;
  String? nascimento;
  String? sexo;
  String? telefone;
  String? tipoUser;
  String? sala;
  String? createdAt;
  int? iV;

  Usuario(
      {this.sId,
      this.nome,
      this.email,
      this.nascimento,
      this.sexo,
      this.telefone,
      this.tipoUser,
      this.sala,
      this.createdAt,
      this.iV});

  Usuario.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    nome = json['nome'];
    email = json['email'];
    nascimento = json['nascimento'];
    sexo = json['sexo'];
    telefone = json['telefone'];
    tipoUser = json['tipo_user'];
    sala = json['sala'];
    createdAt = json['createdAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['_id'] = this.sId;
    data['nome'] = this.nome;
    data['email'] = this.email;
    data['nascimento'] = this.nascimento;
    data['sexo'] = this.sexo;
    data['telefone'] = this.telefone;
    data['tipo_user'] = this.tipoUser;
    data['sala'] = this.sala;
    data['createdAt'] = this.createdAt;
    data['__v'] = this.iV;
    return data;
  }
}
