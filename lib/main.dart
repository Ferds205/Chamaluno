import 'package:chamada_alunos/alunorepositorio.dart';
import 'package:chamada_alunos/model/aluno.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AlunoRepository alunoRepository = AlunoRepository();
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    alunoRepository.carregarAlunos().then((_) {
      setState(() {
        carregando = false;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    if (carregando) {
      return MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TelaInicial(alunoRepository: alunoRepository),
    );
  }
}

final AlunoRepository alunoRepository = AlunoRepository();

class ListaChamada extends StatefulWidget {
  final AlunoRepository alunoRepository;
  const ListaChamada({super.key, required this.alunoRepository});
  @override
  _ListaChamadaState createState() => _ListaChamadaState();
}

class _ListaChamadaState extends State<ListaChamada> {
  Map<String, bool> presenca = {};
  @override
  void initState() {
    super.initState();

    for (var aluno in widget.alunoRepository.getAlunos()) {
      presenca[aluno.nome] = false;
    }
  }
//tela da lista de chamada
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lista de Chamada')),
      body: ListView.builder(
        itemCount: widget.alunoRepository.getAlunos().length,
        itemBuilder: (context, index) {
          final aluno = widget.alunoRepository.getAlunos()[index];
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

 //tela de inicio do aplicativo
class TelaInicial extends StatelessWidget {
  final AlunoRepository alunoRepository;

 
  const TelaInicial({super.key, required this.alunoRepository});
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
                  MaterialPageRoute(
                    builder:
                        (_) => CadastroAluno(alunoRepository: alunoRepository),
                  ),
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
                    builder:
                        (_) => ListaChamada(alunoRepository: alunoRepository),
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

class CadastroAluno extends StatefulWidget {
  final AlunoRepository alunoRepository;
  const CadastroAluno({super.key, required this.alunoRepository});

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
    'boboca',
    'cupinxa',
  ];
  bool contemPalavraProibida(String nome) {
    String nomeMin = nome.toLowerCase();
    return palavrasProibidas.any((palavras) => nomeMin.contains(palavras));
  }

  bool nomeValido(String nome) {
    final RegExp regex = RegExp(r'^[A-Za-zÀ-ú\s]+$');
    return regex.hasMatch(nome);
  }

    //tela de cadastro de aluno
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastrar Aluno')),
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
    final nome = nomeController.text.trim();
    final idade = idadeController.text.trim();

    // Verificações de campo vazio
    if (nome.isEmpty || idade.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Preencha todos os campos antes de salvar!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Verificações de idade inválida
    int? idadeConvertida = int.tryParse(idade);
    if (idadeConvertida == null || idadeConvertida <= 0 || idadeConvertida >= 130) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Idade inválida.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Verificações de nome
    if (contemPalavraProibida(nome)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nome contém palavras impróprias >:{'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    // verifica se o nome contém só letras e não outros caractéres
    if (!nomeValido(nome)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('O nome deve apenas conter letras.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Verificação de nome duplicado
    if (widget.alunoRepository.nomeDuplicado(nome)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Nome já cadastrado'),
          content: Text('Este nome já está em uso. Deseja adicionar mesmo assim?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  widget.alunoRepository.adicionar(Aluno(nome: nome, idade: idade));
                  AlunoRepository.salvarAlunos(widget.alunoRepository.getAlunos());
                  nomeController.clear();
                  idadeController.clear();
                }); 
                Navigator.pop(context); // volta para a tela anterior
              },
              child: Text('Sim'),
            ),
          ],
        ),
      );
      return; // evita seguir o fluxo normal
    }

    // Se não for duplicado, adiciona direto
    setState(() {
      widget.alunoRepository.adicionar(Aluno(nome: nome, idade: idade));
      AlunoRepository.salvarAlunos(widget.alunoRepository.getAlunos());
      nomeController.clear();
      idadeController.clear();
    });
    Navigator.pop(context);
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
              child:
                  widget.alunoRepository.getAlunos().isEmpty
                      ? Center(child: Text('Nenhum aluno cadastrado ainda'))
                      : ListView.builder(
                        itemCount: widget.alunoRepository.getAlunos().length,
                        itemBuilder: (context, index) {
                          final aluno =
                              widget.alunoRepository.getAlunos()[index];
                          return ListTile(
                            title: Text(aluno.nome),
                            subtitle: Text('idade: ${aluno.idade}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    TextEditingController nomeController =
                                        TextEditingController(text: aluno.nome);
                                    TextEditingController idadeController =
                                        TextEditingController(
                                          text: aluno.idade,
                                        );

                                    showDialog(
                                      context: context,
                                      builder:
                                          (context) => AlertDialog(
                                            title: Text('Editar Aluno'),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                TextField(
                                                  controller: nomeController,
                                                  decoration: InputDecoration(
                                                    labelText: 'Nome',
                                                  ),
                                                ),
                                                TextField(
                                                  controller: idadeController,
                                                  decoration: InputDecoration(
                                                    labelText: 'Idade',
                                                  ),
                                                  keyboardType:
                                                      TextInputType.number,
                                                ),
                                              ],
                                            ),
                                            actions: [
                                              ElevatedButton(
                                                onPressed: () {
                                                  final nomeEditado = nomeController.text.trim();
                                                  final idadeEditada = idadeController.text.trim();
                                                  final novoAluno = Aluno(
                                                    nome: nomeEditado,
                                                    idade: idadeEditada,
                                                  );

                                                  setState(() {
                                                    widget.alunoRepository
                                                        .atualizar(
                                                          aluno,
                                                          novoAluno,
                                                        );
                                                    AlunoRepository.salvarAlunos(
                                                      widget.alunoRepository
                                                          .getAlunos(),
                                                    );
                                                  });

                                                  Navigator.pop(context);
                                                },
                                                child: Text('Salvar'),
                                              ),
                                            ],
                                          ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder:
                                          (context) => AlertDialog(
                                            title: Text(
                                              'Deseja excluir mesmo esse aluno?',
                                            ),
                                            actions: [
                                              ElevatedButton(
                                                onPressed: () {
                                                  setState(() {
                                                    widget.alunoRepository
                                                        .remover(aluno);
                                                    AlunoRepository.salvarAlunos(
                                                      widget.alunoRepository
                                                          .getAlunos(),
                                                    );
                                                  });
                                                  Navigator.pop(context);

                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (
                                                          context,
                                                        ) => AlertDialog(
                                                          title: Text(
                                                            'Aluno excluído!',
                                                          ),
                                                          actions: [
                                                            ElevatedButton(
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                  context,
                                                                );
                                                              },
                                                              child: Text('OK'),
                                                            ),
                                                          ],
                                                        ),
                                                  );
                                                },
                                                child: Text('Sim'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text('Cancelar'),
                                              ),
                                            ],
                                          ),
                                    );
                                  },
                                ),
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
