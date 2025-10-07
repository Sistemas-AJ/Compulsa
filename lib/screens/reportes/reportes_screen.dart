import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/cards/dashboard_card.dart';
import '../../widgets/compulsa_appbar.dart';
import '../../services/historial_igv_service.dart';
import '../../services/historial_renta_service.dart';
import '../../models/historial_igv.dart';
import '../../models/historial_renta.dart';
import 'estadisticas_empresariales_screen.dart';
import 'evolucion_mensual_screen.dart';

class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key});

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  List<HistorialIGV> _historialIGV = [];
  List<HistorialRenta> _historialRenta = [];
  Map<String, dynamic>? _resumenIGV;
  Map<String, dynamic>? _resumenRenta;
  bool _cargandoDatos = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      // Cargar datos de IGV
      final historialIGV = await HistorialIGVService.obtenerTodosLosCalculos();
      final resumenIGV = await HistorialIGVService.obtenerResumenReciente();

      // Cargar datos de Renta
      final historialRenta = await HistorialRentaService.obtenerHistorial();
      final estadisticasRenta =
          await HistorialRentaService.obtenerEstadisticas();

      if (mounted) {
        setState(() {
          _historialIGV = historialIGV;
          _historialRenta = historialRenta;
          _resumenIGV = resumenIGV;
          _resumenRenta = estadisticasRenta;
          _cargandoDatos = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _cargandoDatos = false;
        });
      }
      print('Error al cargar datos del historial: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CompulsaAppBar(title: 'Reportes'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Análisis Tributario',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            _buildResumenMensual(),
            const SizedBox(height: 24),
            const Text(
              'Reportes Disponibles',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            DashboardCard(
              icon: Icons.pie_chart,
              title: 'Resumen General',
              subtitle: 'IGV y Renta por empresa',
              color: AppColors.primary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const EstadisticasEmpresarialesScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            DashboardCard(
              icon: Icons.trending_up,
              title: 'Evolución Mensual',
              subtitle: 'Tendencia de impuestos',
              color: AppColors.secondary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EvolucionMensualScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            DashboardCard(
              icon: Icons.account_balance,
              title: 'Historial de Cálculos IGV',
              subtitle: 'Registro de todos los cálculos de IGV realizados',
              color: AppColors.saldoFavorColor,
              onTap: () {
                _mostrarHistorialIGV();
              },
            ),
            const SizedBox(height: 12),
            DashboardCard(
              icon: Icons.assignment,
              title: 'Historial de Cálculos Renta',
              subtitle: 'Registro de todos los cálculos de Renta realizados',
              color: AppColors.igvColor,
              onTap: () {
                _mostrarHistorialRenta();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenMensual() {
    if (_cargandoDatos) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Cargando datos...',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    final resumen = _resumenIGV;
    final ultimoSaldo = resumen?['ultimo_saldo'] ?? 0.0;
    final totalCalculos = resumen?['total_calculos'] ?? 0;
    final totalIgvPagado = resumen?['total_igv_pagado'] ?? 0.0;
    final totalSaldoFavor = resumen?['total_saldo_favor'] ?? 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen de Cálculos IGV',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Saldo a Favor Actual',
                    'S/ ${ultimoSaldo.toStringAsFixed(2)}',
                    ultimoSaldo > 0
                        ? AppColors.saldoFavorColor
                        : AppColors.igvColor,
                    Icons.account_balance_wallet,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'IGV Acumulado',
                    'S/ ${totalIgvPagado.toStringAsFixed(2)}',
                    AppColors.igvColor,
                    Icons.payment,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Cálculos',
                    totalCalculos.toString(),
                    AppColors.primary,
                    Icons.calculate,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'Saldo a Favor Acumulado',
                    'S/ ${totalSaldoFavor.toStringAsFixed(2)}',
                    AppColors.saldoFavorColor,
                    Icons.trending_up,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    String titulo,
    String valor,
    Color color,
    IconData icono,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icono, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            valor,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            titulo,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _mostrarOpcionesHistorial() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_sweep, color: Colors.red),
              title: const Text('Limpiar todo el historial'),
              subtitle: const Text('Eliminar todos los cálculos guardados'),
              onTap: () {
                Navigator.pop(context);
                _limpiarTodoElHistorial();
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Cancelar'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _limpiarTodoElHistorial() async {
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Limpiar Historial'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning, color: Colors.orange, size: 48),
              const SizedBox(height: 16),
              const Text(
                '¿Estás seguro de que deseas eliminar TODOS los cálculos del historial?',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Se eliminarán ${_historialIGV.length} cálculos.',
                style: const TextStyle(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Esta acción no se puede deshacer.',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Eliminar Todo'),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      try {
        await HistorialIGVService.limpiarHistorial();

        // Recargar datos
        await _cargarDatos();

        if (mounted) {
          Navigator.pop(context); // Cerrar el modal del historial
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Historial eliminado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar el historial: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _eliminarCalculo(HistorialIGV calculo) async {
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar Cálculo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('¿Estás seguro de que deseas eliminar este cálculo?'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fecha: ${calculo.fechaFormateada}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text('Tipo: ${calculo.tipoNegocioFormatted}'),
                    Text(calculo.resumenCalculo),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Esta acción no se puede deshacer.',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      // Mostrar indicador de carga
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 16),
                Text('Eliminando cálculo...'),
              ],
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }

      try {
        // Eliminar directamente de la lista local primero para feedback inmediato
        setState(() {
          _historialIGV.removeWhere((item) => item.id == calculo.id);
        });

        // Luego eliminar de la base de datos
        await HistorialIGVService.eliminarCalculo(calculo.id);

        // Recargar datos para asegurar sincronización
        await _cargarDatos();

        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cálculo eliminado correctamente'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        // Si hay error, recargar datos para restaurar el estado
        await _cargarDatos();

        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  // ==================== MÉTODOS PARA HISTORIAL DE RENTA ====================

  Future<void> _eliminarCalculoRenta(HistorialRenta calculo) async {
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar Cálculo de Renta'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('¿Estás seguro de que deseas eliminar este cálculo?'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fecha: ${calculo.fechaFormateada}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text('Régimen: ${calculo.regimenFormatted}'),
                    Text(calculo.resumenCalculo),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Esta acción no se puede deshacer.',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      // Mostrar indicador de carga
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 16),
                Text('Eliminando cálculo de renta...'),
              ],
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }

      try {
        // Eliminar directamente de la lista local primero para feedback inmediato
        setState(() {
          _historialRenta.removeWhere((item) => item.id == calculo.id);
        });

        // Luego eliminar de la base de datos
        await HistorialRentaService.eliminarCalculo(calculo.id);

        // Recargar datos para asegurar sincronización
        await _cargarDatos();

        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cálculo de renta eliminado correctamente'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        // Si hay error, recargar datos para restaurar el estado
        await _cargarDatos();

        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  void _mostrarOpcionesHistorialRenta() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_sweep, color: Colors.red),
              title: const Text('Limpiar todo el historial de Renta'),
              subtitle: const Text(
                'Eliminar todos los cálculos de renta guardados',
              ),
              onTap: () {
                Navigator.pop(context);
                _limpiarTodoElHistorialRenta();
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Cancelar'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _limpiarTodoElHistorialRenta() async {
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Limpiar Historial de Renta'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning, color: Colors.orange, size: 48),
              const SizedBox(height: 16),
              const Text(
                '¿Estás seguro de que deseas eliminar TODOS los cálculos de renta del historial?',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Se eliminarán ${_historialRenta.length} cálculos.',
                style: const TextStyle(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Esta acción no se puede deshacer.',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Eliminar Todo'),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      try {
        await HistorialRentaService.eliminarTodos();

        // Recargar datos
        await _cargarDatos();

        if (mounted) {
          Navigator.pop(context); // Cerrar el modal del historial
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Historial de renta eliminado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar el historial de renta: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _mostrarHistorialRenta() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 8),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.assignment, color: AppColors.igvColor),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Historial de Cálculos Renta',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_historialRenta.isNotEmpty)
                          IconButton(
                            onPressed: _mostrarOpcionesHistorialRenta,
                            icon: const Icon(Icons.more_vert),
                            tooltip: 'Opciones',
                          ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Content
              Expanded(
                child: _historialRenta.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.assignment_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay cálculos de renta registrados',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Los cálculos aparecerán aquí una vez que realices tu primer cálculo de Renta',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _historialRenta.length,
                        itemBuilder: (context, index) {
                          final calculo = _historialRenta[index];
                          return _buildHistorialRentaCard(calculo);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistorialRentaCard(HistorialRenta calculo) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        calculo.fechaFormateada,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: calculo.debePagar
                              ? AppColors.igvColor.withOpacity(0.1)
                              : AppColors.saldoFavorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          calculo.regimenFormatted,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: calculo.debePagar
                                ? AppColors.igvColor
                                : AppColors.saldoFavorColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _eliminarCalculoRenta(calculo),
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red[400],
                  tooltip: 'Eliminar cálculo',
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  padding: const EdgeInsets.all(4),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildResumenItemRenta(
                    'Ingresos',
                    'S/ ${calculo.ingresos.toStringAsFixed(2)}',
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildResumenItemRenta(
                    'Gastos',
                    'S/ ${calculo.gastos.toStringAsFixed(2)}',
                    Icons.trending_down,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: calculo.debePagar
                    ? AppColors.igvColor.withOpacity(0.1)
                    : calculo.tienePerdida
                    ? Colors.orange.withOpacity(0.1)
                    : AppColors.saldoFavorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    calculo.resumenCalculo,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: calculo.debePagar
                          ? AppColors.igvColor
                          : calculo.tienePerdida
                          ? Colors.orange[700]
                          : AppColors.saldoFavorColor,
                    ),
                  ),
                  if (calculo.usandoCoeficiente)
                    Text(
                      'Con coeficiente',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenItemRenta(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== MÉTODOS PARA HISTORIAL DE IGV ====================

  void _mostrarHistorialIGV() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 8),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.history, color: AppColors.primary),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Historial de Cálculos IGV',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_historialIGV.isNotEmpty)
                          IconButton(
                            onPressed: _mostrarOpcionesHistorial,
                            icon: const Icon(Icons.more_vert),
                            tooltip: 'Opciones',
                          ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Content
              Expanded(
                child: _historialIGV.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history_toggle_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay cálculos registrados',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Los cálculos aparecerán aquí una vez que realices tu primer cálculo de IGV',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _historialIGV.length,
                        itemBuilder: (context, index) {
                          final calculo = _historialIGV[index];
                          return _buildHistorialCard(calculo);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistorialCard(HistorialIGV calculo) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        calculo.fechaFormateada,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: calculo.tieneSaldoAFavor
                              ? AppColors.saldoFavorColor.withOpacity(0.1)
                              : AppColors.igvColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          calculo.tipoNegocioFormatted,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: calculo.tieneSaldoAFavor
                                ? AppColors.saldoFavorColor
                                : AppColors.igvColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _eliminarCalculo(calculo),
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red[400],
                  tooltip: 'Eliminar cálculo',
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  padding: const EdgeInsets.all(4),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildResumenItem(
                    'Ventas',
                    'S/ ${calculo.ventasGravadas.toStringAsFixed(2)}',
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildResumenItem(
                    'Compras',
                    'S/ ${(calculo.compras18 + calculo.compras10).toStringAsFixed(2)}',
                    Icons.shopping_cart,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: calculo.tieneSaldoAFavor
                    ? AppColors.saldoFavorColor.withOpacity(0.1)
                    : AppColors.igvColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    calculo.resumenCalculo,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: calculo.tieneSaldoAFavor
                          ? AppColors.saldoFavorColor
                          : AppColors.igvColor,
                    ),
                  ),
                  if (calculo.saldoAnterior > 0)
                    Text(
                      'Saldo anterior: S/ ${calculo.saldoAnterior.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
