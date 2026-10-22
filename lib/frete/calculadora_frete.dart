import '../models/resultado_frete.dart';
import '../models/tipo_frete.dart';

class CalculadoraFrete {
  ResultadoFrete calcular({
    required TipoFrete tipo,
    required double peso,
    required double distanciaKm,
    required double valorCompra,
  }) {
    if (peso <= 0) {
      throw ArgumentError('O peso deve ser maior que zero');
    }

    if (distanciaKm < 0) {
      throw ArgumentError('A distância não pode ser negativa');
    }

    // calcula primeiro o frete "cheio" e guarda numa variável,
    // para depois aplicar a regra de frete grátis
    late ResultadoFrete resultado;

    switch (tipo) {
      case TipoFrete.economico:
        resultado = ResultadoFrete(
          valor: 8.0 + peso * 2.0 + distanciaKm * 0.10,
          prazoDias: 5,
        );
        break;

      case TipoFrete.expresso:
        resultado = ResultadoFrete(
          valor: 15.0 + peso * 4.0 + distanciaKm * 0.25,
          prazoDias: 2,
        );
        break;

      case TipoFrete.retirada:
        resultado = const ResultadoFrete(
          valor: 0.0,
          prazoDias: 1,
        );
        break;
    }

    // compras a partir de R$ 300,00 possuem frete grátis
    if (valorCompra >= 300.0) {
      return resultado.copyWith(valor: 0.0);
    }

    return resultado;
  }
}
