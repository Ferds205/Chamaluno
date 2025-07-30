import 'package:chamada_alunos/model/aluno.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AlunoRepository {
  final List<Aluno> _alunos = [];

  List<Aluno> getAlunos() => _alunos;

  void adicionar(Aluno aluno) {
    _alunos.add(aluno);
  }

  void remover(Aluno aluno) {
    _alunos.remove(aluno);
  }

  void atualizar(Aluno antigo, Aluno novo) {
    int index = _alunos.indexOf(antigo);
    if (index != -1) {
      _alunos[index] = novo;
    }
  }

  bool nomeDuplicado(String nome) {
    return _alunos.any((a) => a.nome.toLowerCase() == nome.toLowerCase());
  }

  static Future<void> salvarAlunos(List<Aluno> alunos) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = alunos.map((a) => jsonEncode(a.toJson())).toList();
    await prefs.setStringList('alunos', jsonList);
  }

  Future<void> carregarAlunos() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList('alunos') ?? [];
    _alunos.clear();
    _alunos.addAll(jsonList.map((jsonStr) => Aluno.fromJson(jsonDecode(jsonStr))));
  }
}
