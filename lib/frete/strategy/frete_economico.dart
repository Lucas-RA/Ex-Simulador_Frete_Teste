import '../../models/resultado_frete.dart';
import 'frete_strategy.dart';

class FreteEconomico implements FreteStrategy {
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

    final valor = 8.0 + peso * 2.0 + distanciaKm * 0.10;

    return ResultadoFrete(
      valor: valor,
      prazoDias: 5,
    );
  }
}
