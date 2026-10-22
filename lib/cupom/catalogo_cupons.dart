import 'cupom_frete.dart';

// para criar um cupom novo basta cadastrar aqui, sem mexer na calculadora
class CatalogoCupons {
  static const cupons = <String, CupomFrete>{
    'FRETEGRATIS': CupomFrete(
      codigo: 'FRETEGRATIS',
      percentualDesconto: 1.0,
    ),
    'FRETE50': CupomFrete(
      codigo: 'FRETE50',
      percentualDesconto: 0.50,
    ),
    'FRETE20': CupomFrete(
      codigo: 'FRETE20',
      percentualDesconto: 0.20,
    ),
  };

  static CupomFrete? buscar(String codigo) {
    return cupons[codigo.trim().toUpperCase()];
  }
}
