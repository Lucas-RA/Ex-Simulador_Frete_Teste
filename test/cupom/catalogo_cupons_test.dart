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

    test('cupom inexistente deve retornar null', () {
      final cupom = CatalogoCupons.buscar('ABC123');

      expect(cupom, isNull);
    });
  });
}
