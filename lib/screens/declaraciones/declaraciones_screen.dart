import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../config/routes.dart';
import '../../widgets/compulsa_appbar.dart';

class DeclaracionesScreen extends StatefulWidget {
  const DeclaracionesScreen({super.key});

  @override
  State<DeclaracionesScreen> createState() => _DeclaracionesScreenState();
}

class _DeclaracionesScreenState extends State<DeclaracionesScreen> {
  final List<Map<String, dynamic>> _declaraciones = [
    {
      'id': '001',
      'empresa': 'ABC Consultores S.A.C.',
      'tipo': 'IGV',
      'periodo': 'Septiembre 2024',
      'monto': 2456.80,
      'estado': 'Presentada',
      'fecha': '15/10/2024',
    },
    {
      'id': '002',
      'empresa': 'Juan Pérez Contadores',
      'tipo': 'Renta',
      'periodo': 'Septiembre 2024',
      'monto': 1234.50,
      'estado': 'Pendiente',
      'fecha': '10/10/2024',
    },
    {
      'id': '003',
      'empresa': 'ABC Consultores S.A.C.',
      'tipo': 'IGV',
      'periodo': 'Agosto 2024',
      'monto': 1876.30,
      'estado': 'Presentada',
      'fecha': '15/09/2024',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CompulsaAppBar(
        title: 'Declaraciones',
        additionalActions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implementar filtros
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _declaraciones.length,
        itemBuilder: (context, index) {
          final declaracion = _declaraciones[index];
          return _buildDeclaracionCard(declaracion);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AppRoutes.navigateTo(context, AppRoutes.declaracionForm),
        backgroundColor: AppColors.secondary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDeclaracionCard(Map<String, dynamic> declaracion) {
    Color tipoColor = declaracion['tipo'] == 'IGV' ? AppColors.igvColor : AppColors.rentaColor;
    Color estadoColor = declaracion['estado'] == 'Presentada' ? AppColors.success : AppColors.warning;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: tipoColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    declaracion['tipo'],
                    style: TextStyle(
                      fontSize: 12,
                      color: tipoColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: estadoColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    declaracion['estado'],
                    style: TextStyle(
                      fontSize: 12,
                      color: estadoColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'N° ${declaracion['id']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              declaracion['empresa'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Período: ${declaracion['periodo']}',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monto:',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      'S/ ${declaracion['monto'].toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: tipoColor,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Fecha:',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      declaracion['fecha'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    // TODO: Ver detalles
                  },
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('Ver'),
                ),
                TextButton.icon(
                  onPressed: () {
                    // TODO: Descargar PDF
                  },
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('PDF'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}