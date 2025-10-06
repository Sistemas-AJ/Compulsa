import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/calculo_service.dart';

class IgvScreen extends StatefulWidget {
  const IgvScreen({super.key});

  @override
  State<IgvScreen> createState() => _IgvScreenState();
}

class _IgvScreenState extends State<IgvScreen> {
  final TextEditingController _ventasGravadasController = TextEditingController();
  final TextEditingController _igvComprasController = TextEditingController();
  
  Map<String, dynamic>? _resultadoCalculo;
  bool _calculando = false;

  @override
  void dispose() {
    _ventasGravadasController.dispose();
    _igvComprasController.dispose();
    super.dispose();
  }

  Future<void> _calcularIgv() async {
    if (_ventasGravadasController.text.isEmpty || _igvComprasController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor complete todos los campos')),
      );
      return;
    }

    setState(() {
      _calculando = true;
    });

    try {
      final ventasGravadas = double.parse(_ventasGravadasController.text);
      final igvCompras = double.parse(_igvComprasController.text);

      final resultado = await CalculoService.calcularIgv(
        ingresosGravados: ventasGravadas,
        igvCompras: igvCompras,
      );

      if (!mounted) return;
      
      setState(() {
        _resultadoCalculo = resultado;
        _calculando = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _calculando = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error en el cálculo: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cálculo de IGV'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Ingrese los datos para calcular el IGV',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            
            TextFormField(
              controller: _ventasGravadasController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Ventas Gravadas',
                hintText: 'Ingrese el monto de ventas gravadas',
                prefixText: 'S/. ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _igvComprasController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'IGV de Compras',
                hintText: 'Ingrese el IGV de compras',
                prefixText: 'S/. ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            
            ElevatedButton(
              onPressed: _calculando ? null : _calcularIgv,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _calculando
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Calcular IGV', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 24),
            
            if (_resultadoCalculo != null) _buildResultadoCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildResultadoCard() {
    final igvVentas = _resultadoCalculo!['igvVentas'] as double;
    final igvPorPagar = _resultadoCalculo!['igvPorPagar'] as double;
    final tieneSaldoAFavor = igvPorPagar < 0;
    final saldoAFavor = tieneSaldoAFavor ? igvPorPagar.abs() : 0.0;
    final montoAPagar = tieneSaldoAFavor ? 0.0 : igvPorPagar;

    return Card(
      margin: const EdgeInsets.only(top: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resultado del Cálculo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            _buildResultadoItem('IGV de Ventas', igvVentas),
            _buildResultadoItem('IGV de Compras', _resultadoCalculo!['igvCompras']),
            const Divider(),
            
            if (tieneSaldoAFavor) ...[
              _buildResultadoItem('Saldo a Favor', saldoAFavor, isTotal: true, isPositive: true),
            ] else ...[
              _buildResultadoItem('IGV por Pagar', montoAPagar, isTotal: true, isPositive: false),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultadoItem(String label, double valor, {bool isTotal = false, bool isPositive = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            'S/. ',
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal 
                ? (isPositive ? Colors.green : Colors.red)
                : null,
            ),
          ),
        ],
      ),
    );
  }
}
