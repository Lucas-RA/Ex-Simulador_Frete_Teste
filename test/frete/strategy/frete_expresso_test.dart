import 'package:flutter_test/flutter_test.dart';
import 'package:simulador_frete/frete/strategy/frete_expresso.dart';

void main() {
  late FreteExpresso strategy;

  setUp(() {
    strategy = FreteExpresso();
  });

  test('deve calcular frete considerando peso e distância', () {
    final resultado = strategy.calcular(
      peso: 2.0,
      distanciaKm: 100.0,
    );

    expect(resultado.valor, closeTo(48.0, 0.01));
    expect(resultado.prazoDias, 2);
  });

  test('peso zero deve gerar erro', () {
    expect(
      () => strategy.calcular(
        peso: 0.0,
        distanciaKm: 100.0,
      ),
      throwsArgumentError,
    );
  });
}
