module Prettify where

-- Evita conflito com o operador (<>) que ja existe no Prelude.
import Prelude hiding ((<>))

-- Esboco do documento; sera implementado no capitulo 5.
-- As funcoes com undefined compilam, mas dao erro se forem executadas.
data Doc = ToBeDefined
           deriving (Show)

string :: String -> Doc
string str = undefined

text :: String -> Doc
text str = undefined

double :: Double -> Doc
double num = undefined

-- Junta dois documentos.
(<>) :: Doc -> Doc -> Doc
a <> b = undefined

char :: Char -> Doc
char c = undefined

-- Junta uma lista de documentos em um so.
hcat :: [Doc] -> Doc
hcat xs = undefined

-- Combinara documentos com a possibilidade de quebrar linhas.
fsep :: [Doc] -> Doc
fsep xs = undefined

-- Acrescenta o separador a cada documento, exceto ao ultimo.
punctuate :: Doc -> [Doc] -> [Doc]
punctuate p [] = []
punctuate p [d] = [d]
punctuate p (d:ds) = (d <> p) : punctuate p ds
