// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  late bool _isMounted;
  late List<Activity> _activity;

  String? jwt;
  String? role;

  @override
  void initState() {
    super.initState();
    _getStoredValues();
    _isMounted = true;
    _activity = [];
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  Future<void> _getStoredValues() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      jwt = prefs.getString('token');
      role = prefs.getString('role');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atividade'),
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
                  width: 150,
                  child: ElevatedButton(
                    onPressed: () {
                      _openCreateActivity(context, jwt!, role!);
                    },
                    child: const Text('Criar Atividade', style: TextStyle(fontSize: 12)),
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

  DataRow _buildActivityDataRow(Activity activity) {
    return DataRow(
      cells: [
        DataCell(Text(activity.id.toString())),
        DataCell(Text(activity.titulo)),
        DataCell(Text(activity.descricao)),
        DataCell(Text(formatDate(activity.data))),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  _openEditActivityForm(context, activity, jwt!, role!);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  _deleteActivity(activity.id);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityDataTable() {
    return FutureBuilder<List<Activity>>(
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
              DataColumn(label: Text('titulo')),
              DataColumn(label: Text('descricao')),
              DataColumn(label: Text('data')),
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

  Future<List<Activity>> _fetchUsers() async {
    try {
      final dio = Dio();
      final options = Options(headers: {'jwt': '$jwt'});
      final response = await dio.get(
        'http://localhost:3000/school-activity/all-activity?roleUser=$role',
        options: options,
      );
      
      if (response.statusCode == 200 && _isMounted) {
        final List<dynamic> responseData = response.data;
        return responseData.map((json) => Activity(
          id: json['id'],
          titulo: json['titulo'] ?? '',
          descricao: json['descricao'] ?? '',
          data: json['data'] ?? '', 
          desabilitado: json['desabilitado'] == 0,
        )).toList();
      } else {
        throw Exception('Failed to load activity');
      }
    } catch (error) {
      throw Exception('Failed to load activity: $error');
    }
  }

  void _openCreateActivity(BuildContext context, String jwt, String role) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Criar Atvidade'),
          content: SizedBox(
            width: 600,
            height: 250,
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

  void _openEditActivityForm(BuildContext context, Activity activity, String jwt, String role) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Atividade'),
          content: SizedBox(
            width: 600,
            height: 250,
            child: EditActivityForm(
              activity: activity,
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

  void _deleteActivity(int activityId) async {
    try {
      final dio = Dio();
      final options = Options(headers: {'jwt': '$jwt'});
      final response = await dio.put(
        'http://localhost:3000/school-activity/$activityId?roleUser=$role',
        data: {'desabilitado': true},
        options: options,
      );

      if (response.statusCode == 200) {
        setState(() {
          for (var activity in _activity) {
            if (activity.id == activityId) {
              activity.desabilitado = true;
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
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _dataController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _tituloController,
            decoration: const InputDecoration(labelText: 'Título'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira o título';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _descricaoController,
            decoration: const InputDecoration(labelText: 'Descrição'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira uma Descrição';
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
          'http://localhost:3000/school-activity/?roleUser=${widget.role}',
          data: {
            'titulo': _tituloController.text,
            'descricao': _descricaoController.text,
            'data': _dataController.text,
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
    _tituloController.dispose();
    _descricaoController.dispose();
    _dataController.dispose();
    super.dispose();
  }
}

class EditActivityForm extends StatefulWidget {
  final Function onFormSubmitted;
  final Activity activity;
  final String jwt;
  final String role;

  const EditActivityForm({super.key, required this.onFormSubmitted, required this.activity, required this.jwt, required this.role});

  @override
  _EditActivityFormState createState() => _EditActivityFormState();
}

class _EditActivityFormState extends State<EditActivityForm> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _dataController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tituloController.text = widget.activity.titulo;
    _descricaoController.text = widget.activity.descricao;
    _dataController.text = formatDate(widget.activity.data);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _tituloController,
            decoration: const InputDecoration(labelText: 'Título'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira o título';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _descricaoController,
            decoration: const InputDecoration(labelText: 'Descrição'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira a descrição';
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
          'http://localhost:3000/school-activity/${widget.activity.id}?roleUser=${widget.role}',
          data: {
            'titulo': _tituloController.text,
            'descricao': _descricaoController.text,
            'data': _dataController.text,
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
    _tituloController.dispose();
    _descricaoController.dispose();
    _dataController.dispose();
    super.dispose();
  }
}

class Activity {
  final int id;
  final String titulo;
  final String descricao;
  final String data;
  bool desabilitado;

  Activity({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.data,
    required this.desabilitado,
  });
}


String formatDate(String dateString) {
  DateTime dateTime = DateTime.parse(dateString);
  String formattedDate = "${dateTime.year.toString()}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
  return formattedDate;
}