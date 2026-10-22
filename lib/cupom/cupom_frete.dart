class CupomFrete {
  final String codigo;
  // 1.0 = 100% de desconto, 0.50 = 50% de desconto
  final double percentualDesconto;

  const CupomFrete({
    required this.codigo,
    required this.percentualDesconto,
  });

  double aplicar(double valorFrete) {
    return valorFrete * (1 - percentualDesconto);
  }
}
