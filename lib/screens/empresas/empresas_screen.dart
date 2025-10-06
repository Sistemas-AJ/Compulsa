import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/database_models.dart';
import '../../models/regimen_tributario.dart';
import '../../services/database_service.dart';
import 'empresa_form_screen.dart';

class EmpresasScreen extends StatefulWidget {
  const EmpresasScreen({super.key});

  @override
  State<EmpresasScreen> createState() => _EmpresasScreenState();
}

class _EmpresasScreenState extends State<EmpresasScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<Empresa> _empresas = [];
  Map<int, RegimenTributario> _regimenes = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Cargar empresas y regímenes en paralelo
      final futures = await Future.wait([
        _databaseService.obtenerEmpresas(),
        _databaseService.obtenerRegimenes(),
      ]);

      final empresas = futures[0] as List<Empresa>;
      final regimenes = futures[1] as List<RegimenTributario>;

      // Crear mapa de regímenes para acceso rápido
      final regimenesMap = <int, RegimenTributario>{};
      for (var regimen in regimenes) {
        regimenesMap[regimen.id] = regimen;
      }

      setState(() {
        _empresas = empresas;
        _regimenes = regimenesMap;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: $e')),
        );
      }
    }
  }

  Future<void> _eliminarEmpresa(Empresa empresa) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Está seguro de eliminar la empresa "${empresa.nombreRazonSocial}"?\n\nEsta acción también eliminará todas las liquidaciones y saldos relacionados.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true && mounted) {
      try {
        await _databaseService.eliminarEmpresa(empresa.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Empresa eliminada correctamente')),
        );
        _cargarDatos();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Empresas'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _empresas.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.business, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No hay empresas registradas',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Agregue una empresa para empezar',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _cargarDatos,
                  child: ListView.builder(
                    itemCount: _empresas.length,
                    itemBuilder: (context, index) {
                      final empresa = _empresas[index];
                      final regimen = _regimenes[empresa.regimenId];
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: AppColors.primary,
                            child: Icon(Icons.business, color: Colors.white),
                          ),
                          title: Text(
                            empresa.nombreRazonSocial,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('RUC: ${empresa.ruc}'),
                              if (regimen != null)
                                Text(
                                  'Régimen: ${regimen.nombre}',
                                  style: const TextStyle(color: AppColors.textSecondary),
                                ),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'edit') {
                                final result = await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EmpresaFormScreen(
                                      empresa: empresa,
                                    ),
                                  ),
                                );
                                if (result == true) {
                                  _cargarDatos();
                                }
                              } else if (value == 'delete') {
                                _eliminarEmpresa(empresa);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: ListTile(
                                  leading: Icon(Icons.edit),
                                  title: Text('Editar'),
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: ListTile(
                                  leading: Icon(Icons.delete, color: Colors.red),
                                  title: Text('Eliminar'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => const EmpresaFormScreen(),
            ),
          );
          if (result == true) {
            _cargarDatos();
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}