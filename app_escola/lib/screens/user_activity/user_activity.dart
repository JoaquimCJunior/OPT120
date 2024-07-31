// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserActivityScreen extends StatefulWidget {
  const UserActivityScreen({super.key});

  @override
  _UserActivityScreenState createState() => _UserActivityScreenState();
}

class _UserActivityScreenState extends State<UserActivityScreen> {
  late bool _isMounted;
  late List<UserActivity> _userActivity;

  String? jwt;
  String? role;

  @override
  void initState() {
    super.initState();
    _getStoredValues();
    _isMounted = true;
    _userActivity = [];
  }

  Future<void> _getStoredValues() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      jwt = prefs.getString('token');
      role = prefs.getString('role');
    });
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atividade - Usuário'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () {
                      _openCreateUserActivity(context, jwt!, role!);
                    },
                    child: const Text('Vincular Atividades', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildActivityDataTable(),
          ],
        ),
      ),
    );
  }

  DataRow _buildActivityDataRow(UserActivity userActivity) {
    return DataRow(
      cells: [
        DataCell(Text(userActivity.id.toString())),
        DataCell(Text(userActivity.idUsuario.toString())),
        DataCell(Text(userActivity.idAtividade.toString())),
        DataCell(Text(formatDate(userActivity.data))),
        DataCell(Text(userActivity.nota.toString())),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  _openEditUserActivity(context, userActivity, jwt!, role!);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  _deleteUserActivity(userActivity.id);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityDataTable() {
    return FutureBuilder<List<UserActivity>>(
      future: _fetchUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return DataTable(
            columns: const [
              DataColumn(label: Text('ID')),
              DataColumn(label: Text('Usuário')),
              DataColumn(label: Text('Atividade')),
              DataColumn(label: Text('data')),
              DataColumn(label: Text('nota')),
              DataColumn(label: Text('Ações')),
            ],
            rows: snapshot.data!.map((user) {
              return _buildActivityDataRow(user);
            }).toList(),
          );
        }
      },
    );
  }

  Future<List<UserActivity>> _fetchUsers() async {
    try {
      final dio = Dio();
      final options = Options(headers: {'jwt': '$jwt'});
      final response = await dio.get(
        'http://localhost:3000/users-activity/all-users-activity?roleUser=$role',
        options: options,
      );
      if (response.statusCode == 200 && _isMounted) {
        final List<dynamic> responseData = response.data;
        return responseData.map((json) => UserActivity(
          id: json['id'],
          idUsuario: json['id_usuario'],
          idAtividade: json['id_atividade'],
          data: json['data'] ?? '', 
          nota: json['nota'] ?? '',
          desabilitado: json['desabilitado'] == 0,
        )).toList();
      } else {
        throw Exception('Failed to load activity');
      }
    } catch (error) {
      throw Exception('Failed to load activity: $error');
    }
  }

  void _openCreateUserActivity(BuildContext context, String jwt, String role) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Atribuir Atividade para Usuário'),
          content: SizedBox(
            width: 600,
            height: 300,
            child: UserForm(
              jwt: jwt,
              role: role,
              onFormSubmitted: () {
                setState(() {});
              },
            ),
          ),
        );
      },
    );
  }

  void _openEditUserActivity(BuildContext context, UserActivity userActivity, String jwt, String role) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Atividade do Usuário'),
          content: SizedBox(
            width: 600,
            height: 300,
            child: EditUserActivity(
              userActivity: userActivity,
              jwt: jwt,
              role: role,
              onFormSubmitted: () {
                setState(() {});
              },
            ),
          ),
        );
      },
    );
  }


  void _deleteUserActivity(int userActivityId) async {
    try {
      final dio = Dio();
      final options = Options(headers: {'jwt': '$jwt'});
      final response = await dio.put(
        'http://localhost:3000/users-activity/$userActivityId?roleUser=$role',
        data: {'desabilitado': true},
        options: options,
      );
      if (response.statusCode == 200) {
        setState(() {
          for (var userActivity in _userActivity) {
            if (userActivity.id == userActivityId) {
              userActivity.desabilitado = true;
            }
          }
        });
      } else {
        // Handle error
      }
    } catch (error) {
      // Handle error
    }
  }


}

class UserForm extends StatefulWidget {
  final Function onFormSubmitted;
  final String jwt;
  final String role;

  const UserForm({super.key, required this.onFormSubmitted, required this.jwt, required this.role});

  @override
  _UserFormState createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final _formKey = GlobalKey<FormState>();
  final _idUsuarioController = TextEditingController();
  final _idAtividadeController = TextEditingController();
  final _dataController = TextEditingController();
  final _notaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _idUsuarioController,
            decoration: const InputDecoration(labelText: 'Usuário'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira um usuário';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _idAtividadeController,
            decoration: const InputDecoration(labelText: 'Atividade'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira uma Atividade';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _dataController,
            decoration: const InputDecoration(labelText: 'Data (AA-MM-DD)'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira uma data';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _notaController,
            decoration: const InputDecoration(labelText: 'nota'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira uma Atividade';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _submitForm(context);

            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  
  void _submitForm(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        final options = Options(headers: {'jwt': '${widget.jwt}'});
        final response = await Dio().post(
          'http://localhost:3000/users-activity/?roleUser=${widget.role}',
          data: {
            'id_usuario': _idUsuarioController.text,
            'id_atividade': _idAtividadeController.text,
            'data': _dataController.text,
            'nota': _notaController.text,
          },
          options: options,
        );

        if (response.statusCode == 201 && mounted) {
          widget.onFormSubmitted();
          // ignore: use_build_context_synchronously
          Navigator.of(context).pop();
        } else {
          // Handle error
        }
      } catch (error) {
        // Handle error
      }
    }
  }

  @override
  void dispose() {
    _idUsuarioController.dispose();
    _idAtividadeController.dispose();
    _dataController.dispose();
    _notaController.dispose();
    super.dispose();
  }
}

class EditUserActivity extends StatefulWidget {
  final Function onFormSubmitted;
  final UserActivity userActivity;
  final String jwt;
  final String role;

  const EditUserActivity({super.key, required this.onFormSubmitted, required this.userActivity, required this.jwt, required this.role});

  @override
  _EditUserActivityState createState() => _EditUserActivityState();
}

class _EditUserActivityState extends State<EditUserActivity> {
  final _formKey = GlobalKey<FormState>();
  final _idUsuarioController = TextEditingController();
  final _idAtividadeController = TextEditingController();
  final _dataController = TextEditingController();
  final _notaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _idUsuarioController.text = widget.userActivity.idUsuario.toString();
    _idAtividadeController.text = widget.userActivity.idAtividade.toString();
    _dataController.text = formatDate(widget.userActivity.data);
    _notaController.text = widget.userActivity.nota.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _idUsuarioController,
            decoration: const InputDecoration(labelText: 'Usuário'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira um Usuário';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _idAtividadeController,
            decoration: const InputDecoration(labelText: 'Atividade'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira uma Atividade';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _dataController,
            decoration: const InputDecoration(labelText: 'Data (AA-MM-DD)'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira uma data';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _notaController,
            decoration: const InputDecoration(labelText: 'Nota'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira uma nota';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _submitEditForm(context);
            },
            child: const Text('Concluir'),
          ),
        ],
      ),
    );
  }

  void _submitEditForm(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        final options = Options(headers: {'jwt': '${widget.jwt}'});
        final response = await Dio().put(
          'http://localhost:3000/users-activity/${widget.userActivity.id}?roleUser=${widget.role}',
          data: {
            'id_usuario': _idUsuarioController.text,
            'id_atividade': _idAtividadeController.text,
            'data': _dataController.text,
            'nota': _notaController.text,
          },
          options: options, 
        );

        if (response.statusCode == 200) {
          widget.onFormSubmitted();
          // ignore: use_build_context_synchronously
          Navigator.of(context).pop();
        } else {
          // Handle error
        }
      } catch (error) {
        // Handle error
      }
    }
  }

  @override
  void dispose() {
    _idUsuarioController.dispose();
    _idAtividadeController.dispose();
    _dataController.dispose();
    _notaController.dispose();
    super.dispose();
  }
}

class UserActivity {
  final int id;
  final int idUsuario;
  final int idAtividade;
  final String data;
  final double nota;
  bool desabilitado;

  UserActivity({
    required this.id,
    required this.idUsuario,
    required this.idAtividade,
    required this.data,
    required this.nota,
    required this.desabilitado,
  });
}


String formatDate(String dateString) {
  DateTime dateTime = DateTime.parse(dateString);
  String formattedDate = "${dateTime.year.toString()}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
  return formattedDate;
}