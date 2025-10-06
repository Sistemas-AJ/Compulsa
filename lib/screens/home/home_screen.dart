import 'package:flutter/material.dart';
import '../../config/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/cards/dashboard_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compulsa - Asistente Tributario'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(),
            const SizedBox(height: 24),
            _buildQuickAccessSection(context),
            const SizedBox(height: 24),
            _buildMainActionsSection(context),
            const SizedBox(height: 24),
            _buildRecentActivitySection(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AppRoutes.navigateTo(context, AppRoutes.calculos),
        icon: const Icon(Icons.calculate),
        label: const Text('Calcular'),
        backgroundColor: AppColors.secondary,
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¡Bienvenido!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tu asistente tributario inteligente para Perú',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white70, size: 18),
              SizedBox(width: 8),
              Text(
                'Cálculo automático de IGV y Renta',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white70, size: 18),
              SizedBox(width: 8),
              Text(
                'Gestión de saldos a favor',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white70, size: 18),
              SizedBox(width: 8),
              Text(
                'Control fiscal completo',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Acceso Rápido',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                context,
                icon: Icons.calculate,
                title: 'Calcular IGV',
                subtitle: 'Impuesto General a las Ventas',
                color: AppColors.igvColor,
                onTap: () => AppRoutes.navigateTo(context, AppRoutes.igv),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                context,
                icon: Icons.account_balance_wallet,
                title: 'Calcular Renta',
                subtitle: 'Impuesto a la Renta',
                color: AppColors.rentaColor,
                onTap: () => AppRoutes.navigateTo(context, AppRoutes.renta),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMainActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Funciones Principales',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        DashboardCard(
          icon: Icons.account_balance,
          title: 'Declaraciones',
          subtitle: 'Gestionar declaraciones mensuales',
          color: AppColors.igvColor,
          onTap: () => AppRoutes.navigateTo(context, AppRoutes.declaraciones),
        ),
        const SizedBox(height: 12),
        DashboardCard(
          icon: Icons.bar_chart,
          title: 'Reportes',
          subtitle: 'Análisis y reportes tributarios',
          color: AppColors.rentaColor,
          onTap: () => AppRoutes.navigateTo(context, AppRoutes.reportes),
        ),
        const SizedBox(height: 24),
        
        // Configuración
        const Text(
          'Configuración',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        DashboardCard(
          icon: Icons.account_balance_wallet,
          title: 'Regímenes Tributarios',
          subtitle: 'Gestionar regímenes y tasas',
          color: Colors.indigo,
          onTap: () => AppRoutes.navigateTo(context, AppRoutes.regimenes),
        ),
        const SizedBox(height: 12),
        DashboardCard(
          icon: Icons.business,
          title: 'Empresas',
          subtitle: 'Gestionar empresas contribuyentes',
          color: Colors.teal,
          onTap: () => AppRoutes.navigateTo(context, AppRoutes.empresa),
        ),
      ],
    );
  }

  Widget _buildRecentActivitySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Actividad Reciente',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton.icon(
              onPressed: () => AppRoutes.navigateTo(context, AppRoutes.actividadReciente),
              icon: const Icon(Icons.history, size: 18),
              label: const Text('Ver todo'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Aquí verás tu actividad real una vez que realices cálculos, configuraciones o creaciones.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => AppRoutes.navigateTo(context, AppRoutes.actividadReciente),
                    icon: const Icon(Icons.history),
                    label: const Text('Ver Actividad Reciente'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}