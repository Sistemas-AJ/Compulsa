import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/empresa.dart';
import '../../models/regimen_tributario.dart';
import '../../services/empresa_service.dart';
import '../../services/regimen_tributario_service.dart';

class EmpresaFormScreen extends StatefulWidget {
  final Empresa? empresa;
  
  const EmpresaFormScreen({super.key, this.empresa});

  @override
  State<EmpresaFormScreen> createState() => _EmpresaFormScreenState();
}

class _EmpresaFormScreenState extends State<EmpresaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _rucController = TextEditingController();
  final _razonSocialController = TextEditingController();
  final _nombreComercialController = TextEditingController();
  final _direccionController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();
  
  List<RegimenTributario> _regimenes = [];
  int? _regimenSeleccionado;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _cargarRegimenes();
    _inicializarFormulario();
  }

  void _cargarRegimenes() async {
    try {
      final regimenes = await RegimenTributarioService.getAllRegimenes();
      setState(() {
        _regimenes = regimenes;
        if (_regimenSeleccionado == null && regimenes.isNotEmpty) {
          _regimenSeleccionado = regimenes.first.id;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar regímenes: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _inicializarFormulario() {
    if (widget.empresa != null) {
      final empresa = widget.empresa!;
      _rucController.text = empresa.ruc;
      _razonSocialController.text = empresa.razonSocial;
      _nombreComercialController.text = empresa.nombreComercial ?? '';
      _direccionController.text = empresa.direccion ?? '';
      _telefonoController.text = empresa.telefono ?? '';
      _emailController.text = empresa.email ?? '';
      _regimenSeleccionado = empresa.regimenTributarioId;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.empresa == null ? 'Nueva Empresa' : 'Editar Empresa'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _rucController,
                      decoration: const InputDecoration(
                        labelText: 'RUC *',
                        hintText: 'Ingrese el RUC de la empresa',
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 11,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese el RUC';
                        }
                        if (value.length != 11) {
                          return 'El RUC debe tener 11 dígitos';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _razonSocialController,
                      decoration: const InputDecoration(
                        labelText: 'Razón Social *',
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
                    TextFormField(
                      controller: _nombreComercialController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre Comercial',
                        hintText: 'Ingrese el nombre comercial (opcional)',
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      initialValue: _regimenSeleccionado,
                      decoration: const InputDecoration(
                        labelText: 'Régimen Tributario *',
                      ),
                      items: _regimenes.map((RegimenTributario regimen) {
                        return DropdownMenuItem<int>(
                          value: regimen.id,
                          child: Text('${regimen.nombre} (${regimen.tasaRentaFormateada})'),
                        );
                      }).toList(),
                      onChanged: (int? newValue) {
                        setState(() {
                          _regimenSeleccionado = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Por favor seleccione un régimen tributario';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _direccionController,
                      decoration: const InputDecoration(
                        labelText: 'Dirección',
                        hintText: 'Ingrese la dirección (opcional)',
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _telefonoController,
                      decoration: const InputDecoration(
                        labelText: 'Teléfono',
                        hintText: 'Ingrese el teléfono (opcional)',
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'Ingrese el email (opcional)',
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Ingrese un email válido';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _guardarEmpresa,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(widget.empresa == null ? 'Guardar Empresa' : 'Actualizar Empresa'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
  
  void _guardarEmpresa() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final empresa = Empresa(
        id: widget.empresa?.id,
        ruc: _rucController.text,
        razonSocial: _razonSocialController.text,
        nombreComercial: _nombreComercialController.text.isEmpty 
            ? null : _nombreComercialController.text,
        direccion: _direccionController.text.isEmpty 
            ? null : _direccionController.text,
        telefono: _telefonoController.text.isEmpty 
            ? null : _telefonoController.text,
        email: _emailController.text.isEmpty 
            ? null : _emailController.text,
        regimenTributarioId: _regimenSeleccionado!,
      );

      if (widget.empresa == null) {
        // Crear nueva empresa
        await EmpresaService.createEmpresa(empresa);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Empresa creada correctamente'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        // Actualizar empresa existente
        await EmpresaService.updateEmpresa(widget.empresa!.id!, empresa);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Empresa actualizada correctamente'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context, true); // Retorna true para indicar que se guardó
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar empresa: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  @override
  void dispose() {
    _rucController.dispose();
    _razonSocialController.dispose();
    _nombreComercialController.dispose();
    _direccionController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}