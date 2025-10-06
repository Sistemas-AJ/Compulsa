import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class IgvScreen extends StatefulWidget {
  const IgvScreen({super.key});

  @override
  State<IgvScreen> createState() => _IgvScreenState();
}

class _IgvScreenState extends State<IgvScreen> {
  final _ventasController = TextEditingController();
  final _compras18Controller = TextEditingController();
  final _compras10Controller = TextEditingController();
  double _igvVentas = 0.0;
  double _igvCompras18 = 0.0;
  double _igvCompras10 = 0.0;
  double _igvTotalCompras = 0.0;
  double _igvPorPagar = 0.0;
  String _tipoEmpresa = 'general'; // 'general' o 'restaurante_hotel'
  
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
            
            // Selector de tipo de empresa
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tipo de Empresa',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('General (18%)'),
                            value: 'general',
                            groupValue: _tipoEmpresa,
                            onChanged: (value) {
                              setState(() {
                                _tipoEmpresa = value!;
                                _calcularIgv('');
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Restaurante/Hotel (10%)'),
                            value: 'restaurante_hotel',
                            groupValue: _tipoEmpresa,
                            onChanged: (value) {
                              setState(() {
                                _tipoEmpresa = value!;
                                _calcularIgv('');
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _ventasController,
              decoration: InputDecoration(
                labelText: 'Ventas Netas',
                hintText: 'Ingrese el monto de ventas sin IGV',
                prefixText: 'S/ ',
                helperText: _tipoEmpresa == 'general' 
                    ? 'IGV: 18%' 
                    : 'IGV Reducido: 10% (Restaurantes/Hoteles)',
              ),
              keyboardType: TextInputType.number,
              onChanged: _calcularIgv,
            ),
            const SizedBox(height: 16),
            
            const Text(
              'Compras Gravadas (Crédito Fiscal)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _compras18Controller,
              decoration: const InputDecoration(
                labelText: 'Compras con IGV 18%',
                hintText: 'Compras generales',
                prefixText: 'S/ ',
              ),
              keyboardType: TextInputType.number,
              onChanged: _calcularIgv,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _compras10Controller,
              decoration: const InputDecoration(
                labelText: 'Compras con IGV 10%',
                hintText: 'Compras en restaurantes/hoteles',
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
                    _buildCalculoItem(
                      'IGV de Ventas (${_tipoEmpresa == 'general' ? '18%' : '10%'})', 
                      _igvVentas
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Crédito Fiscal (IGV de Compras):',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    _buildCalculoItem('  • Compras IGV 18%', _igvCompras18),
                    _buildCalculoItem('  • Compras IGV 10%', _igvCompras10),
                    _buildCalculoItem('Total Crédito Fiscal', _igvTotalCompras, isSubTotal: true),
                    const Divider(),
                    _buildCalculoItem(
                      _igvPorPagar >= 0 ? 'IGV por Pagar' : 'Saldo a Favor', 
                      _igvPorPagar.abs(), 
                      isTotal: true,
                      isNegative: _igvPorPagar < 0
                    ),
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
      double compras18 = double.tryParse(_compras18Controller.text) ?? 0.0;
      double compras10 = double.tryParse(_compras10Controller.text) ?? 0.0;
      
      // Calcular IGV de ventas según el tipo de empresa
      if (_tipoEmpresa == 'restaurante_hotel') {
        _igvVentas = ventas * 0.10; // 10% para restaurantes y hoteles
      } else {
        _igvVentas = ventas * 0.18; // 18% general
      }
      
      // Calcular IGV de compras (crédito fiscal)
      _igvCompras18 = compras18 * 0.18;
      _igvCompras10 = compras10 * 0.10;
      _igvTotalCompras = _igvCompras18 + _igvCompras10;
      
      // IGV por pagar = IGV de ventas - Crédito fiscal
      _igvPorPagar = _igvVentas - _igvTotalCompras;
    });
  }
  
  Widget _buildCalculoItem(String label, double valor, {bool isTotal = false, bool isSubTotal = false, bool isNegative = false}) {
    Color textColor;
    Color valueColor;
    
    if (isTotal) {
      textColor = AppColors.textPrimary;
      valueColor = isNegative ? Colors.green : AppColors.igvColor;
    } else if (isSubTotal) {
      textColor = AppColors.textPrimary;
      valueColor = AppColors.textPrimary;
    } else {
      textColor = AppColors.textSecondary;
      valueColor = AppColors.textPrimary;
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isTotal ? 16 : 14,
                fontWeight: (isTotal || isSubTotal) ? FontWeight.bold : FontWeight.normal,
                color: textColor,
              ),
            ),
          ),
          Text(
            '${isNegative ? '' : ''}S/ ${valor.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: FontWeight.bold,
              color: valueColor,
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
    _compras18Controller.dispose();
    _compras10Controller.dispose();
    super.dispose();
  }
}