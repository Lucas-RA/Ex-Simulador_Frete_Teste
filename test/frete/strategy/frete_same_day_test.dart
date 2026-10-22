import 'package:flutter_test/flutter_test.dart';
import 'package:simulador_frete/frete/strategy/frete_same_day.dart';

void main() {
  late FreteSameDay strategy;

  setUp(() {
    strategy = FreteSameDay();
  });

  // 25 + (1 × 6) + (10 × 0,40) = 35
  test('deve calcular 1 kg e 10 km', () {
    final resultado = strategy.calcular(peso: 1.0, distanciaKm: 10.0);

    expect(resultado.valor, closeTo(35.0, 0.01));
  });

  // 25 + (2 × 6) + (100 × 0,40) = 77
  test('deve calcular 2 kg e 100 km', () {
    final resultado = strategy.calcular(peso: 2.0, distanciaKm: 100.0);

    expect(resultado.valor, closeTo(77.0, 0.01));
  });

  // 25 + (5 × 6) + (50 × 0,40) = 75
  test('deve calcular 5 kg e 50 km', () {
    final resultado = strategy.calcular(peso: 5.0, distanciaKm: 50.0);

    expect(resultado.valor, closeTo(75.0, 0.01));
  });

  test('entrega deve acontecer no mesmo dia', () {
    final resultado = strategy.calcular(peso: 2.0, distanciaKm: 100.0);

    expect(resultado.prazoDias, 0);
  });

  test('peso zero deve gerar erro', () {
    expect(
      () => strategy.calcular(peso: 0.0, distanciaKm: 10.0),
      throwsArgumentError,
    );
  });

  test('distância negativa deve gerar erro', () {
    expect(
      () => strategy.calcular(peso: 2.0, distanciaKm: -1.0),
      throwsArgumentError,
    );
  });
}
