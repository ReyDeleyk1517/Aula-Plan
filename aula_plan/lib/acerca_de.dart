import 'package:flutter/material.dart';
class AcercaDeView extends StatelessWidget {
  const AcercaDeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acerca de la App'),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text(
                'CAM - USAER',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const Divider(height: 40, indent: 50, endIndent: 50),
              const Text(
                'Desarrollado por: Roberto Pacheco Mendoza',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 30),
              const Text(
                '2026',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}