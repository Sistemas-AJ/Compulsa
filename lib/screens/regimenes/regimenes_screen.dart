import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/regimen_tributario.dart';
import '../../services/regimen_tributario_service.dart';
import 'regimen_form_screen.dart';

class RegimenesScreen extends StatefulWidget {
  const RegimenesScreen({super.key});

  @override
  State<RegimenesScreen> createState() => _RegimenesScreenState();
}

class _RegimenesScreenState extends State<RegimenesScreen> {
  List<RegimenTributario> _regimenes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarRegimenes();
  }

  Future<void> _cargarRegimenes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final regimenes = await RegimenTributarioService.getAllRegimenes();
      setState(() {
        _regimenes = regimenes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar regímenes: $e')),
        );
      }
    }
  }

  Future<void> _eliminarRegimen(RegimenTributario regimen) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Está seguro de eliminar el régimen "${regimen.nombre}"?'),
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
        await RegimenTributarioService.deleteRegimen(regimen.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Régimen eliminado correctamente')),
        );
        _cargarRegimenes();
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
        title: const Text('Regímenes Tributarios'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _regimenes.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.account_balance, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No hay regímenes tributarios',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Agregue un régimen para empezar',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _cargarRegimenes,
                  child: ListView.builder(
                    itemCount: _regimenes.length,
                    itemBuilder: (context, index) {
                      final regimen = _regimenes[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: AppColors.primary,
                            child: Icon(Icons.account_balance, color: Colors.white),
                          ),
                          title: Text(
                            regimen.nombre,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Tasa: ${regimen.tasaRentaFormateada}',
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'edit') {
                                final result = await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RegimenFormScreen(
                                      regimen: regimen,
                                    ),
                                  ),
                                );
                                if (result == true) {
                                  _cargarRegimenes();
                                }
                              } else if (value == 'delete') {
                                _eliminarRegimen(regimen);
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
              builder: (context) => const RegimenFormScreen(),
            ),
          );
          if (result == true) {
            _cargarRegimenes();
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}