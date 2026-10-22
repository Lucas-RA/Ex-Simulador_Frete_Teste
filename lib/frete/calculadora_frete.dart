import '../models/resultado_frete.dart';
import '../models/tipo_frete.dart';

class CalculadoraFrete{
  ResultadoFrete calcular({
    required TipoFrete tipo,
    required double peso,
    required double distanciaKm,
  }) {
      switch (tipo) {
        case TipoFrete.economico:
          return ResultadoFrete(
              valor: 8.0 + peso * 2.0 + distanciaKm * 0.10,
              prazoDias: 5
            );
        case TipoFrete.expresso:
          return ResultadoFrete(
            valor: 15.0 + peso * 4.0 + distanciaKm * 0.25, 
            prazoDias: 2
            );
        case TipoFrete.retirada:
          return const ResultadoFrete(
            valor: 0.0, 
            prazoDias: 1
            );
      }
  }
}