import 'package:flutter_test/flutter_test.dart';
import 'package:simulador_frete/frete/calculadora_frete.dart';
import 'package:simulador_frete/models/tipo_frete.dart';

void main() {
  final calculadora = CalculadoraFrete();

  // TESTE 1
  test('frete econômico deve calcular valor pelo peso e distância', () {
    // Arrange - Preparar
    const peso = 2.0;
    const distanciaKm = 100.0;
    // Act - Executar
    final resultado = calculadora.calcular(
      tipo: TipoFrete.economico,
      peso: peso,
      distanciaKm: distanciaKm,
      valorCompra: 100.0,
    );
    // Assert - Verificar
    // usamos o closeTo - valores double podem sofrer pequenas diferenças (pontos flutuantes)
    expect(resultado.valor, closeTo(22.0, 0.01));
  });

  // TESTE 2
  test('frete expresso deve calcular pelo peso e distância', () {
    const peso = 2.0;
    const distanciaKm = 100.0;

    final resultado = calculadora.calcular(
      tipo: TipoFrete.expresso,
      peso: peso,
      distanciaKm: distanciaKm,
      valorCompra: 100.0,
    );

    expect(resultado.valor, closeTo(48.0, 0.01));
  });

  // TESTE 3
  test('retirada deve possuir frete gratuito', () {
    final resultado = calculadora.calcular(
      tipo: TipoFrete.retirada,
      peso: 10.0,
      distanciaKm: 0.0,
      valorCompra: 100.0,
    );

    expect(resultado.valor, closeTo(0.0, 0.01));
  });

  test('peso zero deve gerar erro', () {
    expect(
      () => calculadora.calcular(
        tipo: TipoFrete.economico,
        peso: 0.0,
        distanciaKm: 100.0,
        valorCompra: 100.0,
      ),
      throwsArgumentError,
    );
  });

  test('peso negativo deve gerar erro', () {
    expect(
      () => calculadora.calcular(
        tipo: TipoFrete.economico,
        peso: -1.0,
        distanciaKm: 100.0,
        valorCompra: 100.0,
      ),
      throwsArgumentError,
    );
  });

  test('distância negativa deve gerar erro', () {
    expect(
      () => calculadora.calcular(
        tipo: TipoFrete.economico,
        peso: 2.0,
        distanciaKm: -10.0,
        valorCompra: 100.0,
      ),
      throwsArgumentError,
    );
  });

  test('compra de 350 deve possuir frete grátis no econômico', () {
    final resultado = calculadora.calcular(
      tipo: TipoFrete.economico,
      peso: 2.0,
      distanciaKm: 100.0,
      valorCompra: 350.0,
    );

    expect(resultado.valor, closeTo(0.0, 0.01));
  });

  // casos de fronteira da regra de frete grátis
  test('compra exatamente de 300 deve possuir frete grátis', () {
    final resultado = calculadora.calcular(
      tipo: TipoFrete.economico,
      peso: 2.0,
      distanciaKm: 100.0,
      valorCompra: 300.0,
    );

    expect(resultado.valor, closeTo(0.0, 0.01));
  });

  test('compra abaixo de 300 deve pagar frete', () {
    final resultado = calculadora.calcular(
      tipo: TipoFrete.economico,
      peso: 2.0,
      distanciaKm: 100.0,
      valorCompra: 299.99,
    );

    expect(resultado.valor, closeTo(22.0, 0.01));
  });
}
