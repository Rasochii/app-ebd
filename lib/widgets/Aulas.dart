class Aulas {
  String? sId;
  String? sala;
  String? tema;
  String? data;
  String? observacoes;
  String? presmarcada;
  bool? anexo;
  String? createdAt;
  int? iV;

  Aulas(
      {this.sId,
      this.sala,
      this.tema,
      this.data,
      this.observacoes,
      this.presmarcada,
      this.anexo,
      this.createdAt,
      this.iV});

  Aulas.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    sala = json['sala'];
    tema = json['tema'];
    data = json['data'];
    observacoes = json['observacoes'];
    presmarcada = json['presmarcada'];
    anexo = json['anexo'];
    createdAt = json['createdAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['_id'] = this.sId;
    data['sala'] = this.sala;
    data['tema'] = this.tema;
    data['data'] = this.data;
    data['observacoes'] = this.observacoes;
    data['presmarcada'] = this.presmarcada;
    data['anexo'] = this.anexo;
    data['createdAt'] = this.createdAt;
    data['__v'] = this.iV;
    return data;
  }
}
