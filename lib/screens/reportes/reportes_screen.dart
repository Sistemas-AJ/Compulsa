import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/cards/dashboard_card.dart';

class ReportesScreen extends StatelessWidget {
  const ReportesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
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
                // TODO: Mostrar reporte por empresa
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
              title: 'Saldos a Favor',
              subtitle: 'Historial de saldos',
              color: AppColors.saldoFavorColor,
              onTap: () {
                // TODO: Mostrar saldos
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen del Mes Actual',
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
                    'IGV Total',
                    'S/ 5,234.80',
                    AppColors.igvColor,
                    Icons.receipt,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'Renta Total',
                    'S/ 3,456.50',
                    AppColors.rentaColor,
                    Icons.account_balance_wallet,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Empresas',
                    '8',
                    AppColors.secondary,
                    Icons.business,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'Declaraciones',
                    '12',
                    AppColors.primary,
                    Icons.file_present,
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
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
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
}