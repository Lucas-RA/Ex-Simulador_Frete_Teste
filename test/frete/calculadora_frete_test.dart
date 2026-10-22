import 'package:flutter_test/flutter_test.dart';
import 'package:simulador_frete/frete/calculadora_frete.dart';
import 'package:simulador_frete/models/tipo_frete.dart';

void main() {
  late CalculadoraFrete calculadora;

  setUp(() {
    calculadora = CalculadoraFrete();
  });

  group('Validações', () {
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

    // throwsA + isA permite verificar o tipo exato da exceção
    test('peso zero deve gerar exatamente um ArgumentError', () {
      expect(
        () => calculadora.calcular(
          tipo: TipoFrete.expresso,
          peso: 0.0,
          distanciaKm: 100.0,
          valorCompra: 100.0,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('distância zero deve ser permitida', () {
      final resultado = calculadora.calcular(
        tipo: TipoFrete.economico,
        peso: 2.0,
        distanciaKm: 0.0,
        valorCompra: 100.0,
      );

      // 8 + (2 × 2) + (0 × 0,10) = 12
      expect(resultado.valor, closeTo(12.0, 0.01));
    });
  });

  group('Modalidades', () {
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
      expect(resultado.prazoDias, 5);
    });

    test('frete expresso deve calcular pelo peso e distância', () {
      final resultado = calculadora.calcular(
        tipo: TipoFrete.expresso,
        peso: 2.0,
        distanciaKm: 100.0,
        valorCompra: 100.0,
      );

      expect(resultado.valor, closeTo(48.0, 0.01));
      expect(resultado.prazoDias, 2);
    });

    test('retirada deve possuir frete gratuito', () {
      final resultado = calculadora.calcular(
        tipo: TipoFrete.retirada,
        peso: 10.0,
        distanciaKm: 0.0,
        valorCompra: 100.0,
      );

      expect(resultado.valor, closeTo(0.0, 0.01));
      expect(resultado.prazoDias, 1);
    });

    test('same day deve calcular pelo peso e distância e entregar no mesmo dia', () {
      final resultado = calculadora.calcular(
        tipo: TipoFrete.sameDay,
        peso: 2.0,
        distanciaKm: 100.0,
        valorCompra: 100.0,
      );

      expect(resultado.valor, closeTo(77.0, 0.01));
      expect(resultado.prazoDias, 0);
    });
  });

  group('Frete grátis', () {
    test('compra de 350 deve possuir frete grátis no econômico', () {
      final resultado = calculadora.calcular(
        tipo: TipoFrete.economico,
        peso: 2.0,
        distanciaKm: 100.0,
        valorCompra: 350.0,
      );

      expect(resultado.valor, closeTo(0.0, 0.01));
    });

    // casos de fronteira: 300,00 ganha, 299,99 paga
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

    test('frete grátis não deve alterar o prazo de entrega', () {
      final resultado = calculadora.calcular(
        tipo: TipoFrete.expresso,
        peso: 2.0,
        distanciaKm: 100.0,
        valorCompra: 300.0,
      );

      expect(resultado.valor, closeTo(0.0, 0.01));
      expect(resultado.prazoDias, 2);
    });
  });

  group('Cupons', () {
    test('cupom FRETEGRATIS deve zerar o frete', () {
      final resultado = calculadora.calcular(
        tipo: TipoFrete.economico,
        peso: 2.0,
        distanciaKm: 100.0,
        valorCompra: 100.0,
        cupom: 'FRETEGRATIS',
      );

      expect(resultado.valor, closeTo(0.0, 0.01));
    });

    test('cupom FRETE50 deve aplicar cinquenta por cento de desconto', () {
      final resultado = calculadora.calcular(
        tipo: TipoFrete.economico,
        peso: 2.0,
        distanciaKm: 100.0,
        valorCompra: 100.0,
        cupom: 'FRETE50',
      );

      expect(resultado.valor, closeTo(11.0, 0.01));
    });

    // 8 + (2 × 2) + (380 × 0,10) = 50 → com 20% de desconto = 40
    test('cupom FRETE20 deve aplicar vinte por cento de desconto', () {
      final resultado = calculadora.calcular(
        tipo: TipoFrete.economico,
        peso: 2.0,
        distanciaKm: 380.0,
        valorCompra: 100.0,
        cupom: 'FRETE20',
      );

      expect(resultado.valor, closeTo(40.0, 0.01));
    });

    test('cupom inválido não deve alterar valor do frete', () {
      final resultado = calculadora.calcular(
        tipo: TipoFrete.economico,
        peso: 2.0,
        distanciaKm: 100.0,
        valorCompra: 100.0,
        cupom: 'ABC123',
      );

      expect(resultado.valor, closeTo(22.0, 0.01));
    });

    test('sem cupom o valor do frete não muda', () {
      final resultado = calculadora.calcular(
        tipo: TipoFrete.economico,
        peso: 2.0,
        distanciaKm: 100.0,
        valorCompra: 100.0,
      );

      expect(resultado.valor, closeTo(22.0, 0.01));
    });

    test('cupom fretegratis em minúsculo deve zerar frete', () {
      final resultado = calculadora.calcular(
        tipo: TipoFrete.economico,
        peso: 2.0,
        distanciaKm: 100.0,
        valorCompra: 100.0,
        cupom: 'fretegratis',
      );

      expect(resultado.valor, closeTo(0.0, 0.01));
    });

    // regra de negócio: frete grátis por valor da compra vence qualquer cupom
    test('frete grátis por valor da compra deve ter prioridade sobre cupom', () {
      final resultado = calculadora.calcular(
        tipo: TipoFrete.economico,
        peso: 2.0,
        distanciaKm: 100.0,
        valorCompra: 350.0,
        cupom: 'FRETE50',
      );

      expect(resultado.valor, closeTo(0.0, 0.01));
    });
  });
}
