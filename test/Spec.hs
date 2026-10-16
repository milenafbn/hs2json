{-# LANGUAGE TemplateHaskell #-}

module Main where

import Prelude hiding ((<>))
import Data.Char (isSpace)
import Data.List (intersperse)
import System.Exit (exitFailure)
import Test.QuickCheck
import QuickTestes
import Prettify
import SimpleJSON
import qualified PrettyJSON as JSON

-- Diminui o tamanho em cada ramo e usa apenas folhas quando chega a zero.
instance Arbitrary Doc where
    arbitrary = sized doc
      where
        doc n
            | n <= 0 = leaf
            | otherwise = frequency
                [ (4, leaf)
                , (1, Concat <$> smaller <*> smaller)
                , (1, Union <$> smaller <*> smaller)
                ]
          where smaller = resize (n `div` 2) (doc (n `div` 2))
        leaf = oneof [return Empty, Char <$> arbitrary, Text <$> arbitrary, return Line]

    -- Reduz a arvore e seus campos ao procurar um contraexemplo menor.
    shrink = genericShrink

-- Controla tanto a profundidade quanto o comprimento das listas recursivas.
instance Arbitrary JValue where
    arbitrary = sized value
      where
        value n
            | n <= 0 = scalar
            | otherwise = frequency [(4, scalar), (2, recursive)]
          where
            smaller = value (n `div` 2)
            field = (,) <$> arbitrary <*> smaller
            recursive = oneof
                [ JObject <$> resize (n `div` 2) (listOf field)
                , JArray <$> resize (n `div` 2) (listOf smaller)
                ]
        -- Numeros finitos e pequenos tambem permitem testar getInt com seguranca.
        scalar = oneof
            [ JString <$> arbitrary
            , JNumber <$> choose (-1000000, 1000000)
            , JBool <$> arbitrary
            , return JNull
            ]

-- Concatenar com o documento vazio nao muda o documento
prop_empty_id :: Doc -> Bool
prop_empty_id x = empty <> x == x && x <> empty == x

prop_char :: Char -> Bool
prop_char c = char c == Char c

prop_text :: String -> Bool
prop_text s = text s == if null s then Empty else Text s

prop_line :: Bool
prop_line = line == Line

prop_double :: Double -> Bool
prop_double d = double d == text (show d)

-- Compara hcat com uma concatenacao recursiva de referencia
prop_hcat :: [Doc] -> Bool
prop_hcat xs = hcat xs == glue xs
  where glue [] = empty
        glue (d:ds) = d <> glue ds

-- O modelo intercala separadores e combina os pares, simplificando Empty.
-- Comparar diretamente com intersperse seria uma propriedade incorreta.
prop_punctuate' :: Doc -> [Doc] -> Bool
prop_punctuate' s xs = punctuate s xs == combine (intersperse s xs)
  where combine [] = []
        combine [x] = [x]
        combine (x:Empty:ys) = x : combine ys
        combine (Empty:y:ys) = y : combine ys
        combine (x:y:ys) = x `Concat` y : combine ys

-- Primeiro teste de renderizacao apresentado no capitulo 9.
prop_compact_text :: String -> Bool
prop_compact_text s = compact (text s) == s

prop_pretty_text :: Int -> String -> Bool
prop_pretty_text w s = pretty w (text s) == s

-- A largura so pode ser garantida se cada palavra couber sozinha.
-- Usamos palavras sem espacos ou quebras de linha e limitadas a largura.
prop_pretty_width :: Positive Int -> [String] -> Property
prop_pretty_width (Positive n) xs =
    counterexample rendered (all ((<= width) . length) (lines rendered))
  where
    width = 1 + n `mod` 80
    word s = take width (case filter (\c -> c >= 'a' && c <= 'z') s of
                            "" -> "x"
                            letters -> letters)
    rendered = pretty width (fsep (map (text . word) xs))

-- Um trecho indivisivel pode ultrapassar a largura: pretty nao corta palavras.
prop_pretty_unbreakable :: Positive Int -> Bool
prop_pretty_unbreakable (Positive n) =
    pretty width (text token) == token
  where width = 1 + n `mod` 80
        token = replicate (width + 1) 'x'

-- Union gerado ao acaso pode ter textos diferentes em cada lado.
-- Para comparar layouts, reconstruimos apenas escolhas com o mesmo conteudo.
layoutDoc :: Doc -> Doc
layoutDoc (Concat a b) = layoutDoc a <> layoutDoc b
layoutDoc (Union _ b) = group (layoutDoc b)
layoutDoc other = other

prop_compact_pretty_content :: Int -> Doc -> Bool
prop_compact_pretty_content width d =
    content (compact valid) == content (pretty width valid)
  where valid = layoutDoc d
        -- Equivalencia deste exercicio: ignora todos os caracteres de espaco.
        content = filter (not . isSpace)

-- Accessors devem aceitar o construtor certo e rejeitar os outros com Nothing.
prop_getString :: JValue -> Bool
prop_getString v = getString v == case v of
    JString s -> Just s
    _ -> Nothing

prop_getInt :: JValue -> Bool
prop_getInt v = getInt v == case v of
    JNumber n -> Just (truncate n)
    _ -> Nothing

prop_getDouble :: JValue -> Bool
prop_getDouble v = getDouble v == case v of
    JNumber n -> Just n
    _ -> Nothing

prop_getBool :: JValue -> Bool
prop_getBool v = getBool v == case v of
    JBool b -> Just b
    _ -> Nothing

prop_getObject :: JValue -> Bool
prop_getObject v = getObject v == case v of
    JObject fields -> Just fields
    _ -> Nothing

prop_getArray :: JValue -> Bool
prop_getArray v = getArray v == case v of
    JArray values -> Just values
    _ -> Nothing

prop_isNull :: JValue -> Bool
prop_isNull v = isNull v == case v of
    JNull -> True
    _ -> False

-- Casos conhecidos verificam escapes sem depender de um segundo renderizador.
prop_json_simple_escapes :: Property
prop_json_simple_escapes = forAll (elements examples) $ \(input, expected) ->
    compact (JSON.renderJValue (JString input)) === expected
  where examples =
            [ ("\"", "\"\\\"\"")
            , ("\\", "\"\\\\\"")
            , ("\n", "\"\\n\"")
            , ("\t", "\"\\t\"")
            , ("\b\f\r/", "\"\\b\\f\\r\\/\"")
            ]

prop_json_unicode_escapes :: Property
prop_json_unicode_escapes = forAll (elements examples) $ \(input, expected) ->
    compact (JSON.renderJValue (JString input)) === expected
  where examples =
            [ ("\x0", "\"\\u0000\"")
            , ("\x7f", "\"\\u007f\"")
            , ("\x100", "\"\\u0100\"")
            , ("\xffff", "\"\\uffff\"")
            , ("\x10000", "\"\\ud800\\udc00\"")
            , ("\x1f600", "\"\\ud83d\\ude00\"")
            , ("\x10ffff", "\"\\udbff\\udfff\"")
            ]

-- Separa as declaracoes para o Template Haskell encontrar as propriedades acima
return []

runTests :: IO Bool
runTests = $quickCheckAll

-- Mostra o nome da propriedade e guarda o resultado para o Cabal
check :: Testable prop => String -> prop -> IO Result
check name prop = do
    putStrLn name
    quickCheckResult prop

main :: IO ()
main = do
    -- Integer evita que o polimorfismo escolha um tipo pouco util nos testes.
    results <- sequence
        [ check "prop_idempotent" (prop_idempotent :: [Integer] -> Bool)
        , check "prop_minimum'" (prop_minimum' :: [Integer] -> Property)
        , check "prop_ordered" (prop_ordered :: [Integer] -> Bool)
        , check "prop_permutation" (prop_permutation :: [Integer] -> Bool)
        , check "prop_maximum" (prop_maximum :: [Integer] -> Property)
        , check "prop_append" (prop_append :: [Integer] -> [Integer] -> Property)
        , check "prop_sort_model" (prop_sort_model :: [Integer] -> Bool)
        ]
    passed <- runTests
    -- Uma falha em qualquer grupo deve ser informada ao Cabal
    if all isSuccess results && passed
        then putStrLn "Passou em todos os testes."
        else do
            putStrLn "Alguns testes falharam."
            exitFailure
