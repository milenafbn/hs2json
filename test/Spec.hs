{-# LANGUAGE TemplateHaskell #-}

module Main where

import Prelude hiding ((<>))
import Control.Monad (liftM, liftM2)
import Data.List (intersperse)
import System.Exit (exitFailure)
import Test.QuickCheck
import QuickTestes
import Prettify

-- Gera os seis construtores de Doc, incluindo documentos recursivos
-- A instancia fica nos testes; os usuarios da biblioteca nao precisam dela
instance Arbitrary Doc where
    arbitrary = oneof
        [ return Empty
        , liftM Char arbitrary
        , liftM Text arbitrary
        , return Line
        , liftM2 Concat arbitrary arbitrary
        , liftM2 Union arbitrary arbitrary
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
