class ResultadoFrete {
  final double valor;
  final int prazoDias;

  const ResultadoFrete({required this.valor, required this.prazoDias});

// vai nos permitir alterar o valor do frete sem modificar o prazo
  ResultadoFrete copyWith({
    double? valor,
    int? prazoDias
  }) {
    return ResultadoFrete(
      valor: valor ?? this.valor,
      prazoDias: prazoDias ?? this.prazoDias
    );
  }
}
