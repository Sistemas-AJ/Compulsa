import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../models/database_models.dart';
import '../../models/regimen_tributario.dart';
import '../../services/database_service.dart';

class PerfilUsuarioScreen extends StatefulWidget {
  const PerfilUsuarioScreen({Key? key}) : super(key: key);

  @override
  State<PerfilUsuarioScreen> createState() => _PerfilUsuarioScreenState();
}

class _PerfilUsuarioScreenState extends State<PerfilUsuarioScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _rucController = TextEditingController();
  
  bool _cargandoDatos = false;
  bool _modoEdicion = false;
  
  Empresa? _empresaActual;
  List<RegimenTributario> _regimenes = [];
  int? _regimenSeleccionado;
  RegimenTributario? _regimenActual;
  
  final ImagePicker _picker = ImagePicker();
  String? _imagenPerfilPath;

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
        
        if (_empresaActual != null) {
          _nombreController.text = _empresaActual!.nombreRazonSocial;
          _rucController.text = _empresaActual!.ruc;
          _imagenPerfilPath = _empresaActual!.imagenPerfil;
          
          final regimenExiste = regimenes.any((r) => r.id == _empresaActual!.regimenId);
          if (regimenExiste) {
            _regimenSeleccionado = _empresaActual!.regimenId;
            _regimenActual = regimenes.firstWhere((r) => r.id == _empresaActual!.regimenId);
          } else if (regimenes.isNotEmpty) {
            _regimenSeleccionado = regimenes.first.id;
            _regimenActual = regimenes.first;
          }
        } else {
          if (regimenes.isNotEmpty) {
            _regimenSeleccionado = regimenes.first.id;
            _regimenActual = regimenes.first;
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

  Future<void> _seleccionarImagen() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      
      if (image != null) {
        // Guardar la imagen en el directorio de la aplicación
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String fileName = 'perfil_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final String localPath = '${appDir.path}/$fileName';
        
        // Copiar la imagen al directorio local
        await File(image.path).copy(localPath);
        
        setState(() {
          _imagenPerfilPath = localPath;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar imagen: $e')),
        );
      }
    }
  }

  Future<void> _guardarPerfil() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_regimenSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione un régimen tributario')),
      );
      return;
    }

    setState(() {
      _cargandoDatos = true;
    });

    try {
      final empresa = Empresa(
        id: _empresaActual?.id,
        regimenId: _regimenSeleccionado!,
        nombreRazonSocial: _nombreController.text.trim(),
        ruc: _rucController.text.trim(),
        imagenPerfil: _imagenPerfilPath,
      );

      if (_empresaActual == null) {
        await _databaseService.insertarEmpresa(empresa);
      } else {
        await _databaseService.actualizarEmpresa(empresa);
      }

      setState(() {
        _cargandoDatos = false;
        _modoEdicion = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil guardado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        _cargarDatos();
      }
    } catch (e) {
      setState(() {
        _cargandoDatos = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
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
    
    final firstDigit = int.parse(ruc[0]);
    if (firstDigit != 1 && firstDigit != 2) {
      return 'El RUC debe comenzar con 1 o 2';
    }
    
    return null;
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _modoEdicion || _empresaActual == null ? _seleccionarImagen : null,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  backgroundImage: _imagenPerfilPath != null && File(_imagenPerfilPath!).existsSync()
                      ? FileImage(File(_imagenPerfilPath!))
                      : null,
                  child: _imagenPerfilPath == null || !File(_imagenPerfilPath!).existsSync()
                      ? const Icon(
                          Icons.business,
                          size: 50,
                          color: Colors.white,
                        )
                      : null,
                ),
                if (_modoEdicion || _empresaActual == null)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _empresaActual?.nombreRazonSocial ?? 'Mi Empresa',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          if (_empresaActual?.ruc != null)
            Text(
              'RUC: ${_empresaActual!.ruc}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRegimenInfo() {
    if (_regimenActual == null) return const SizedBox.shrink();
    
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                const Text(
                  'Régimen Tributario',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _regimenActual!.nombre,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTasaCard(
                          'Impuesto a la Renta',
                          _regimenActual!.tasaRentaFormateada,
                          Colors.orange,
                          Icons.trending_up,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTasaCard(
                          'IGV',
                          _regimenActual!.tasaIGVFormateada,
                          _regimenActual!.pagaIGV ? Colors.green : Colors.grey,
                          Icons.receipt,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasaCard(String titulo, String tasa, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            titulo,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            tasa,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormulario() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Información de la Empresa',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (!_modoEdicion && _empresaActual != null)
                    IconButton(
                      onPressed: () => setState(() => _modoEdicion = true),
                      icon: const Icon(Icons.edit),
                      tooltip: 'Editar información',
                    ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nombreController,
                enabled: _modoEdicion || _empresaActual == null,
                decoration: const InputDecoration(
                  labelText: 'Nombre o Razón Social',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre es obligatorio';
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
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
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
                value: _regimenes.any((r) => r.id == _regimenSeleccionado) 
                       ? _regimenSeleccionado 
                       : null,
                decoration: const InputDecoration(
                  labelText: 'Régimen Tributario',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_balance),
                ),
                items: _regimenes.map((regimen) {
                  return DropdownMenuItem<int>(
                    value: regimen.id,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(regimen.nombre),
                        Text(
                          'Renta: ${regimen.tasaRentaFormateada} • IGV: ${regimen.tasaIGVFormateada}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (_modoEdicion || _empresaActual == null) ? (value) {
                  setState(() {
                    _regimenSeleccionado = value;
                    _regimenActual = _regimenes.firstWhere((r) => r.id == value);
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
                          onPressed: () {
                            setState(() => _modoEdicion = false);
                            _cargarDatos();
                          },
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _cargandoDatos ? null : _guardarPerfil,
                        child: _cargandoDatos 
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(_empresaActual == null ? 'Crear Perfil' : 'Guardar'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _cargandoDatos
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(),
                  if (_regimenActual != null && !_modoEdicion && _empresaActual != null)
                    _buildRegimenInfo(),
                  _buildFormulario(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}