import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../models/regimen_tributario.dart';
import '../../services/regimen_tributario_service.dart';
import '../../services/actividad_reciente_service.dart';

class RegimenFormScreen extends StatefulWidget {
  final RegimenTributario? regimen;

  const RegimenFormScreen({super.key, this.regimen});

  bool get isEditing => regimen != null;

  @override
  State<RegimenFormScreen> createState() => _RegimenFormScreenState();
}

class _RegimenFormScreenState extends State<RegimenFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _tasaController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _nombreController.text = widget.regimen!.nombre;
      _tasaController.text = (widget.regimen!.tasaRenta * 100).toString();
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _tasaController.dispose();
    super.dispose();
  }

  Future<void> _guardarRegimen() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final nombre = _nombreController.text.trim();
      final tasaPercent = double.parse(_tasaController.text);
      final tasa = tasaPercent / 100; // Convertir porcentaje a decimal

      final regimen = RegimenTributario(
        id: widget.regimen?.id ?? 0,
        nombre: nombre,
        tasaRenta: tasa,
      );

      if (widget.isEditing) {
        await RegimenTributarioService.updateRegimen(regimen);
      } else {
        await RegimenTributarioService.createRegimen(regimen);
        // Registrar actividad solo para creación
        await ActividadRecienteService.registrarRegimenCreado(
          nombre: nombre,
          tasaRenta: tasaPercent,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing 
                ? 'Régimen actualizado correctamente'
                : 'Régimen creado correctamente',
            ),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar Régimen' : 'Nuevo Régimen'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Información del Régimen',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _nombreController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del Régimen',
                        hintText: 'Ej: Régimen General',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.account_balance),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El nombre es obligatorio';
                        }
                        if (value.trim().length < 3) {
                          return 'El nombre debe tener al menos 3 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _tasaController,
                      decoration: const InputDecoration(
                        labelText: 'Tasa de Renta (%)',
                        hintText: 'Ej: 29.5',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.percent),
                        suffixText: '%',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,3}')),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'La tasa es obligatoria';
                        }
                        final tasa = double.tryParse(value);
                        if (tasa == null) {
                          return 'Ingrese una tasa válida';
                        }
                        if (tasa < 0 || tasa > 100) {
                          return 'La tasa debe estar entre 0% y 100%';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _guardarRegimen,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                widget.isEditing ? 'Actualizar Régimen' : 'Crear Régimen',
                                style: const TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Información',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• La tasa de renta se expresa como porcentaje\n'
                      '• Ejemplos: Régimen General (29.5%), RER (1.5%), etc.\n'
                      '• Puede usar decimales para mayor precisión',
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}