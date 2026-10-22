import '../../models/resultado_frete.dart';
import 'frete_strategy.dart';

class FreteSameDay implements FreteStrategy {
  @override
  ResultadoFrete calcular({
    required double peso,
    required double distanciaKm,
  }) {
    if (peso <= 0) {
      throw ArgumentError('O peso deve ser maior que zero');
    }

    if (distanciaKm < 0) {
      throw ArgumentError('A distância não pode ser negativa');
    }

    final valor = 25.0 + peso * 6.0 + distanciaKm * 0.40;

    // entrega no mesmo dia = 0 dias de prazo
    return ResultadoFrete(
      valor: valor,
      prazoDias: 0,
    );
  }
}
