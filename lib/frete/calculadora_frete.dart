import '../cupom/catalogo_cupons.dart';
import '../models/resultado_frete.dart';
import '../models/tipo_frete.dart';
import 'strategy/frete_economico.dart';
import 'strategy/frete_expresso.dart';
import 'strategy/frete_strategy.dart';
import 'strategy/retirada_loja.dart';

class CalculadoraFrete {
  ResultadoFrete calcular({
    required TipoFrete tipo,
    required double peso,
    required double distanciaKm,
    required double valorCompra,
    String cupom = '',
  }) {
    // a calculadora só escolhe a estratégia; a fórmula fica em cada classe
    final FreteStrategy strategy = switch (tipo) {
      TipoFrete.economico => FreteEconomico(),
      TipoFrete.expresso => FreteExpresso(),
      TipoFrete.retirada => RetiradaLoja(),
    };

    final resultado = strategy.calcular(
      peso: peso,
      distanciaKm: distanciaKm,
    );

    // compras a partir de R$ 300,00 possuem frete grátis
    // (regra de maior prioridade: vem antes dos cupons)
    if (valorCompra >= 300.0) {
      return resultado.copyWith(valor: 0.0);
    }

    final cupomEncontrado = CatalogoCupons.buscar(cupom);

    // cupom vazio ou inexistente: frete sem desconto
    if (cupomEncontrado == null) {
      return resultado;
    }

    final valorComDesconto = cupomEncontrado.aplicar(
      resultado.valor,
    );

    return resultado.copyWith(
      valor: valorComDesconto,
    );
  }
}
