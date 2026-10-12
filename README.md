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

Implementamos as etapas dos **capítulos 1 a 6** do tutorial. Já conseguimos representar dados
JSON, consultar seus valores e mostrar esses dados no terminal de duas formas: com o
renderizador simples (`PutJSON`) e com o *pretty printer* (`PrettyJSON` + `Prettify`),
que quebra as linhas de acordo com a largura disponível e indenta arrays e objetos.

No capítulo 6 resolvemos os dois exercícios propostos pelo tutorial, que não trazem
resposta pronta:

- `fill`: completa um documento com espaços até uma largura (útil para alinhar colunas).
- `nest`: indenta as linhas que vêm depois de uma quebra. O `PrettyJSON` usa `nest 2`
  em arrays e objetos, e os níveis aninhados somam (2, 4, 6... espaços).

Também completamos o `hs2json.cabal` com `synopsis`, `description` e `category`, e
ampliamos a faixa de versão do `base` para `>= 4.7 && < 5`, para que o projeto compile
com diferentes versões do GHC.

| Arquivo | Para que serve |
| --- | --- |
| `src/SimpleJSON.hs` | Define os tipos de dados JSON e as funções para consultar seus valores. |
| `src/PutJSON.hs` | Transforma os dados JSON em texto e mostra no terminal. |
| `src/Prettify.hs` | Biblioteca de formatação: o tipo `Doc`, as funções para montar documentos (incluindo `fill` e `nest`) e as renderizações `compact` e `pretty`. |
| `src/PrettyJSON.hs` | Converte dados JSON em `Doc`, com a formatação de strings (incluindo escapes Unicode), números, booleanos, null, arrays e objetos indentados. |
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

## 🚧 Próximas etapas

O exemplo em `cabal run` continua usando o renderizador simples `PutJSON`, como no tutorial.

Nos próximos capítulos, vamos:

- Eliminar os avisos do compilador (`-Wall`) sobre variáveis não usadas.
- Adicionar testes com QuickCheck, que serão executados com `cabal test`.

## 🎥 Vídeo de apresentação

**O link será adicionado aqui após a gravação do vídeo.**
