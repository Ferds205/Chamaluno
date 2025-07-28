import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: TelaInicial()));
}

List<Aluno> alunos = [];

class ListaChamada extends StatefulWidget {
  final List<Aluno> alunos;
  const ListaChamada({super.key, required this.alunos});
  @override
  _ListaChamadaState createState() => _ListaChamadaState();
}

class _ListaChamadaState extends State<ListaChamada> {
  Map<String, bool> presenca = {};
  @override
  void initState() {
    super.initState();

    for (var aluno in widget.alunos) {
      presenca[aluno.nome] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lista de Chamada')),
      body: ListView.builder(
        itemCount: widget.alunos.length,
        itemBuilder: (context, index) {
          final aluno = widget.alunos[index];
          return CheckboxListTile(
            title: Text(aluno.nome),
            subtitle: Text('Idade: ${aluno.idade}'),
            value: presenca[aluno.nome],
            onChanged: (bool? valor) {
              setState(() {
                presenca[aluno.nome] = valor ?? false;
              });
            },
          );
        },
      ),
    );
  }
}

class TelaInicial extends StatelessWidget {
  const TelaInicial({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Menu Principal')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text('Cadastrar Aluno'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CadastroAluno()),
                );
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Lista de Chamada'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ListaChamada(alunos: alunos),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Tela principal do app
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CadastroAluno(), // Tela inicial
    );
  }
}

class Aluno {
  String nome;
  String idade;
  bool presente;
  Aluno({required this.nome, required this.idade, this.presente = false});
}

class CadastroAluno extends StatefulWidget {
  const CadastroAluno({super.key});

  @override
  _CadastroAlunoState createState() => _CadastroAlunoState();
}

class _CadastroAlunoState extends State<CadastroAluno> {
  String nome = '';
  String idade = '';
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController idadeController = TextEditingController();
  List<String> palavrasProibidas = [
    'filha da puta',
    'hitler',
    'arrombado',
    'vagabundo',
    'idiota',
    'besta',
    'lucas',
  ];
  bool contemPalavraProibida(String nome) {
    String nomeMin = nome.toLowerCase();
    return palavrasProibidas.any((palavras) => nomeMin.contains(palavras));
  }

  bool nomeValido(String nome) {
    final RegExp regex = RegExp(r'^[A-Za-zÀ-ú\s]+$');
    return regex.hasMatch(nome);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bem Vindo!')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo para digitar o nome
            TextField(
              controller: nomeController,
              decoration: InputDecoration(labelText: 'Nome'),
              onChanged: (valor) {
                nome = valor;
              },
            ),
            TextField(
              controller: idadeController,
              decoration: InputDecoration(labelText: 'Idade'),
              keyboardType: TextInputType.number,
              onChanged: (valor) {
                idade = valor;
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (nome.trim().isEmpty || idade.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Preencha todos os campos antes de salvar!',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                int? idadeConvertida = int.tryParse(idade);
                if (idadeConvertida == null || idadeConvertida <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Idade inválida.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                if (contemPalavraProibida(nome)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Nome contém palavras impróprias >:{'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                if (!nomeValido(nome)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('O nome deve apenas conter letras. '),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                setState(() {
                  // Atualiza a tela para mostrar os dados
                  alunos.add(Aluno(nome: nome, idade: idade));
                  nomeController.clear();
                  idadeController.clear();
                  nome = '';
                  idade = '';
                });
              },
              child: Text('Salvar'),
            ),
            SizedBox(height: 20),
            Text(
              'Alunos cadastrados:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: alunos.length,
                itemBuilder: (context, index) {
                  final aluno = alunos[index];
                  return ListTile(
                    title: Text(aluno.nome),
                    subtitle: Text('idade: ${aluno.idade}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: Icon(Icons.edit), onPressed: () {}),
                        IconButton(icon: Icon(Icons.delete), onPressed: () {}),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
