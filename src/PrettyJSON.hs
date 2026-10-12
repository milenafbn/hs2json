module PrettyJSON
    ( renderJValue
    ) where

import Prelude hiding ((<>))
import Numeric (showHex)
import Data.Char (ord)
import Data.Bits (shiftR, (.&.))
import SimpleJSON (JValue(..))
import Prettify (Doc, (<>), char, double, fsep, hcat, nest, punctuate, text)

-- Converte cada tipo JSON em um documento, sem imprimir no terminal.
renderJValue :: JValue -> Doc
renderJValue (JBool True) = text "true"
renderJValue (JBool False) = text "false"
renderJValue JNull = text "null"
renderJValue (JNumber num) = double num
renderJValue (JString str) = string str
renderJValue (JArray ary) = series '[' ']' renderJValue ary
renderJValue (JObject obj) = series '{' '}' field obj
  where field (name,val) = string name
                          <> text ": "
                          <> renderJValue val

-- Escapa cada caractere, junta os resultados e coloca aspas ao redor.
string :: String -> Doc
string = enclose '"' '"' . hcat . map oneChar

-- Mesma operacao de string, com o argumento explicito, para comparacao.
pointyString :: String -> Doc
pointyString s = enclose '"' '"' (hcat (map oneChar s))

-- Coloca um documento entre caracteres de abertura e fechamento.
enclose :: Char -> Char -> Doc -> Doc
enclose left right x = char left <> x <> char right

-- Procura um escape conhecido. Se necessario, usa um escape Unicode.
oneChar :: Char -> Doc
oneChar c = case lookup c simpleEscapes of
              Just r -> text r
              Nothing | mustEscape c -> hexEscape c
                      | otherwise -> char c
  where mustEscape ch = ch < ' ' || ch == '\x7f' || ch > '\xff'

-- Associa caracteres especiais a seus escapes JSON, como newline a \\n.
simpleEscapes :: [(Char, String)]
simpleEscapes = zipWith ch "\b\n\f\r\t\\\"/" "bnfrt\\\"/"
  where ch a b = (a, ['\\',b])

-- Produz um escape \\uXXXX, completando quatro digitos com zeros.
smallHex :: Int -> Doc
smallHex x = text "\\u"
             <> text (replicate (4 - length h) '0')
             <> text h
  where h = showHex x ""

-- Divide o codigo ajustado em dois escapes UTF-16 (par substituto).
astral :: Int -> Doc
astral n = smallHex (a + 0xd800) <> smallHex (b + 0xdc00)
  where a = (n `shiftR` 10) .&. 0x3ff
        b = n .&. 0x3ff

-- Caracteres acima de 0xFFFF precisam de um par de escapes.
hexEscape :: Char -> Doc
hexEscape c | d < 0x10000 = smallHex d
            | otherwise = astral (d - 0x10000)
  where d = ord c

-- Estrutura comum de arrays e objetos: delimitadores e itens com virgulas.
-- O nest 2 indenta os itens quando a linha quebra.
series :: Char -> Char -> (a -> Doc) -> [a] -> Doc
series open close item = enclose open close . nest 2
                         . fsep . punctuate (char ',') . map item
