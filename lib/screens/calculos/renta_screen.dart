import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/calculo_service.dart';
import '../../services/regimen_tributario_service.dart';
import '../../services/actividad_reciente_service.dart';
import '../../models/regimen_tributario.dart';
import '../../config/routes.dart';

class RentaScreen extends StatefulWidget {
  const RentaScreen({super.key});

  @override
  State<RentaScreen> createState() => _RentaScreenState();
}

class _RentaScreenState extends State<RentaScreen> {
  final _ingresosController = TextEditingController();
  
  int? _regimenSeleccionado;
  Map<String, dynamic>? _resultadoCalculo;
  bool _isCalculating = false;
  
  List<RegimenTributario> _regimenes = [];
  bool _cargandoRegimenes = true;

  @override
  void initState() {
    super.initState();
    _cargarRegimenes();
  }

  Future<void> _cargarRegimenes() async {
    try {
      final regimenes = await RegimenTributarioService.getAllRegimenes();
      setState(() {
        _regimenes = regimenes;
        _cargandoRegimenes = false;
        // Seleccionar el primer régimen por defecto
        if (_regimenes.isNotEmpty) {
          _regimenSeleccionado = _regimenes.first.id;
        }
      });
    } catch (e) {
      setState(() {
        _cargandoRegimenes = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar regímenes: $e')),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Impuesto a la Renta'),
        backgroundColor: AppColors.rentaColor,
        foregroundColor: Colors.white,
      ),
      body: _cargandoRegimenes 
        ? const Center(child: CircularProgressIndicator())
        : _regimenes.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.warning, size: 64, color: Colors.orange),
                    const SizedBox(height: 16),
                    const Text(
                      'No hay regímenes tributarios',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Debe crear al menos un régimen tributario para realizar cálculos',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => AppRoutes.navigateTo(context, AppRoutes.regimenes),
                      icon: const Icon(Icons.add),
                      label: const Text('Crear Régimen'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
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
            _cargandoRegimenes 
              ? const Center(child: CircularProgressIndicator())
              : DropdownButtonFormField<int>(
                  initialValue: _regimenSeleccionado,
                  decoration: const InputDecoration(
                    labelText: 'Régimen Tributario',
                  ),
                  items: _regimenes.map((regimen) {
                    return DropdownMenuItem<int>(
                      value: regimen.id,
                      child: Text('${regimen.nombre} (${regimen.tasaRentaFormateada})'),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    setState(() {
                      _regimenSeleccionado = newValue!;
                      _resultadoCalculo = null; // Limpiar resultado anterior
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
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isCalculating ? null : _calcularRenta,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.rentaColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isCalculating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Calcular Impuesto a la Renta'),
              ),
            ),
            const SizedBox(height: 24),
            if (_resultadoCalculo != null) _buildResultadoCard(),
          ],
        ),
      ),
    );
  }
  
  Future<void> _calcularRenta() async {
    final ingresos = double.tryParse(_ingresosController.text) ?? 0.0;
    
    if (ingresos <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingrese un monto de ingresos válido'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isCalculating = true;
    });

    try {
      final resultado = await CalculoService.calcularRenta(
        ingresos: ingresos,
        gastos: 0.0, // Sin gastos deducibles
        regimenId: _regimenSeleccionado!,
      );

      if (!mounted) return;
      
      // Registrar actividad reciente
      final regimenSeleccionado = _regimenes.firstWhere((r) => r.id == _regimenSeleccionado);
      await ActividadRecienteService.registrarCalculoRenta(
        ingresos: ingresos,
        impuesto: resultado['impuestoCalculado'] ?? 0.0,
        regimenNombre: regimenSeleccionado.nombre,
      );
      
      setState(() {
        _resultadoCalculo = resultado;
        _isCalculating = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isCalculating = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al calcular: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
  
  Widget _buildResultadoCard() {
    if (_resultadoCalculo == null) return const SizedBox();
    
    final resultado = _resultadoCalculo!;
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resultado del Cálculo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildResultadoItem('Ingresos', resultado['ingresos']),
            _buildResultadoItem('Gastos Deducibles', resultado['gastos']),
            _buildResultadoItem('Renta Neta', resultado['renta_neta']),
            const Divider(),
            _buildResultadoItem(
              'Impuesto a la Renta (${(resultado['tasa_renta'] * 100).toStringAsFixed(1)}%)', 
              resultado['impuesto_renta'], 
              isTotal: true,
            ),
            if (resultado['perdida'] > 0)
              _buildResultadoItem('Pérdida', resultado['perdida'], isError: true),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: resultado['debe_pagar'] 
                    ? AppColors.rentaColor.withValues(alpha: 0.1)
                    : AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    resultado['debe_pagar'] ? 'Total a Pagar' : 'Sin Impuesto por Pagar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: resultado['debe_pagar'] ? AppColors.rentaColor : AppColors.success,
                    ),
                  ),
                  if (resultado['debe_pagar'])
                    Text(
                      'S/ ${resultado['renta_por_pagar'].toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.rentaColor,
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
  
  Widget _buildResultadoItem(String label, double valor, {bool isTotal = false, bool isError = false}) {
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
              color: isError ? AppColors.error : (isTotal ? AppColors.textPrimary : AppColors.textSecondary),
            ),
          ),
          Text(
            'S/ ${valor.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: FontWeight.bold,
              color: isError ? AppColors.error : (isTotal ? AppColors.rentaColor : AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _ingresosController.dispose();
    super.dispose();
  }
}