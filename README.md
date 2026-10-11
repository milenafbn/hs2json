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

Concluímos os **capítulos 1 a 3** do tutorial. Já conseguimos representar dados
JSON e mostrar esses dados no terminal. A parte que vai organizar a saída com
quebras de linha e indentação (o *pretty printer*) ainda está no início.

| Arquivo | Para que serve |
| --- | --- |
| `src/SimpleJSON.hs` | Define os tipos de dados JSON e as funções para consultar seus valores. |
| `src/PutJSON.hs` | Transforma os dados JSON em texto e mostra no terminal. |
| `src/Prettify.hs` | Contém o início da biblioteca de formatação. |
| `src/PrettyJSON.hs` | Contém o início da formatação de JSON usando essa biblioteca. |
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

## 🚧 Próximas etapas

As funções de `Prettify` ainda usam `undefined`, uma marcação temporária prevista
no tutorial. Por enquanto, essas funções dão erro se forem executadas.
`PrettyJSON` também ainda não formata arrays e objetos.

Nos próximos capítulos, vamos:

- Tratar caracteres especiais nas strings, como aspas e quebras de linha.
- Completar a formatação de arrays e objetos.
- Implementar a biblioteca `Prettify`.
- Adicionar testes com QuickCheck, que serão executados com `cabal test`.

## 🎥 Vídeo de apresentação

**O link será adicionado aqui após a gravação do vídeo.**
