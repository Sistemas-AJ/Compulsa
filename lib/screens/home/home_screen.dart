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
            _buildRecentActivitySection(),
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
                icon: Icons.business,
                title: 'Empresas',
                subtitle: 'Gestionar empresas',
                color: AppColors.primary,
                onTap: () => AppRoutes.navigateTo(context, AppRoutes.empresas),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                context,
                icon: Icons.calculate,
                title: 'Calcular',
                subtitle: 'IGV y Renta',
                color: AppColors.secondary,
                onTap: () => AppRoutes.navigateTo(context, AppRoutes.calculos),
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
      ],
    );
  }

  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actividad Reciente',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildActivityItem(
                  icon: Icons.add_business,
                  title: 'Empresa registrada',
                  subtitle: 'ABC Consultores S.A.C.',
                  time: 'Hace 2 horas',
                ),
                const Divider(),
                _buildActivityItem(
                  icon: Icons.calculate,
                  title: 'Cálculo IGV realizado',
                  subtitle: 'Periodo: Septiembre 2024',
                  time: 'Hace 1 día',
                ),
                const Divider(),
                _buildActivityItem(
                  icon: Icons.file_present,
                  title: 'Declaración generada',
                  subtitle: 'PDT 621 - IGV',
                  time: 'Hace 3 días',
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

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
        child: Icon(
          icon,
          color: AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
        ),
      ),
      trailing: Text(
        time,
        style: TextStyle(
          color: AppColors.textHint,
          fontSize: 11,
        ),
      ),
    );
  }
}