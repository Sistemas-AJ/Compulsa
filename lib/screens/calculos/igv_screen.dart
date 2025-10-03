import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class IgvScreen extends StatefulWidget {
  const IgvScreen({super.key});

  @override
  State<IgvScreen> createState() => _IgvScreenState();
}

class _IgvScreenState extends State<IgvScreen> {
  final _ventasController = TextEditingController();
  final _comprasController = TextEditingController();
  double _igvVentas = 0.0;
  double _igvCompras = 0.0;
  double _igvPorPagar = 0.0;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cálculo de IGV'),
        backgroundColor: AppColors.igvColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ingrese los datos del período',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _ventasController,
              decoration: const InputDecoration(
                labelText: 'Ventas Gravadas',
                hintText: 'Ingrese el monto de ventas',
                prefixText: 'S/ ',
              ),
              keyboardType: TextInputType.number,
              onChanged: _calcularIgv,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _comprasController,
              decoration: const InputDecoration(
                labelText: 'Compras Gravadas',
                hintText: 'Ingrese el monto de compras',
                prefixText: 'S/ ',
              ),
              keyboardType: TextInputType.number,
              onChanged: _calcularIgv,
            ),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Resumen del Cálculo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCalculoItem('IGV de Ventas (18%)', _igvVentas),
                    _buildCalculoItem('IGV de Compras (18%)', _igvCompras),
                    const Divider(),
                    _buildCalculoItem('IGV por Pagar', _igvPorPagar, isTotal: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _igvPorPagar > 0 ? _guardarCalculo : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.igvColor,
                ),
                child: const Text('Guardar Cálculo'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _calcularIgv(String value) {
    setState(() {
      double ventas = double.tryParse(_ventasController.text) ?? 0.0;
      double compras = double.tryParse(_comprasController.text) ?? 0.0;
      
      _igvVentas = ventas * 0.18;
      _igvCompras = compras * 0.18;
      _igvPorPagar = _igvVentas - _igvCompras;
    });
  }
  
  Widget _buildCalculoItem(String label, double valor, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
          Text(
            'S/ ${valor.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: FontWeight.bold,
              color: isTotal ? AppColors.igvColor : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
  
  void _guardarCalculo() {
    // TODO: Guardar cálculo en base de datos
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cálculo de IGV guardado correctamente'),
        backgroundColor: AppColors.success,
      ),
    );
  }
  
  @override
  void dispose() {
    _ventasController.dispose();
    _comprasController.dispose();
    super.dispose();
  }
}