import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/calculo_service.dart';
import '../../services/database_service.dart';
import '../../services/actividad_reciente_service.dart';
import '../../services/historial_igv_service.dart';
import '../../models/regimen_tributario.dart';
import '../../widgets/compulsa_appbar.dart';

class RentaScreen extends StatefulWidget {
  const RentaScreen({super.key});

  @override
  State<RentaScreen> createState() => _RentaScreenState();
}

class _RentaScreenState extends State<RentaScreen> {
  final _ingresosController = TextEditingController();
  final _gastosController = TextEditingController();
  
  int? _regimenSeleccionado;
  Map<String, dynamic>? _resultadoCalculo;
  bool _isCalculating = false;
  
  List<RegimenTributario> _regimenes = [];
  bool _cargandoRegimenes = true;

  @override
  void initState() {
    super.initState();
    _cargarRegimenes();
    _cargarUltimasVentas();
  }

  Future<void> _cargarRegimenes() async {
    try {
      final regimenes = await DatabaseService().obtenerRegimenes();
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

  // Cargar las ventas del último cálculo de IGV
  Future<void> _cargarUltimasVentas() async {
    try {
      final ultimasVentas = await HistorialIGVService.obtenerUltimasVentas();
      if (mounted && ultimasVentas > 0) {
        setState(() {
          _ingresosController.text = ultimasVentas.toStringAsFixed(2);
        });
        
        // Mostrar un mensaje informativo
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Se cargaron automáticamente las ventas del último cálculo de IGV: S/ ${ultimasVentas.toStringAsFixed(2)}',
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Limpiar',
              textColor: Colors.white,
              onPressed: () {
                _ingresosController.clear();
              },
            ),
          ),
        );
      }
    } catch (e) {
      // En caso de error, no hacer nada - el campo queda vacío
      print('Error al cargar últimas ventas: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CompulsaAppBar(
        title: 'Impuesto a la Renta',
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
                      'Cargando regímenes tributarios',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Por favor espere mientras se cargan los regímenes disponibles',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
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
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _ingresosController.text.isNotEmpty 
                      ? AppColors.success.withOpacity(0.5)
                      : Colors.grey.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_ingresosController.text.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(7)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Datos cargados del último cálculo de IGV',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.success,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _ingresosController.clear();
                              });
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Limpiar',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 12,
                      right: 12,
                      bottom: 12,
                      top: _ingresosController.text.isNotEmpty ? 8 : 12,
                    ),
                    child: TextFormField(
                      controller: _ingresosController,
                      decoration: InputDecoration(
                        labelText: 'Ingresos del Período',
                        hintText: _ingresosController.text.isEmpty 
                            ? 'Ingrese los ingresos totales o calculará con ventas de IGV'
                            : 'Ingrese los ingresos totales',
                        prefixText: 'S/ ',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        labelStyle: TextStyle(
                          color: _ingresosController.text.isNotEmpty 
                              ? AppColors.success
                              : Colors.grey[600],
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          // Actualizar la UI cuando cambie el valor
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Campo de gastos deducibles
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: TextFormField(
                  controller: _gastosController,
                  decoration: const InputDecoration(
                    labelText: 'Gastos Deducibles (Opcional)',
                    hintText: 'Ingrese los gastos deducibles del período',
                    prefixText: 'S/ ',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    helperText: 'Gastos permitidos según su régimen tributario',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Botón para cargar ventas de IGV
            Container(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  try {
                    final ultimasVentas = await HistorialIGVService.obtenerUltimasVentas();
                    if (ultimasVentas > 0) {
                      setState(() {
                        _ingresosController.text = ultimasVentas.toStringAsFixed(2);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Ventas cargadas: S/ ${ultimasVentas.toStringAsFixed(2)}',
                          ),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No hay cálculos de IGV registrados'),
                          backgroundColor: AppColors.warning,
                        ),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al cargar ventas: $e'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.download_outlined, size: 18),
                label: const Text('Cargar Ventas del Último IGV'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
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
    final gastos = double.tryParse(_gastosController.text) ?? 0.0;
    
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
        gastos: gastos,
        regimenId: _regimenSeleccionado!,
      );

      if (!mounted) return;
      
      // Registrar actividad reciente
      final regimenSeleccionado = _regimenes.firstWhere((r) => r.id == _regimenSeleccionado);
      await ActividadRecienteService.registrarCalculoRenta(
        ingresos: ingresos,
        impuesto: resultado['impuesto_renta'] ?? 0.0,
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
            _buildResultadoItem('Ingresos (Ventas)', resultado['ingresos']),
            _buildResultadoItem('Gastos Deducibles', resultado['gastos']),
            _buildResultadoItem('Renta Neta', resultado['renta_neta']),
            if (resultado['base_imponible'] != null && resultado['base_imponible'] != resultado['renta_neta'])
              _buildResultadoItem('Base Imponible', resultado['base_imponible']),
            const Divider(),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                resultado['tipo_calculo'] ?? 'Cálculo estándar',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            _buildResultadoItem(
              'Impuesto a la Renta (${(resultado['tasa_renta']).toStringAsFixed(1)}%)', 
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
    _gastosController.dispose();
    super.dispose();
  }
}