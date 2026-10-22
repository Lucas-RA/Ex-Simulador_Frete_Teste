# Simulador de Frete

Simulador de frete em Flutter/Dart desenvolvido para praticar **testes unitários**, **TDD (Red → Green → Refactor)** e **Strategy Pattern**.

## Regras implementadas

| Modalidade | Valor base | Por kg  | Por km  | Prazo     |
|------------|-----------:|--------:|--------:|-----------|
| Econômico  | R$ 8,00    | R$ 2,00 | R$ 0,10 | 5 dias    |
| Expresso   | R$ 15,00   | R$ 4,00 | R$ 0,25 | 2 dias    |
| Retirada   | R$ 0,00    | R$ 0,00 | R$ 0,00 | 1 dia     |
| Same Day   | R$ 25,00   | R$ 6,00 | R$ 0,40 | mesmo dia |

- Peso deve ser maior que zero e distância não pode ser negativa (`ArgumentError`).
- Compras a partir de **R$ 300,00** têm frete grátis — essa regra tem prioridade sobre qualquer cupom.
- Cupons: `FRETEGRATIS` (100%), `FRETE50` (50%) e `FRETE20` (20%), sem diferenciar maiúsculas/minúsculas.

## Como rodar os testes

```bash
flutter test
```

## Passo a passo

O desenvolvimento completo, etapa por etapa, está em [docs/passo-a-passo.md](docs/passo-a-passo.md).
