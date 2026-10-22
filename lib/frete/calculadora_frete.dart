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
    // (essa regra vem antes dos cupons porque tem prioridade)
    if (valorCompra >= 300.0) {
      return resultado.copyWith(valor: 0.0);
    }

    // toUpperCase para aceitar o cupom digitado em minúsculo
    if (cupom.toUpperCase() == 'FRETEGRATIS') {
      return resultado.copyWith(valor: 0.0);
    }

    if (cupom.toUpperCase() == 'FRETE50') {
      return resultado.copyWith(
        valor: resultado.valor * 0.50,
      );
    }

    return resultado;
  }
}
