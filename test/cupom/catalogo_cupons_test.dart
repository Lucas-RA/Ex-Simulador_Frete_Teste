import 'package:flutter_test/flutter_test.dart';
import 'package:simulador_frete/cupom/catalogo_cupons.dart';

void main() {
  group('CatalogoCupons', () {
    test('deve localizar FRETE50', () {
      final cupom = CatalogoCupons.buscar('FRETE50');

      expect(cupom, isNotNull);
      expect(cupom!.percentualDesconto, 0.50);
    });

    test('deve ignorar diferença entre maiúsculas e minúsculas', () {
      final cupom = CatalogoCupons.buscar('fretegratis');

      expect(cupom, isNotNull);
      expect(cupom!.percentualDesconto, 1.0);
    });

    test('deve localizar FRETE20', () {
      final cupom = CatalogoCupons.buscar('FRETE20');

      expect(cupom, isNotNull);
      expect(cupom!.percentualDesconto, 0.20);
    });

    test('FRETE20 deve transformar frete de 50 em 40', () {
      final cupom = CatalogoCupons.buscar('FRETE20')!;

      expect(cupom.aplicar(50.0), closeTo(40.0, 0.01));
    });

    test('deve ignorar espaços antes e depois do código', () {
      final cupom = CatalogoCupons.buscar('  frete50 ');

      expect(cupom, isNotNull);
    });

    test('cupom inexistente deve retornar null', () {
      final cupom = CatalogoCupons.buscar('ABC123');

      expect(cupom, isNull);
    });
  });
}
