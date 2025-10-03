import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class EmpresaFormScreen extends StatefulWidget {
  const EmpresaFormScreen({super.key});

  @override
  State<EmpresaFormScreen> createState() => _EmpresaFormScreenState();
}

class _EmpresaFormScreenState extends State<EmpresaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _rucController = TextEditingController();
  final _razonSocialController = TextEditingController();
  String _regimenSeleccionado = 'General';
  
  final List<String> _regimenes = [
    'General',
    'MYPE',
    'Especial',
    'RUS',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Empresa'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                controller: _rucController,
                decoration: const InputDecoration(
                  labelText: 'RUC',
                  hintText: 'Ingrese el RUC de la empresa',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el RUC';  
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _razonSocialController,
                decoration: const InputDecoration(
                  labelText: 'Razón Social',
                  hintText: 'Ingrese la razón social',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese la razón social';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _regimenSeleccionado,
                decoration: const InputDecoration(
                  labelText: 'Régimen Tributario',
                ),
                items: _regimenes.map((String regimen) {
                  return DropdownMenuItem<String>(
                    value: regimen,
                    child: Text(regimen),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _regimenSeleccionado = newValue!;
                  });
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _guardarEmpresa,
                  child: const Text('Guardar Empresa'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _guardarEmpresa() {
    if (_formKey.currentState!.validate()) {
      // TODO: Guardar empresa
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Empresa guardada correctamente'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
  
  @override
  void dispose() {
    _rucController.dispose();
    _razonSocialController.dispose();
    super.dispose();
  }
}