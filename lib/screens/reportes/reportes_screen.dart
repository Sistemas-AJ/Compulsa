import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/cards/dashboard_card.dart';
import '../../widgets/compulsa_appbar.dart';
import '../../services/historial_igv_service.dart';
import '../../models/historial_igv.dart';
import 'estadisticas_empresariales_screen.dart';

class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key});

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  List<HistorialIGV> _historialIGV = [];
  Map<String, dynamic>? _resumenIGV;
  bool _cargandoDatos = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      final historial = await HistorialIGVService.obtenerTodosLosCalculos();
      final resumen = await HistorialIGVService.obtenerResumenReciente();
      
      if (mounted) {
        setState(() {
          _historialIGV = historial;
          _resumenIGV = resumen;
          _cargandoDatos = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _cargandoDatos = false;
        });
      }
      print('Error al cargar datos del historial IGV: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CompulsaAppBar(
        title: 'Reportes',
      ),
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
              title: 'Resumen por Empresa',
              subtitle: 'IGV y Renta por empresa',
              color: AppColors.primary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EstadisticasEmpresarialesScreen(),
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
                // TODO: Mostrar evolución
              },
            ),
            const SizedBox(height: 12),
            DashboardCard(
              icon: Icons.account_balance,
              title: 'Historial de Cálculos IGV',
              subtitle: 'Registro de todos los cálculos realizados',
              color: AppColors.saldoFavorColor,
              onTap: () {
                _mostrarHistorialIGV();
              },
            ),
            const SizedBox(height: 12),
            DashboardCard(
              icon: Icons.calendar_today,
              title: 'Calendario Tributario',
              subtitle: 'Fechas importantes',
              color: AppColors.warning,
              onTap: () {
                // TODO: Mostrar calendario
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
                    'Saldo Actual',
                    'S/ ${ultimoSaldo.toStringAsFixed(2)}',
                    ultimoSaldo > 0 ? AppColors.saldoFavorColor : AppColors.igvColor,
                    Icons.account_balance_wallet,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'IGV Pagado',
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
                    'Saldo a Favor',
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
  
  Widget _buildMetricCard(String titulo, String valor, Color color, IconData icono) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(
            icono,
            color: color,
            size: 24,
          ),
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
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

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
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
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
                Text(
                  calculo.fechaFormateada,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenItem(String label, String value, IconData icon, Color color) {
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
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
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