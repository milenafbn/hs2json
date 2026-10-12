module Prettify
    (
      Doc
    , empty
    , char
    , text
    , double
    , line
    , (<>)
    , hcat
    , fsep
    , (</>)
    , punctuate
    , group
    , softline
    , compact
    ) where

-- Evita conflito com o operador (<>) que ja existe no Prelude.
import Prelude hiding ((<>))

-- Documento em forma de arvore: Concat e Union sao nos internos, o resto sao folhas.
data Doc = Empty
         | Char Char
         | Text String
         | Line
         | Concat Doc Doc
         | Union Doc Doc
           deriving (Show, Eq)

empty :: Doc
empty = Empty

char :: Char -> Doc
char c = Char c

text :: String -> Doc
text "" = Empty
text s  = Text s

double :: Double -> Doc
double d = text (show d)

-- Quebra de linha que sempre aparece.
line :: Doc
line = Line

-- Junta dois documentos. Empty e o elemento neutro.
(<>) :: Doc -> Doc -> Doc
Empty <> y = y
x <> Empty = x
x <> y = x `Concat` y

-- Junta uma lista de documentos em um so.
hcat :: [Doc] -> Doc
hcat = fold (<>)

fold :: (Doc -> Doc -> Doc) -> [Doc] -> Doc
fold f = foldr f empty

-- Junta documentos com uma quebra de linha opcional entre eles.
fsep :: [Doc] -> Doc
fsep = fold (</>)

(</>) :: Doc -> Doc -> Doc
x </> y = x <> softline <> y

-- Quebra de linha que so aparece se a linha nao couber.
softline :: Doc
softline = group line

-- Guarda duas versoes do documento: achatada (esquerda) e original (direita).
group :: Doc -> Doc
group x = flatten x `Union` x

-- Troca as quebras de linha por espacos.
flatten :: Doc -> Doc
flatten (x `Concat` y) = flatten x `Concat` flatten y
flatten Line           = Char ' '
flatten (x `Union` _)  = flatten x
flatten other          = other

-- Renderiza sem se preocupar com largura: so emite os caracteres.
compact :: Doc -> String
compact x = transform [x]
    where transform [] = ""
          transform (d:ds) =
              case d of
                Empty        -> transform ds
                Char c       -> c : transform ds
                Text s       -> s ++ transform ds
                Line         -> '\n' : transform ds
                a `Concat` b -> transform (a:b:ds)
                _ `Union` b  -> transform (b:ds)

-- Acrescenta o separador a cada documento, exceto ao ultimo.
punctuate :: Doc -> [Doc] -> [Doc]
punctuate p [] = []
punctuate p [d] = [d]
punctuate p (d:ds) = (d <> p) : punctuate p ds
