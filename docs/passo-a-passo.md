# Simulador de Frete — passo a passo

Anotações do desenvolvimento do projeto **Simulador de Frete** em Flutter, seguindo o material
[Simulador de Frete em Flutter com TDD e Strategy Pattern](https://www.heiderlopes.com.br/flutter/tutoriais/simulador-frete-teste/simulador-frete-flutter-tdd-strategy).

Nesse projeto foi trabalhado:

- Testes unitários com `flutter_test`
- Organização de cenários de teste
- TDD (Test Driven Development) — **RED → GREEN → REFACTOR**
- Regras de negócio e casos de borda
- Refatoração com **Strategy Pattern**

---

## Sumário

0. [Recapitulando o começo](#0-recapitulando-o-começo)
1. [Nova regra: considerar a distância](#1-nova-regra-considerar-a-distância)
2. [Casos inválidos](#2-casos-inválidos)
3. [Frete grátis por valor da compra](#3-frete-grátis-por-valor-da-compra)
4. [Testando o limite da regra (fronteira)](#4-testando-o-limite-da-regra-fronteira)
5. [Cupons de frete](#5-cupons-de-frete)
6. [Prioridade entre as regras](#6-prioridade-entre-as-regras)
7. [O código começou a crescer](#7-o-código-começou-a-crescer)
8. [REFACTOR com Strategy Pattern](#8-refactor-com-strategy-pattern)
9. [Refatorando os cupons: catálogo](#9-refatorando-os-cupons-catálogo)
10. [Desafio 1 — Frete Same Day](#10-desafio-1--frete-same-day)
11. [Desafio 2 — Cupom FRETE20](#11-desafio-2--cupom-frete20)
12. [Desafio 3 — Organizando os testes com `group`](#12-desafio-3--organizando-os-testes-com-group)
13. [Estrutura final e comandos](#13-estrutura-final-e-comandos)

---

## 0. Recapitulando o começo

Criamos o projeto com:

```bash
flutter create simulador_frete
```

Removemos o teste padrão (`test/widget_test.dart`) e fomos criando as pastas conforme a necessidade.

**Regra de negócio inicial:** 3 tipos de frete, cada um com valor base, valor por kg e prazo.

**Models** (`lib/models`):

- `tipo_frete.dart` → o **enum** com as modalidades (`economico`, `expresso`, `retirada`)
- `resultado_frete.dart` → a resposta que o cliente quer: **valor** e **prazoDias**.
  Tem um `copyWith`, que permite trocar o valor do frete sem mexer no prazo (vai ser muito usado mais pra frente).

**Classe de cálculo:** `lib/frete/calculadora_frete.dart` → `CalculadoraFrete.calcular(...)`.

**Testes:** pasta `test/frete`, usando `import 'package:flutter_test/flutter_test.dart';`
e o padrão **Arrange → Act → Assert** (preparar, executar, verificar).

Usamos `closeTo(valor, 0.01)` nas comparações porque `double` pode ter pequenas diferenças de ponto flutuante.

### TDD — Red → Green → Refactor

- **RED**: criamos um teste para um comportamento que ainda não existe. O teste deve falhar (às vezes nem compila — isso também é RED).
- **GREEN**: escrevemos o mínimo de código necessário para o teste passar.
- **REFACTOR**: melhoramos a estrutura do código **sem alterar o comportamento** (os testes continuam passando).

---

## 1. Nova regra: considerar a distância

A empresa decidiu que o frete vai considerar **peso** e **distância**.
Antes de mexer no código, documentamos a nova tabela:

### 1.1 Nova tabela de preços

| Modalidade | Valor base | Por kg  | Por km  | Prazo  |
|------------|-----------:|--------:|--------:|--------|
| Econômico  | R$ 8,00    | R$ 2,00 | R$ 0,10 | 5 dias |
| Expresso   | R$ 15,00   | R$ 4,00 | R$ 0,25 | 2 dias |
| Retirada   | R$ 0,00    | R$ 0,00 | R$ 0,00 | 1 dia  |

Fórmula:

```text
valor base + (peso × valor por kg) + (distância × valor por km)
```

Exemplos do Econômico:

| Peso | Distância | Cálculo                    | Resultado |
|------|-----------|----------------------------|-----------|
| 1 kg | 10 km     | 8 + (1 × 2) + (10 × 0,10)  | R$ 11,00  |
| 2 kg | 100 km    | 8 + (2 × 2) + (100 × 0,10) | R$ 22,00  |
| 5 kg | 50 km     | 8 + (5 × 2) + (50 × 0,10)  | R$ 23,00  |

Expresso com 2 kg e 100 km: `15 + (2 × 4) + (100 × 0,25) = R$ 48,00`.

### 1.2 RED

Primeiro alteramos o teste passando `distanciaKm` e esperando R$ 22,00.
O projeto nem compila porque o parâmetro ainda não existe → **RED**.

### 1.3 GREEN

Adicionamos `required double distanciaKm` no `calcular` e ajustamos as fórmulas:

```dart
case TipoFrete.economico:
  return ResultadoFrete(
    valor: 8.0 + peso * 2.0 + distanciaKm * 0.10,
    prazoDias: 5,
  );
case TipoFrete.expresso:
  return ResultadoFrete(
    valor: 15.0 + peso * 4.0 + distanciaKm * 0.25,
    prazoDias: 2,
  );
```

---

## 2. Casos inválidos

Novas regras de validação, definidas **antes** da implementação:

| Situação               | Comportamento esperado |
|------------------------|------------------------|
| Peso maior que zero    | cálculo permitido      |
| Peso igual a zero      | erro                   |
| Peso negativo          | erro                   |
| Distância igual a zero | permitido              |
| Distância negativa     | erro                   |

Para testar exceção usamos o matcher `throwsArgumentError`.
Repare que passamos **uma função** para o `expect` (`() => ...`) — assim o framework consegue capturar a exceção
no momento em que ela acontece:

```dart
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
```

GREEN — no começo do `calcular`:

```dart
if (peso <= 0) {
  throw ArgumentError('O peso deve ser maior que zero');
}

if (distanciaKm < 0) {
  throw ArgumentError('A distância não pode ser negativa');
}
```

---

## 3. Frete grátis por valor da compra

O time comercial criou uma promoção:

> Pedidos com valor **igual ou superior a R$ 300,00** possuem frete grátis.

Transformando o requisito em exemplos (**tabela de decisão**):

| Valor da compra | Frete calculado | Frete final |
|-----------------|-----------------|-------------|
| R$ 100,00       | R$ 22,00        | R$ 22,00    |
| R$ 299,99       | R$ 22,00        | R$ 22,00    |
| R$ 300,00       | R$ 22,00        | R$ 0,00     |
| R$ 350,00       | R$ 22,00        | R$ 0,00     |

### 3.1 RED

```dart
test('compra de 350 deve possuir frete grátis no econômico', () {
  final resultado = calculadora.calcular(
    tipo: TipoFrete.economico,
    peso: 2.0,
    distanciaKm: 100.0,
    valorCompra: 350.0,
  );

  expect(resultado.valor, closeTo(0.0, 0.01));
});
```

Não compila porque `valorCompra` ainda não existe. Quando adicionamos `required double valorCompra` na assinatura,
**todos os testes antigos param de compilar** também, porque agora precisam informar o valor da compra:

```text
Error: Required named parameter 'valorCompra' must be provided.
```

Ou seja, além de criar o parâmetro, ajustamos os testes antigos passando `valorCompra: 100.0`
(um valor abaixo de R$ 300, para não mudar o resultado esperado deles).

### 3.2 GREEN

Para aplicar a regra **depois** do cálculo, o `switch` deixou de dar `return` direto e passou a guardar
o resultado numa variável. Depois do `switch`, usamos o `copyWith` para zerar só o valor (o prazo continua o mesmo):

```dart
late ResultadoFrete resultado;

switch (tipo) {
  case TipoFrete.economico:
    resultado = ResultadoFrete(
      valor: 8.0 + peso * 2.0 + distanciaKm * 0.10,
      prazoDias: 5,
    );
    break;
  // ... expresso e retirada
}

if (valorCompra >= 300.0) {
  return resultado.copyWith(valor: 0.0);
}

return resultado;
```

---

## 4. Testando o limite da regra (fronteira)

O ponto mais importante da regra é o **limite**:

```text
299,99 → paga frete
300,00 → frete grátis
```

Esse é um **caso de fronteira** (onde costumam aparecer os bugs, por exemplo usar `>` no lugar de `>=`).
Por isso criamos um teste para cada lado:

```dart
test('compra exatamente de 300 deve possuir frete grátis', () { ... valorCompra: 300.0 ... });  // 0,00
test('compra abaixo de 300 deve pagar frete', () { ... valorCompra: 299.99 ... });             // 22,00
```

Resultado: **9 testes passando**.

---

## 5. Cupons de frete

O marketing criou cupons:

| Cupom          | Regra                     |
|----------------|---------------------------|
| `FRETEGRATIS`  | 100% de desconto no frete |
| `FRETE50`      | 50% de desconto no frete  |
| Qualquer outro | sem desconto              |

Com frete original de R$ 22,00:

| Compra    | Cupom         | Desconto | Frete final |
|-----------|---------------|----------|-------------|
| R$ 100,00 | nenhum        | R$ 0,00  | R$ 22,00    |
| R$ 100,00 | `FRETEGRATIS` | R$ 22,00 | R$ 0,00     |
| R$ 100,00 | `FRETE50`     | R$ 11,00 | R$ 11,00    |
| R$ 100,00 | `ABC123`      | R$ 0,00  | R$ 22,00    |

### 5.1 RED

Testes para `FRETEGRATIS`, `FRETE50`, cupom inválido (`ABC123`) e cupom em minúsculo (`fretegratis`).
Erro de compilação: `No named parameter with the name 'cupom'`.

### 5.2 GREEN

O cupom é um parâmetro **opcional** (com valor padrão `''`), assim os testes antigos não precisam mudar:

```dart
ResultadoFrete calcular({
  required TipoFrete tipo,
  required double peso,
  required double distanciaKm,
  required double valorCompra,
  String cupom = '',
}) {
```

Depois da regra de frete grátis:

```dart
if (cupom.toUpperCase() == 'FRETEGRATIS') {
  return resultado.copyWith(valor: 0.0);
}

if (cupom.toUpperCase() == 'FRETE50') {
  return resultado.copyWith(valor: resultado.valor * 0.50);
}
```

O `toUpperCase()` faz o cupom funcionar mesmo digitado em minúsculo.

---

## 6. Prioridade entre as regras

Dúvida de negócio: compra de **R$ 350,00** com cupom **FRETE50** — qual regra vale?

No mundo real essa decisão vem do negócio. Ficou definido:

> Frete grátis por valor da compra tem **prioridade** sobre qualquer cupom.

| Compra    | Cupom         | Resultado    |
|-----------|---------------|--------------|
| R$ 350,00 | nenhum        | R$ 0,00      |
| R$ 350,00 | `FRETE50`     | R$ 0,00      |
| R$ 350,00 | `FRETEGRATIS` | R$ 0,00      |
| R$ 100,00 | `FRETE50`     | 50% do frete |
| R$ 100,00 | `FRETEGRATIS` | R$ 0,00      |

```dart
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
```

Esse teste já passou de primeira, porque a regra dos R$ 300 vem **antes** dos cupons no código.
Mesmo assim ele é importante: **o teste documenta a regra de negócio** — se alguém inverter a ordem dos `if`, ele quebra.

Resultado: **14 testes passando**.

---

## 7. O código começou a crescer

Nesse ponto a `CalculadoraFrete` fazia tudo: validação, as 3 fórmulas, frete grátis e cupons.
E a empresa já planejava novas modalidades (Same Day, Motoboy, Transportadora, Premium).

Continuando com `switch`, a classe só ia crescer. É aqui que entra a terceira etapa do TDD: **REFACTOR**.

---

## 8. REFACTOR com Strategy Pattern

Objetivo: **melhorar a estrutura sem alterar o comportamento**. Isso é seguro porque já temos testes cobrindo tudo.

```text
Antes                         Depois
CalculadoraFrete              FreteStrategy (contrato)
├── regra Econômico           ├── FreteEconomico
├── regra Expresso            ├── FreteExpresso
└── regra Retirada            └── RetiradaLoja
```

Cada estratégia fica responsável por calcular **uma** modalidade.

### 8.1 O contrato — `lib/frete/strategy/frete_strategy.dart`

Em Dart, uma `abstract class` é o jeito comum de representar o contrato da Strategy:

```dart
abstract class FreteStrategy {
  ResultadoFrete calcular({
    required double peso,
    required double distanciaKm,
  });
}
```

### 8.2 As estratégias

`lib/frete/strategy/frete_economico.dart`:

```dart
class FreteEconomico implements FreteStrategy {
  @override
  ResultadoFrete calcular({
    required double peso,
    required double distanciaKm,
  }) {
    if (peso <= 0) {
      throw ArgumentError('O peso deve ser maior que zero');
    }

    if (distanciaKm < 0) {
      throw ArgumentError('A distância não pode ser negativa');
    }

    final valor = 8.0 + peso * 2.0 + distanciaKm * 0.10;

    return ResultadoFrete(valor: valor, prazoDias: 5);
  }
}
```

`FreteExpresso` é igual, com `15.0 + peso * 4.0 + distanciaKm * 0.25` e prazo 2.
`RetiradaLoja` sempre devolve valor 0 e prazo 1.

### 8.3 Testando cada estratégia isoladamente

Criamos `test/frete/strategy/` com um arquivo por estratégia. Aqui aparece o `setUp`, que roda **antes de cada teste**
e garante uma instância nova para cada um:

```dart
void main() {
  late FreteEconomico strategy;

  setUp(() {
    strategy = FreteEconomico();
  });

  test('deve calcular frete considerando peso e distância', () {
    final resultado = strategy.calcular(peso: 2.0, distanciaKm: 100.0);

    expect(resultado.valor, closeTo(22.0, 0.01));
    expect(resultado.prazoDias, 5);
  });
}
```

Exercícios do "Para praticar" feitos no `frete_economico_test.dart`:

| Teste                                  | Ideia                                                      |
|----------------------------------------|------------------------------------------------------------|
| peso mínimo (1 kg, 100 km)             | `8 + 2 + 10 = R$ 20,00`                                    |
| valor aumenta quando o peso aumenta    | compara 1 kg com 5 kg usando `greaterThan`                 |
| valor aumenta quando a distância aumenta | compara 50 km com 500 km usando `greaterThan`            |
| distância negativa gera erro           | `throwsArgumentError`                                      |
| peso negativo gera erro                | `throwsArgumentError`                                      |

### 8.4 A calculadora depois da refatoração

Agora a calculadora **não conhece mais as fórmulas**, ela só escolhe a estratégia certa
(usando *switch expression*, do Dart 3):

```dart
final FreteStrategy strategy = switch (tipo) {
  TipoFrete.economico => FreteEconomico(),
  TipoFrete.expresso => FreteExpresso(),
  TipoFrete.retirada => RetiradaLoja(),
};

final resultado = strategy.calcular(
  peso: peso,
  distanciaKm: distanciaKm,
);
```

**Prova de que a refatoração não mudou o comportamento:** rodamos os 14 testes da calculadora
**sem alterar nenhum deles** e todos continuaram passando (23 no total, somando os novos testes das estratégias).

---

## 9. Refatorando os cupons: catálogo

A Strategy resolveu as modalidades, mas os cupons ainda eram uma sequência de `if`.
Cada cupom novo faria a `CalculadoraFrete` crescer de novo. Solução: um **catálogo de cupons**.

### 9.1 RED

Criamos `test/cupom/catalogo_cupons_test.dart` antes do código (não compila, a classe não existe):

```dart
group('CatalogoCupons', () {
  test('deve localizar FRETE50', () {
    final cupom = CatalogoCupons.buscar('FRETE50');

    expect(cupom, isNotNull);
    expect(cupom!.percentualDesconto, 0.50);
  });

  test('deve ignorar diferença entre maiúsculas e minúsculas', () { ... });

  test('cupom inexistente deve retornar null', () {
    expect(CatalogoCupons.buscar('ABC123'), isNull);
  });
});
```

### 9.2 GREEN

`lib/cupom/cupom_frete.dart` — o cupom sabe aplicar o próprio desconto:

```dart
class CupomFrete {
  final String codigo;
  final double percentualDesconto;

  const CupomFrete({required this.codigo, required this.percentualDesconto});

  double aplicar(double valorFrete) {
    return valorFrete * (1 - percentualDesconto);
  }
}
```

`lib/cupom/catalogo_cupons.dart` — um `Map` com os cupons cadastrados:

```dart
class CatalogoCupons {
  static const cupons = <String, CupomFrete>{
    'FRETEGRATIS': CupomFrete(codigo: 'FRETEGRATIS', percentualDesconto: 1.0),
    'FRETE50': CupomFrete(codigo: 'FRETE50', percentualDesconto: 0.50),
  };

  static CupomFrete? buscar(String codigo) {
    return cupons[codigo.trim().toUpperCase()];
  }
}
```

O `trim()` ignora espaços e o `toUpperCase()` resolve maiúsculas/minúsculas.
O retorno é `CupomFrete?` (pode ser `null`) quando o cupom não existe.

### 9.3 Calculadora usando o catálogo

```dart
// Regra de maior prioridade.
if (valorCompra >= 300.0) {
  return resultado.copyWith(valor: 0.0);
}

final cupomEncontrado = CatalogoCupons.buscar(cupom);

if (cupomEncontrado == null) {
  return resultado;
}

return resultado.copyWith(
  valor: cupomEncontrado.aplicar(resultado.valor),
);
```

A calculadora não precisa mais saber o percentual de cada cupom. Resultado: **26 testes passando**.

---

## 10. Desafio 1 — Frete Same Day

Novo requisito:

| Regra        | Valor     |
|--------------|-----------|
| Valor base   | R$ 25,00  |
| Valor por kg | R$ 6,00   |
| Valor por km | R$ 0,40   |
| Prazo        | mesmo dia |

Fórmula: `25 + (peso × 6) + (distância × 0,40)`

Completando a tabela **antes** de implementar:

| Peso | Distância | Cálculo                     | Resultado |
|------|-----------|-----------------------------|-----------|
| 1 kg | 10 km     | 25 + (1 × 6) + (10 × 0,40)  | R$ 35,00  |
| 2 kg | 100 km    | 25 + (2 × 6) + (100 × 0,40) | R$ 77,00  |
| 5 kg | 50 km     | 25 + (5 × 6) + (50 × 0,40)  | R$ 75,00  |

"Mesmo dia" foi representado como `prazoDias: 0`.

Passos seguidos:

1. Escrevemos `test/frete/strategy/frete_same_day_test.dart` com os 3 exemplos da tabela, o prazo 0 e as validações.
2. Rodamos → **RED** (`'FreteSameDay' isn't a type`).
3. Implementamos `lib/frete/strategy/frete_same_day.dart` (mesma estrutura das outras estratégias).
4. Rodamos de novo → **GREEN**.
5. Adicionamos `sameDay` no enum `TipoFrete`.
6. Conectamos a nova Strategy na calculadora — **uma linha** no `switch`:

```dart
TipoFrete.sameDay => FreteSameDay(),
```

Esse é o ganho do Strategy Pattern: uma modalidade nova é uma **classe nova**, sem mexer nas fórmulas das outras.
E como o `switch` expression precisa cobrir todos os valores do enum, o próprio compilador avisa se esquecermos de ligar a modalidade nova.

---

## 11. Desafio 2 — Cupom FRETE20

> O cupom `FRETE20` oferece 20% de desconto no frete.

| Cupom     | Frete original | Desconto | Frete final |
|-----------|----------------|----------|-------------|
| `FRETE20` | R$ 50,00       | R$ 10,00 | R$ 40,00    |

**RED** — testes no catálogo (`buscar('FRETE20')` com 20%, e `aplicar(50.0)` resultando em 40) e na calculadora.
Para chegar num frete de R$ 50,00 no Econômico: `8 + (2 × 2) + (380 × 0,10) = 50` → com o cupom, R$ 40,00.
Rodando: só os 3 testes do FRETE20 falharam.

**GREEN** — pergunta do desafio: *é necessário alterar a lógica da `CalculadoraFrete`?*
**Não.** Bastou cadastrar o cupom no catálogo:

```dart
'FRETE20': CupomFrete(
  codigo: 'FRETE20',
  percentualDesconto: 0.20,
),
```

---

## 12. Desafio 3 — Organizando os testes com `group`

Reorganizamos o `calculadora_frete_test.dart` em grupos. A organização **não muda o comportamento** dos testes,
mas deixa o relatório muito mais fácil de ler:

```dart
void main() {
  late CalculadoraFrete calculadora;

  setUp(() {
    calculadora = CalculadoraFrete();
  });

  group('Validações', () {
    // peso zero, peso negativo, distância negativa, distância zero permitida
  });

  group('Modalidades', () {
    // econômico, expresso, retirada e same day
  });

  group('Frete grátis', () {
    // limite de R$ 300 (300,00 e 299,99) e prazo mantido
  });

  group('Cupons', () {
    // FRETEGRATIS, FRETE50, FRETE20, inválido, sem cupom, minúsculo, prioridade
  });
}
```

Na saída do `flutter test` o nome do grupo aparece antes do teste, por exemplo:

```text
Cupons cupom FRETE20 deve aplicar vinte por cento de desconto
```

Aproveitamos para incluir alguns testes extras:

- `throwsA(isA<ArgumentError>())` → forma mais específica de verificar o tipo da exceção;
- distância zero é permitida (estava na tabela de validações mas não tinha teste);
- frete grátis zera o valor mas **não altera o prazo** (garante o uso correto do `copyWith`).

---

## 13. Estrutura final e comandos

```text
lib/
├── cupom/
│   ├── catalogo_cupons.dart
│   └── cupom_frete.dart
├── frete/
│   ├── calculadora_frete.dart
│   └── strategy/
│       ├── frete_economico.dart
│       ├── frete_expresso.dart
│       ├── frete_same_day.dart
│       ├── frete_strategy.dart
│       └── retirada_loja.dart
├── models/
│   ├── resultado_frete.dart
│   └── tipo_frete.dart
└── main.dart

test/
├── cupom/
│   └── catalogo_cupons_test.dart
└── frete/
    ├── calculadora_frete_test.dart
    └── strategy/
        ├── frete_economico_test.dart
        ├── frete_expresso_test.dart
        ├── frete_same_day_test.dart
        └── retirada_loja_test.dart
```

Resultado final: **41 testes passando** e `flutter analyze` sem nenhum problema.

### Comandos úteis

| Comando                                                      | Para quê                       |
|--------------------------------------------------------------|--------------------------------|
| `flutter test`                                               | todos os testes                |
| `flutter test test/frete`                                    | só os testes de frete          |
| `flutter test test/frete/calculadora_frete_test.dart`        | um arquivo                     |
| `flutter test --plain-name "FRETE50"`                        | testes pelo nome               |
| `flutter test --reporter expanded`                           | saída detalhada                |
| `flutter analyze`                                            | análise estática do código     |

### Matchers usados

| Matcher                        | Uso                                    |
|--------------------------------|----------------------------------------|
| `closeTo(valor, tolerancia)`   | comparar `double`                      |
| `throwsArgumentError`          | espera um `ArgumentError`              |
| `throwsA(isA<ArgumentError>())`| verificação mais específica de exceção |
| `greaterThan(valor)`           | maior que                              |
| `isNull` / `isNotNull`         | valor nulo / não nulo                  |

### Histórico de commits (uma etapa por commit)

1. Frete grátis para compras a partir de R$ 300 e testes de fronteira
2. Cupons FRETEGRATIS e FRETE50 com prioridade do frete grátis por compra
3. Refatora cálculo das modalidades com Strategy Pattern
4. Catálogo de cupons para remover ifs da calculadora
5. Desafio 1: nova modalidade Frete Same Day
6. Desafios 2 e 3: cupom FRETE20 e testes organizados com group
