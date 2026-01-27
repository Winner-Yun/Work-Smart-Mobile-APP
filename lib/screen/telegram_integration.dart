import 'package:flutter/material.dart';

class TelegramIntegration extends StatefulWidget {
  const TelegramIntegration({super.key});

  @override
  State<TelegramIntegration> createState() => _TelegramIntegrationState();
}

class _TelegramIntegrationState extends State<TelegramIntegration> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Telegram Integration'),
      ),
      body: const Center(
        child: Text('Telegram Integration Screen'),
      ),

    );
  }
}