import 'package:flutter_test/flutter_test.dart';
import 'package:simulador_frete/frete/strategy/retirada_loja.dart';

void main() {
  late RetiradaLoja strategy;

  setUp(() {
    strategy = RetiradaLoja();
  });

  test('retirada deve possuir frete gratuito', () {
    final resultado = strategy.calcular(
      peso: 10.0,
      distanciaKm: 100.0,
    );

    expect(resultado.valor, closeTo(0.0, 0.01));
    expect(resultado.prazoDias, 1);
  });
}
