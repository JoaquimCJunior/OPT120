import 'package:flutter/material.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atividade'),
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
            decoration: const InputDecoration(labelText: 'Título'),
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Descrição'),
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Data (AA/MM/DD)'),
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
