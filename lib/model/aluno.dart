class Aluno {
  String nome;
  String idade;
  bool presente;
  Aluno({required this.nome, required this.idade, this.presente = false});

  Map<String, dynamic> toJson() {
    return {'nome': nome, 'idade': idade, 'presente': presente};
  }

  factory Aluno.fromJson(Map<String, dynamic> json) {
    return Aluno(
      nome: json['nome'],
      idade: json['idade'],
      presente: json['presente'] ?? false,
    );
  }

  
}
