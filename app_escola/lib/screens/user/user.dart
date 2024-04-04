import 'package:flutter/material.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuário'),
      ),
      body: const Center(
        child: SizedBox(
          width: 600,
          child: UserForm(),
        ),
      ),
    );
  }
}

class UserForm extends StatelessWidget {
  const UserForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            decoration: const InputDecoration(labelText: 'Nome'),
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Senha'),
            obscureText: true,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Ação
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }
}
