import '../../models/resultado_frete.dart';

// contrato que toda modalidade de frete precisa seguir
abstract class FreteStrategy {
  ResultadoFrete calcular({
    required double peso,
    required double distanciaKm,
  });
}
