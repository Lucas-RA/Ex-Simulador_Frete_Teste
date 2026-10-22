import '../../models/resultado_frete.dart';
import 'frete_strategy.dart';

class RetiradaLoja implements FreteStrategy {
  @override
  ResultadoFrete calcular({
    required double peso,
    required double distanciaKm,
  }) {
    return const ResultadoFrete(
      valor: 0.0,
      prazoDias: 1,
    );
  }
}
