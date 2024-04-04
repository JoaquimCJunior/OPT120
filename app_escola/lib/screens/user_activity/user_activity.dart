import 'package:flutter/material.dart';

class UserActivityScreen extends StatelessWidget {
  const UserActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atividade - Usuário'),
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
            decoration: const InputDecoration(labelText: 'ID do usuário'),
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'ID da atividade'),
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Data (AA/MM/DD)'),
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Nota'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
