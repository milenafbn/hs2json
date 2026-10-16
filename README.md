# hs2json — Avaliação da Segunda Unidade

Projeto em Haskell feito em dupla para a **avaliação da segunda unidade** da
disciplina de Introdução à Programação Funcional, na
**Universidade Federal do Maranhão (UFMA)**.

O objetivo é criar uma biblioteca para representar dados JSON, mostrar esses dados
de forma organizada e testar o código com QuickCheck. O desenvolvimento segue o
[tutorial da disciplina](https://lambdageo-edu.github.io/lambdageo-tutorials/haskell/).

## 🎓 Informações da atividade

| Informação | Descrição |
| --- | --- |
| Curso | Engenharia da Computação |
| Disciplina | EECP0047 — TÓPICOS EM ENGENHARIA DA COMPUTAÇÃO II - INTRODUÇÃO A PROGRAMAÇÃO FUNCIONAL |
| Docente | Sergio Souza Costa |

**Integrantes da dupla:**

- ANA IARA LOAYZA COSTA
- MILENA FREIRE BRITTO NEVES

## 📚 O que já foi feito

Implementamos as etapas dos **capítulos 1 a 9** do tutorial. Já conseguimos representar dados
JSON, consultar seus valores e mostrar esses dados no terminal de duas formas: com o
renderizador simples (`PutJSON`) e com o *pretty printer* (`PrettyJSON` + `Prettify`),
que quebra as linhas de acordo com a largura disponível e indenta arrays e objetos.

No capítulo 6 resolvemos os dois exercícios propostos pelo tutorial, que não trazem
resposta pronta:

- `fill`: completa um documento com espaços até uma largura (útil para alinhar colunas).
- `nest`: indenta as linhas que vêm depois de uma quebra. O `PrettyJSON` usa `nest 2`
  em arrays e objetos, e os níveis aninhados somam (2, 4, 6... espaços).

Na versão atual, `fill` calcula os espaços considerando o documento sem quebras
de linha. Ele funciona para os exemplos de uma linha; não preenche cada linha
separadamente em documentos com várias linhas.

Também completamos o `hs2json.cabal` com `synopsis`, `description` e `category`, e
ampliamos a faixa de versão do `base` para `>= 4.7 && < 5`, para que o projeto compile
com diferentes versões do GHC.

| Arquivo | Para que serve |
| --- | --- |
| `src/SimpleJSON.hs` | Define os tipos de dados JSON e as funções para consultar seus valores. |
| `src/PutJSON.hs` | Transforma os dados JSON em texto e mostra no terminal. |
| `src/Prettify.hs` | Biblioteca de formatação: o tipo `Doc`, as funções para montar documentos (incluindo `fill` e `nest`) e as renderizações `compact` e `pretty`. |
| `src/PrettyJSON.hs` | Converte dados JSON em `Doc`, com a formatação de strings (incluindo escapes Unicode), números, booleanos, null, arrays e objetos indentados. |
| `src/QuickTestes.hs` | Exemplos de ordenação e geração de valores do tipo `Ternary` com QuickCheck. |
| `test/Spec.hs` | Gera documentos e valores JSON aleatórios e executa os testes de ordenação, documentos, accessors e escapes. |
| `app/Main.hs` | Executa um exemplo de uso do projeto. |

## ▶️ Como executar

Com **GHC e Cabal instalados**, abra o terminal na pasta do projeto e execute:

```sh
# Compilar o projeto
cabal build

# Executar o exemplo
cabal run
```

Saída esperada do executável:

```text
{"foo": 1.0, "bar": false}
```

Para experimentar outros valores, execute `cabal repl` e digite:

```haskell
import SimpleJSON
import PutJSON
putJValue (JObject [("nome", JString "Sergio"), ("idade", JNumber 38)])
renderJValue (JArray [JBool True, JNull])
```

Para testar o *pretty printer*, em uma nova sessão do `cabal repl`:

```haskell
import SimpleJSON
import PrettyJSON
import Prettify (compact, pretty)
let value = renderJValue (JObject [("f", JNumber 1), ("q", JBool True)])
putStrLn (compact value)
putStrLn (pretty 10 value)
putStrLn (pretty 30 value)
```

Com largura 30 o objeto cabe em uma linha (`{"f": 1.0, "q": true }`). Com largura 10,
ele é quebrado em várias linhas, com indentação:

```text
{"f": 1.0,
  "q": true
  }
```

> **Atenção:** importe só as funções necessárias de `Prettify`, como no exemplo. Com
> `import Prettify` completo, o operador `<>` fica ambíguo com o `<>` do Prelude.

## 🧪 Testes com QuickCheck

No capítulo 7, usamos uma função de ordenação (`qsort`) para aprender a escrever
propriedades. O QuickCheck gera listas e verifica se as regras valem para elas.

```sh
cabal test --test-show-details=direct
```

A suíte verifica sete propriedades: ordenar duas vezes dá o mesmo resultado;
o primeiro elemento é o mínimo; a saída está ordenada; os elementos e suas
repetições são preservados; o último é o máximo; o mínimo da junção de duas
listas é o menor dos mínimos; e o resultado coincide com `sort` da biblioteca padrão.
Cada propriedade precisa passar em 100 testes. Algumas descartam listas vazias,
pois funções como `head` e `minimum` não aceitam essas listas.

Para experimentar em `cabal repl`:

```haskell
import QuickTestes
import Test.QuickCheck
qsort [3, 1, 2, 1]
quickCheck (prop_idempotent :: [Integer] -> Bool)
quickCheck (prop_minimum' :: [Integer] -> Property)
```

O tutorial também apresenta `prop_minimum`, sem tratar a lista vazia. Mantivemos
esse exemplo para estudo no REPL, mas ele não entra na suíte automática porque
falha para `[]`. A versão corrigida é `prop_minimum'`.

No capítulo 8, acrescentamos `Arbitrary Doc`, que gera documentos aleatórios,
e sete propriedades sobre as funções básicas da biblioteca:

- Concatenar com `empty` mantém o documento.
- `char`, `text`, `line` e `double` criam os documentos esperados.
- `hcat` combina a lista como uma concatenação recursiva.
- `punctuate` acrescenta os separadores, considerando a simplificação de documentos vazios.

Essas propriedades são encontradas automaticamente por `quickCheckAll`, usando
Template Haskell. `prop_line` não recebe entradas: ela verifica uma igualdade fixa.
Na versão instalada do QuickCheck (2.19), `quickCheckAll` reportou 100 testes
para cada propriedade, inclusive essa, diferente da saída ilustrada no PDF.
Os sete testes de ordenação continuam na suíte.
Se qualquer grupo falhar, o programa devolve um código de erro ao Cabal.

Para experimentar o gerador de documentos e as propriedades no REPL:

```sh
cabal repl test:hs2json-test
```

```haskell
generate arbitrary :: IO [Doc]
quickCheck prop_empty_id
quickCheck prop_punctuate'
```

Como no tutorial, `Doc(..)` agora exporta os construtores para permitir os testes.
O exemplo `Ternary` pode ser experimentado no REPL com
`generate arbitrary :: IO [Ternary]` depois de importar `QuickTestes` e `Test.QuickCheck`.

No capítulo 9, acrescentamos cinco propriedades de renderização: texto puro em
`compact` e `pretty`, respeito à largura quando cada palavra cabe na linha,
preservação de palavras maiores que a largura e equivalência de conteúdo entre
layouts. Nessa última comparação, ignoramos espaços e quebras de linha e usamos
apenas alternativas de layout que representam o mesmo conteúdo.

O gerador de `Doc` agora usa `sized` e `frequency` para controlar a recursão.
Também implementamos `shrink = genericShrink`, com `Generic` em `Doc`, para
reduzir os contraexemplos quando uma propriedade falha.

Para cumprir os requisitos de JSON da atividade, adicionamos `Arbitrary JValue`,
sete propriedades de accessors (incluindo `isNull`) e duas de escapes: caracteres
especiais e Unicode, incluindo pares substitutos. Nos objetos e arrays, o gerador
usa ``resize (n `div` 2)`` em volta de `listOf`, limitando também o comprimento das
listas. Os números gerados são finitos, entre -1.000.000 e 1.000.000.

A suíte tem **28 propriedades** no total: 7 de ordenação, 7 de operações básicas
de documentos, 5 de renderização e 9 de JSON.

## 📊 Cobertura de testes — capítulo 9

Para executar os testes e gerar o relatório HPC:

```sh
cabal test --enable-coverage --test-show-details=direct
```

O Cabal mostra o caminho de `hpc_index.html` no final. Abra esse arquivo no
navegador para ver quais partes do código foram executadas. O relatório fica em
`dist-newstyle/`, que é ignorado pelo Git; ele pode ser gerado novamente.

Na execução desta etapa, com GHC 9.10.3 e QuickCheck 2.19, medimos estes resultados
para o módulo **Prettify**:

| Medida | Antes | Depois |
| --- | --- | --- |
| Expressões executadas | 16% (30/187) | 79% (148/187) |
| Alternativas executadas | 21% (8/38) | 86% (33/38) |
| Declarações locais executadas | 0% (0/5) | 80% (4/5) |

Os percentuais podem variar entre execuções e versões das ferramentas. Cobertura
mostra o que foi executado; sozinha, ela não prova que o código está correto.
`fill`, `nest` e outros caminhos ainda permitem ampliar a cobertura.

Para observar a redução de um contraexemplo, execute `cabal repl test:hs2json-test`
e experimente esta propriedade **falsa de propósito**, apenas no REPL:

```haskell
quickCheck (forAllShrink (pure (text "bug")) shrink (\d -> compact d == ""))
```

O resultado esperado é uma falha com um documento menor. Essa propriedade não
faz parte da suíte automática.

## 🚧 Próximas etapas

O exemplo em `cabal run` continua usando o renderizador simples `PutJSON`, como no tutorial.

Antes da entrega, ainda precisamos:

- Eliminar os avisos do compilador (`-Wall`) sobre variáveis não usadas.
- Revisar as limitações conhecidas, como o preenchimento de documentos com várias linhas.
- Gravar o vídeo de apresentação e adicionar o link ao README.

## 🎥 Vídeo de apresentação

**O link será adicionado aqui após a gravação do vídeo.**
