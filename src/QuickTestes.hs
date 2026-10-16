module QuickTestes where

import Data.List (sort, (\\))
import Test.QuickCheck

-- Exemplo do capitulo 8: escolhe um dos tres valores da logica ternaria
data Ternary = Yes | No | Unknown
    deriving (Eq, Show)

instance Arbitrary Ternary where
    arbitrary = elements [Yes, No, Unknown]

-- Ordena recursivamente os elementos menores e os maiores ou iguais ao pivo
qsort :: Ord a => [a] -> [a]
qsort [] = []
qsort (x:xs) = qsort lhs ++ [x] ++ qsort rhs
  where lhs = filter (< x) xs
        rhs = filter (>= x) xs

-- Ordenar novamente nao deve mudar o resultado
prop_idempotent :: Ord a => [a] -> Bool
prop_idempotent xs = qsort (qsort xs) == qsort xs

-- Exemplo inicial do tutorial: falha para [], pois head e minimum sao parciais
-- Mantido para experimentar no REPL; nao faz parte da suite automatica
prop_minimum :: Ord a => [a] -> Bool
prop_minimum xs = head (qsort xs) == minimum xs

-- A implicacao descarta listas vazias antes de avaliar head e minimum
prop_minimum' :: Ord a => [a] -> Property
prop_minimum' xs = not (null xs) ==> head (qsort xs) == minimum xs

prop_ordered :: Ord a => [a] -> Bool
prop_ordered xs = ordered (qsort xs)
  where ordered [] = True
        ordered [_] = True
        ordered (x:y:ys) = x <= y && ordered (y:ys)

-- Confere se nenhum elemento foi perdido ou acrescentado, incluindo repetidos
prop_permutation :: Ord a => [a] -> Bool
prop_permutation xs = permutation xs (qsort xs)
  where permutation as bs = null (as \\ bs) && null (bs \\ as)

prop_maximum :: Ord a => [a] -> Property
prop_maximum xs =
    not (null xs) ==> last (qsort xs) == maximum xs

prop_append :: Ord a => [a] -> [a] -> Property
prop_append xs ys =
    not (null xs) ==>
    not (null ys) ==>
    head (qsort (xs ++ ys)) == min (minimum xs) (minimum ys)

-- Usa a ordenacao da biblioteca padrao como modelo de referencia
prop_sort_model :: Ord a => [a] -> Bool
prop_sort_model xs = sort xs == qsort xs
