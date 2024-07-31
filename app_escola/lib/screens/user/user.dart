// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  late bool _isMounted;
  late List<User> _users;

  String? jwt;
  String? role;

  @override
  void initState() {
    super.initState();
    _getStoredValues();
    _isMounted = true;
    _users = [];
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
        title: const Text('Usuário'),
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
                  width: 120,
                  child: ElevatedButton(
                    onPressed: () {
                      _openCreateUserForm(context);
                    },
                    child: const Text('Criar Usuário', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildUserDataTable(),
          ],
        ),
      ),
    );
  }

  DataRow _buildUserDataRow(User user) {
    return DataRow(
      cells: [
        DataCell(Text(user.id.toString())),
        DataCell(Text(user.nome)),
        DataCell(Text(user.email)),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  _openEditUserForm(context, user, jwt!, role!); // Passa jwt e role
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  _deleteUser(user.id);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserDataTable() {
    return FutureBuilder<List<User>>(
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
              DataColumn(label: Text('Nome')),
              DataColumn(label: Text('Email')),
              DataColumn(label: Text('Ações')),
            ],
            rows: snapshot.data!.map((user) {
              return _buildUserDataRow(user);
            }).toList(),
          );
        }
      },
    );
  }

  Future<List<User>> _fetchUsers() async {
    try {
      final dio = Dio();
      final options = Options(headers: {'jwt': '$jwt'});
      final response = await dio.get(
        'http://localhost:3000/users/all-users?roleUser=$role',
        options: options,
      );

      if (response.statusCode == 200 && _isMounted) {
        final List<dynamic> responseData = response.data;
        return responseData.map((json) => User(
          id: json['id'],
          nome: json['nome'] ?? '',
          email: json['email'] ?? '',
          password: json['password'] ?? '',
          desabilitado: json['desabilitado'] == 0,
        )).toList();
      } else {
        throw Exception('Failed to load users');
      }
    } catch (error) {
      throw Exception('Failed to load users: $error');
    }
  }

  void _openCreateUserForm(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Criar Usuário'),
          content: SizedBox(
            width: 600,
            height: 250,
            child: UserForm(
              onFormSubmitted: () {
                setState(() {});
                Navigator.of(context).pop();
              },
            ),
          ),
        );
      },
    );
  }

  void _openEditUserForm(BuildContext context, User user, String jwt, String role) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Usuário'),
          content: SizedBox(
            width: 600,
            height: 250,
            child: EditUserForm(
              user: user,
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

  void _deleteUser(int userId) async {
    try {
      final dio = Dio();
      final options = Options(headers: {'jwt': '$jwt'});
      final response = await dio.put(
        'http://localhost:3000/users/$userId?roleUser=$role',
        data: {'desabilitado': true},
        options: options,
      );

      if (response.statusCode == 200) {
        setState(() {
          for (var user in _users) {
            if (user.id == userId) {
              user.desabilitado = true;
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

  const UserForm({super.key, required this.onFormSubmitted});

  @override
  _UserFormState createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nome'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira o nome';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira o email';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Senha'),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira a senha';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _submitForm(context);
            },
            child: const Text('Cadastrar'),
          ),
        ],
      ),
    );
  }

  void _submitForm(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await Dio().post(
          'http://localhost:3000/users/',
          data: {
            'nome': _nameController.text,
            'email': _emailController.text,
            'password': _passwordController.text,
          },
        );

        if (response.statusCode == 201) {
          widget.onFormSubmitted();
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class EditUserForm extends StatefulWidget {
  final Function onFormSubmitted;
  final User user;
  final String jwt;
  final String role;

  const EditUserForm({super.key, required this.onFormSubmitted, required this.user, required this.jwt, required this.role});

  @override
  _EditUserFormState createState() => _EditUserFormState();
}

class _EditUserFormState extends State<EditUserForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.user.nome;
    _emailController.text = widget.user.email;
    _passwordController.text = widget.user.password;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nome'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira o nome';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira o email';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Senha'),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira a senha';
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
        final dio = Dio();
        final options = Options(headers: {'jwt': '${widget.jwt}'}); // Adiciona o JWT ao cabeçalho
        final response = await dio.put(
          'http://localhost:3000/users/${widget.user.id}?roleUser=${widget.role}',
          data: {
            'nome': _nameController.text,
            'email': _emailController.text,
            'password': _passwordController.text,
          },
          options: options, // Passa as opções com o JWT para a requisição
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class User {
  final int id;
  final String nome;
  final String email;
  final String password;
  bool desabilitado;

  User({
    required this.id,
    required this.nome,
    required this.email,
    required this.password,
    required this.desabilitado,
  });
}
