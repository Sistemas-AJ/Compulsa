import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class RentaScreen extends StatefulWidget {
  const RentaScreen({super.key});

  @override
  State<RentaScreen> createState() => _RentaScreenState();
}

class _RentaScreenState extends State<RentaScreen> {
  final _ingresosController = TextEditingController();
  final _gastosController = TextEditingController();
  String _regimenSeleccionado = 'General';
  double _rentaNeta = 0.0;
  double _impuestoRenta = 0.0;
  
  final List<String> _regimenes = ['General', 'MYPE', 'Especial'];
  final Map<String, double> _tasas = {
    'General': 0.015,
    'MYPE': 0.01,
    'Especial': 0.015,
  };
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Impuesto a la Renta'),
        backgroundColor: AppColors.rentaColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cálculo del Impuesto a la Renta',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              initialValue: _regimenSeleccionado,
              decoration: const InputDecoration(
                labelText: 'Régimen Tributario',
              ),
              items: _regimenes.map((String regimen) {
                return DropdownMenuItem<String>(
                  value: regimen,
                  child: Text('$regimen (${(_tasas[regimen]! * 100).toStringAsFixed(1)}%)'),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _regimenSeleccionado = newValue!;
                  _calcularRenta();
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ingresosController,
              decoration: const InputDecoration(
                labelText: 'Ingresos del Período',
                hintText: 'Ingrese los ingresos totales',
                prefixText: 'S/ ',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) => _calcularRenta(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _gastosController,
              decoration: const InputDecoration(
                labelText: 'Gastos Deducibles',
                hintText: 'Ingrese los gastos deducibles',
                prefixText: 'S/ ',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) => _calcularRenta(),
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
                    _buildCalculoItem('Ingresos', double.tryParse(_ingresosController.text) ?? 0.0),
                    _buildCalculoItem('Gastos Deducibles', double.tryParse(_gastosController.text) ?? 0.0),
                    _buildCalculoItem('Renta Neta', _rentaNeta),
                    const Divider(),
                    _buildCalculoItem(
                      'Impuesto a la Renta (${(_tasas[_regimenSeleccionado]! * 100).toStringAsFixed(1)}%)', 
                      _impuestoRenta, 
                      isTotal: true
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _impuestoRenta > 0 ? _guardarCalculo : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.rentaColor,
                ),
                child: const Text('Guardar Cálculo'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _calcularRenta() {
    setState(() {
      double ingresos = double.tryParse(_ingresosController.text) ?? 0.0;
      double gastos = double.tryParse(_gastosController.text) ?? 0.0;
      
      _rentaNeta = ingresos - gastos;
      _impuestoRenta = _rentaNeta > 0 ? _rentaNeta * _tasas[_regimenSeleccionado]! : 0.0;
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
              color: isTotal ? AppColors.rentaColor : AppColors.textPrimary,
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
        content: Text('Cálculo de Renta guardado correctamente'),
        backgroundColor: AppColors.success,
      ),
    );
  }
  
  @override
  void dispose() {
    _ingresosController.dispose();
    _gastosController.dispose();
    super.dispose();
  }
}