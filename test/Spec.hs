module Main (main) where

import Control.Monad (unless)
import System.Exit (exitFailure)
import Test.QuickCheck
import QuickTestes

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
    -- Uma falha deve fazer cabal test terminar com codigo de erro.
    unless (all isSuccess results) exitFailure
