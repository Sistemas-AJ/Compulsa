import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../models/database_models.dart';
import '../../models/regimen_tributario.dart';
import '../../services/database_service.dart';

class EmpresaFormScreen extends StatefulWidget {
  final Empresa? empresa;

  const EmpresaFormScreen({super.key, this.empresa});

  bool get isEditing => empresa != null;

  @override
  State<EmpresaFormScreen> createState() => _EmpresaFormScreenState();
}

class _EmpresaFormScreenState extends State<EmpresaFormScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _rucController = TextEditingController();
  
  List<RegimenTributario> _regimenes = [];
  int? _regimenSeleccionado;
  bool _isLoading = false;
  bool _cargandoRegimenes = true;

  @override
  void initState() {
    super.initState();
    _cargarRegimenes();
    if (widget.isEditing) {
      _nombreController.text = widget.empresa!.nombreRazonSocial;
      _rucController.text = widget.empresa!.ruc;
      _regimenSeleccionado = widget.empresa!.regimenId;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _rucController.dispose();
    super.dispose();
  }

  Future<void> _cargarRegimenes() async {
    try {
      final regimenes = await _databaseService.obtenerRegimenes();
      setState(() {
        _regimenes = regimenes;
        _cargandoRegimenes = false;
        // Si no es edición y hay regímenes, seleccionar el primero
        if (!widget.isEditing && regimenes.isNotEmpty) {
          _regimenSeleccionado = regimenes.first.id;
        }
      });
    } catch (e) {
      setState(() {
        _cargandoRegimenes = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar regímenes: $e')),
        );
      }
    }
  }

  String? _validarRuc(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El RUC es obligatorio';
    }
    
    final ruc = value.trim();
    if (ruc.length != 11) {
      return 'El RUC debe tener 11 dígitos';
    }
    
    if (!RegExp(r'^\d{11}$').hasMatch(ruc)) {
      return 'El RUC debe contener solo números';
    }
    
    // Validación básica de RUC peruano
    final firstDigit = int.parse(ruc[0]);
    if (firstDigit != 1 && firstDigit != 2) {
      return 'El RUC debe comenzar con 1 o 2';
    }
    
    return null;
  }

  Future<void> _guardarEmpresa() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_regimenSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione un régimen tributario')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final empresa = Empresa(
        id: widget.empresa?.id ?? 0,
        regimenId: _regimenSeleccionado!,
        nombreRazonSocial: _nombreController.text.trim(),
        ruc: _rucController.text.trim(),
      );

      if (widget.isEditing) {
        await _databaseService.actualizarEmpresa(empresa);
      } else {
        await _databaseService.insertarEmpresa(empresa);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing 
                ? 'Empresa actualizada correctamente'
                : 'Empresa creada correctamente',
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
        title: Text(widget.isEditing ? 'Editar Empresa' : 'Nueva Empresa'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _cargandoRegimenes
          ? const Center(child: CircularProgressIndicator())
          : _regimenes.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.warning, size: 64, color: Colors.orange),
                      SizedBox(height: 16),
                      Text(
                        'No hay regímenes tributarios',
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Debe crear al menos un régimen tributario\nantes de agregar empresas',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : Form(
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
                                'Datos de la Empresa',
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
                                  labelText: 'Nombre o Razón Social',
                                  hintText: 'Ej: Empresa ABC S.A.C.',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.business),
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
                                controller: _rucController,
                                decoration: const InputDecoration(
                                  labelText: 'RUC',
                                  hintText: 'Ej: 20123456789',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.assignment_ind),
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(11),
                                ],
                                validator: _validarRuc,
                              ),
                              const SizedBox(height: 16),
                              
                              DropdownButtonFormField<int>(
                                value: _regimenSeleccionado,
                                decoration: const InputDecoration(
                                  labelText: 'Régimen Tributario',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.account_balance),
                                ),
                                items: _regimenes.map((regimen) {
                                  return DropdownMenuItem<int>(
                                    value: regimen.id,
                                    child: Text('${regimen.nombre} (${regimen.tasaRentaFormateada})'),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _regimenSeleccionado = value;
                                  });
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Seleccione un régimen tributario';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _guardarEmpresa,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  child: _isLoading
                                      ? const CircularProgressIndicator(color: Colors.white)
                                      : Text(
                                          widget.isEditing ? 'Actualizar Empresa' : 'Crear Empresa',
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
                                    'Información sobre RUC',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                '• El RUC debe tener exactamente 11 dígitos\n'
                                '• Debe comenzar con 1 (persona natural) o 2 (persona jurídica)\n'
                                '• Solo se permiten números\n'
                                '• Ejemplo: 20123456789',
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