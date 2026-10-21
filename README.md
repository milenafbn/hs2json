# hs2json

Biblioteca Haskell para representação de dados JSON, com *pretty printing* e testes
baseados em propriedades com QuickCheck.

## 🎥 Vídeo de apresentação

> **[Assistir ao vídeo](https://youtu.be/vVflKnpbUjw?si=MADFk7DyIcxM3AzR)**

## 🎓 Identificação

|               |                                                                                                  |
| ------------- | ------------------------------------------------------------------------------------------------ |
| Instituição | Universidade Federal do Maranhão (UFMA)                                                         |
| Curso         | Engenharia da Computação                                                                       |
| Disciplina    | EECP0047 — Tópicos em Engenharia da Computação II — Introdução à Programação Funcional |
| Docente       | Prof. Sergio Souza Costa                                                                         |
| Avaliação   | Segunda unidade                                                                                  |
| Discentes     | Ana Iara Loayza Costa e Milena Freire Britto Neves                                               |

O desenvolvimento seguiu o
[tutorial da disciplina](https://lambdageo-edu.github.io/lambdageo-tutorials/haskell/),
capítulos 1 a 9.

## 📁 Estrutura

| Módulo                | Descrição                                                                                       |
| ---------------------- | ------------------------------------------------------------------------------------------------- |
| `src/SimpleJSON.hs`  | Tipo `JValue` e funções de acesso (*accessors*).                                            |
| `src/PutJSON.hs`     | Renderização simples de `JValue` em texto.                                                    |
| `src/Prettify.hs`    | Tipo `Doc`, combinadores (`fill`, `nest`, etc.) e renderizações `compact` e `pretty`. |
| `src/PrettyJSON.hs`  | Conversão de `JValue` em `Doc`, com escapes de strings e Unicode.                            |
| `src/QuickTestes.hs` | Exemplos introdutórios de QuickCheck (`qsort`, `Ternary`).                                   |
| `test/Spec.hs`       | Suíte de testes com QuickCheck.                                                                  |
| `app/Main.hs`        | Executável de exemplo.                                                                           |

## ▶️ Como executar

Requisitos: GHC 9.x e cabal-install 3.x (recomendado instalar via GHCup).

```sh
git clone https://github.com/milenafbn/hs2json.git
cd hs2json
cabal build
cabal run
```

Saída esperada:

```text
{"foo": 1.0, "bar": false}
```

Exemplo do *pretty printer* no `cabal repl`:

```haskell
import SimpleJSON
import PrettyJSON
import Prettify (compact, pretty)
let value = renderJValue (JObject [("f", JNumber 1), ("q", JBool True)])
putStrLn (compact value)
putStrLn (pretty 10 value)
```

## 🧪 Testes

```sh
cabal test --test-show-details=direct
```

A suíte contém **28 propriedades**, cada uma verificada com 100 casos aleatórios:

| Grupo                   | Qtd. | O que verifica                                                                               |
| ----------------------- | ---- | -------------------------------------------------------------------------------------------- |
| Ordenação (`qsort`) | 7    | Idempotência, ordenação, permutação, mínimo, máximo e equivalência com `sort`.     |
| Operações de `Doc`  | 7    | Identidade de `empty`, `char`, `text`, `line`, `double`, `hcat` e `punctuate`. |
| Renderização          | 5    | Saídas de `compact` e `pretty`, respeito à largura e equivalência de conteúdo.       |
| JSON                    | 9    | Os sete *accessors* e a corretude dos escapes simples e Unicode.                           |

O gerador `Arbitrary JValue` usa ``resize (n `div` 2)`` em torno de `listOf` em
`JObject` e `JArray`, o que limita a profundidade e o tamanho das estruturas e evita
o consumo excessivo de memória.

Relatório de cobertura (HPC):

```sh
cabal test --enable-coverage
```

O caminho do `hpc_index.html` é exibido ao final da execução.
