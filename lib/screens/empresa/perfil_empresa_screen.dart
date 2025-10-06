import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../models/database_models.dart';
import '../../models/regimen_tributario.dart';
import '../../services/database_service.dart';
import '../../config/routes.dart';

class PerfilEmpresaScreen extends StatefulWidget {
  const PerfilEmpresaScreen({super.key});

  @override
  State<PerfilEmpresaScreen> createState() => _PerfilEmpresaScreenState();
}

class _PerfilEmpresaScreenState extends State<PerfilEmpresaScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _rucController = TextEditingController();
  
  List<RegimenTributario> _regimenes = [];
  int? _regimenSeleccionado;
  Empresa? _empresaActual;
  bool _isLoading = false;
  bool _cargandoDatos = true;
  bool _modoEdicion = false;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _rucController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _cargandoDatos = true;
    });

    try {
      // Cargar regímenes y empresa en paralelo
      final futures = await Future.wait([
        _databaseService.obtenerRegimenes(),
        _databaseService.obtenerEmpresas(),
      ]);

      final regimenes = futures[0] as List<RegimenTributario>;
      final empresas = futures[1] as List<Empresa>;

      setState(() {
        _regimenes = regimenes;
        _empresaActual = empresas.isNotEmpty ? empresas.first : null;
        _cargandoDatos = false;
        
        // Si hay empresa, cargar sus datos en los controladores
        if (_empresaActual != null) {
          _nombreController.text = _empresaActual!.nombreRazonSocial;
          _rucController.text = _empresaActual!.ruc;
          _regimenSeleccionado = _empresaActual!.regimenId;
        } else {
          // Si no hay empresa y hay regímenes, seleccionar el primero
          if (regimenes.isNotEmpty) {
            _regimenSeleccionado = regimenes.first.id;
          }
        }
      });
    } catch (e) {
      setState(() {
        _cargandoDatos = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: $e')),
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
        id: _empresaActual?.id ?? 0,
        regimenId: _regimenSeleccionado!,
        nombreRazonSocial: _nombreController.text.trim(),
        ruc: _rucController.text.trim(),
      );

      if (_empresaActual != null) {
        await _databaseService.actualizarEmpresa(empresa);
      } else {
        await _databaseService.insertarEmpresa(empresa);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil de empresa guardado correctamente')),
        );
        setState(() {
          _modoEdicion = false;
        });
        _cargarDatos();
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

  void _activarEdicion() {
    setState(() {
      _modoEdicion = true;
    });
  }

  void _cancelarEdicion() {
    setState(() {
      _modoEdicion = false;
    });
    // Restaurar datos originales
    if (_empresaActual != null) {
      _nombreController.text = _empresaActual!.nombreRazonSocial;
      _rucController.text = _empresaActual!.ruc;
      _regimenSeleccionado = _empresaActual!.regimenId;
    } else {
      _nombreController.clear();
      _rucController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Empresa'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_empresaActual != null && !_modoEdicion)
            IconButton(
              onPressed: _activarEdicion,
              icon: const Icon(Icons.edit),
              tooltip: 'Editar perfil',
            ),
        ],
      ),
      body: _cargandoDatos
          ? const Center(child: CircularProgressIndicator())
          : _regimenes.isEmpty
              ? _buildNoRegimenesView()
              : _buildEmpresaView(),
    );
  }

  Widget _buildNoRegimenesView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.warning, size: 64, color: Colors.orange),
          const SizedBox(height: 16),
          const Text(
            'No hay regímenes tributarios',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Debe crear al menos un régimen tributario\nantes de configurar el perfil de empresa',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => AppRoutes.navigateTo(context, AppRoutes.regimenes),
            icon: const Icon(Icons.add),
            label: const Text('Crear Régimen'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpresaView() {
    if (_empresaActual == null && !_modoEdicion) {
      return _buildConfiguracionInicialView();
    }

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Información de la empresa
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.business, color: AppColors.primary),
                      const SizedBox(width: 8),
                      const Text(
                        'Información de la Empresa',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _nombreController,
                    enabled: _modoEdicion || _empresaActual == null,
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
                    enabled: _modoEdicion || _empresaActual == null,
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
                    onChanged: (_modoEdicion || _empresaActual == null) ? (value) {
                      setState(() {
                        _regimenSeleccionado = value;
                      });
                    } : null,
                    validator: (value) {
                      if (value == null) {
                        return 'Seleccione un régimen tributario';
                      }
                      return null;
                    },
                  ),
                  
                  if (_modoEdicion || _empresaActual == null) ...[
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        if (_modoEdicion) ...[
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isLoading ? null : _cancelarEdicion,
                              child: const Text('Cancelar'),
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                        Expanded(
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
                                    _empresaActual == null ? 'Crear Perfil' : 'Guardar Cambios',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          if (!_modoEdicion && _empresaActual != null) ...[
            const SizedBox(height: 16),
            
            // Información del régimen actual
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
                          'Régimen Tributario Actual',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_regimenSeleccionado != null)
                      FutureBuilder<RegimenTributario?>(
                        future: _databaseService.obtenerRegimenPorId(_regimenSeleccionado!),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data != null) {
                            final regimen = snapshot.data!;
                            return Text(
                              '${regimen.nombre}\nTasa de Renta: ${regimen.tasaRentaFormateada}',
                              style: const TextStyle(fontSize: 14),
                            );
                          }
                          return const Text('Cargando información del régimen...');
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConfiguracionInicialView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.business_center, size: 64, color: AppColors.primary),
          const SizedBox(height: 16),
          const Text(
            '¡Bienvenido a Compulsa!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Configure el perfil de su empresa\npara empezar a usar la aplicación',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _activarEdicion,
            icon: const Icon(Icons.add_business),
            label: const Text('Configurar Mi Empresa'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}