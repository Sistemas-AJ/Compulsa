import 'package:flutter/services.dart';
import 'format_utils.dart';

/// Formateador de entrada para números con separadores de miles
class NumberInputFormatter extends TextInputFormatter {
  final int decimales;
  final double? valorMaximo;

  NumberInputFormatter({
    this.decimales = 2,
    this.valorMaximo,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Si el texto está vacío, permitir
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Limpiar el texto de cualquier formato previo
    String textoLimpio = FormatUtils.limpiarFormatoNumero(newValue.text);

    // Validar que solo contenga números y punto decimal
    if (!RegExp(r'^\d*\.?\d*$').hasMatch(textoLimpio)) {
      return oldValue;
    }

    // Convertir a double y validar límite máximo
    double? valor = double.tryParse(textoLimpio);
    if (valor != null && valorMaximo != null && valor > valorMaximo!) {
      return oldValue;
    }

    // Formatear el número
    String textoFormateado = FormatUtils.formatearNumeroConSeparadores(
      textoLimpio,
      decimales: decimales,
    );

    // Calcular nueva posición del cursor
    int nuevaPosicion = textoFormateado.length;
    
    // Ajustar posición del cursor considerando los separadores agregados
    int separadoresAgregados = textoFormateado.split(',').length - 1;
    int separadoresOriginales = oldValue.text.split(',').length - 1;
    int diferenciaSeparadores = separadoresAgregados - separadoresOriginales;
    
    if (newValue.selection.baseOffset != newValue.text.length) {
      nuevaPosicion = newValue.selection.baseOffset + diferenciaSeparadores;
      nuevaPosicion = nuevaPosicion.clamp(0, textoFormateado.length);
    }

    return TextEditingValue(
      text: textoFormateado,
      selection: TextSelection.collapsed(offset: nuevaPosicion),
    );
  }
}

/// Formateador específico para montos en soles peruanos
class MoneyInputFormatter extends NumberInputFormatter {
  MoneyInputFormatter({int decimales = 2, double? valorMaximo})
      : super(
          decimales: decimales,
          valorMaximo: valorMaximo ?? 999999999999.99, // Límite por defecto
        );
}

/// Formateador para coeficientes (porcentajes)
class CoefficientInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Validar formato de porcentaje
    String textoLimpio = newValue.text.replaceAll('%', '');
    
    if (!RegExp(r'^\d*\.?\d*$').hasMatch(textoLimpio)) {
      return oldValue;
    }

    double? valor = double.tryParse(textoLimpio);
    if (valor != null && valor > 100) {
      return oldValue; // No permitir más de 100%
    }

    return newValue;
  }
}