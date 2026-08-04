{-
---
fulltitle: "Optional exercise: DFS using the state monad"
---
-}

module Graph where

{-
In this module we'll look at the depth-first search algorithm on arbitrary graphs as
an example of using the State Monad. Often, when traversing a graph, you need to keep
track of what nodes in the graph that you have already seen so that you can avoid
cycles. This is a perfect opportunity to use `State`.

For these examples, we'll use finite sets and finite maps. The Haskell
`containers` library has efficient implementations of both of these as purely
functional data structures that we can import.
-}

{-
We'll also use the State monad from the `State.hs` module. Make sure that you have filled
in the `undefined` answers in this module before you work on this code.
-}

{-
We'll also import a few other modules for convenience.
-}

import Control.Monad qualified as Monad
import Data.Map (Map)
import Data.Map qualified as Map
import Data.Maybe qualified as Maybe
import Data.Monoid qualified as Monoid
import Data.Set (Set)
import Data.Set qualified as Set
import State (State, evalState, get, modify)

{-
Nodes in our graphs will be just identification numbers today, for simplicity.
(In a more general library they could store other sorts of information.)
-}

type Node = Int

{-
DFS trees
---------

As a warm-up, let's review depth-first searching a tree structure
for a particular node identifier. This data structure for trees below associates a node identifier with each `B`ranch and lets
that branch have *any* number of children.
-}

data Tree = B Node [Tree] deriving (Eq, Show)

{-
If the list is empty in a branch, then it represents a leaf node, with no children. Otherwise the list contains all of the subtrees of the given branch.

Here's an example tree:
-}

tree :: Tree
tree = B 1 [B 2 [B 6 [B 9 [], B 5 [B 10 []]]], B 3 []]

{-
Searching this tree for a particular node requires two mutually
recursive helper functions: one for trees and one for lists of
trees. Note that this `search` operation stops as soon as it finds
the goal node.
-}

-- >>> dfsTree tree 10
-- True

-- >>> dfsTree tree 4
-- False

dfsTree :: Tree -> Node -> Bool
dfsTree t goal = search t
  where
    search :: Tree -> Bool
    search (B v ws) = v == goal || searchList ws

    searchList :: [Tree] -> Bool
    searchList [] = False
    searchList (w : ws) = search w || searchList ws

{-
NOTE: we could replace `searchList` by `any search`, but we'll
keep it this way for comparison with the code below.

Depth-first search for trees makes elegant use of tree recursion. We don't need to keep track of where we are during the search because that
information is automatically stored on the call stack during the
recursive traversal of the tree. As we consider depth-first search of graphs below, we'll want to keep this behavior and use recursion to track
our progress through the graph traversal.

Representing graphs using adjacency lists
-----------------------------------------

Now let's switch to graphs.
We'll use an *adjacency list* representation.

A (directed) graph is then just a finite map that records all of the adjacent
nodes for each node in the graph.
-}

type Graph = Map Node [Node]

{-
For example, we can construct a graph with 12 nodes as follows. Each of these
nodes has 1, 2, or 3 neighbors.  If you look closely you can get from 1 to 10, but
you cannot get from 1 to 4.
-}

graph :: Graph
graph =
  Map.fromList
    [ (1, [2, 3]),
      (2, [6, 5, 1]),
      (3, [1]),
      (4, [7, 8]),
      (5, [9, 10, 2]),
      (6, [2, 9, 5]),
      (7, [4, 11, 12]),
      (8, [4]),
      (9, [6]),
      (10, [5]),
      (11, [7]),
      (12, [7])
    ]

{-
To find the list of adjacent nodes in a graph, we can use the `lookup` function
from the finite map library. If a node is not found in the map, we'll just
say that it has no adjacent nodes.
-}

-- >>> adjacent graph 5
-- [9,10,2]
adjacent :: Graph -> Node -> [Node]
adjacent g n = Maybe.fromMaybe [] (Map.lookup n g)

{-

Now, here is the pseudocode for depth-first search from [wikipedia (recursive version)](https://en.wikipedia.org/wiki/Depth-first_search).
This pseudocode traverses the graph, but doesn't compute anything interesting.

            procedure DFS(G, v) is
                label v as discovered
                for all directed edges from v to w that are in G.adjacentEdges(v) do
                    if vertex w is not labeled as discovered then
                        recursively call DFS(G, w)

We can modify this pseudocode so that it searches for a "goal" node and then returns whether
it has found that node. We also want it to stop as soon as the goal is found. Here it looks,
still in pseudocode.

            procedure DFS(G, v) is
                if v is the goal, return true
                label v as discovered
                for all directed edges from v to w that are in G.adjacentEdges(v) do
                    if vertex w is not labeled as discovered && we haven't yet found the goal
                        recursively call DFS(G, w)

Often at this point, descriptions of DFS algorithms introduce a stack data structure as part
of their implementation and rephrase the code using a loop instead of recursion. However,
this data structure is not necessary: the call stack in the recursive implementation plays
the same role. In the rest of this module, we'll use the `State` monad to implement
a recursive implementation of the pseudocode shown above.

Keeping track of discovered nodes
---------------------------------

The state that we need to keep track of is the set of nodes that we have discovered.
Let's define that type plus some associated operations.
-}

type Store = Set Node

-- | The initial store, a set that contains just the root node
initStore :: Node -> Store
initStore = Set.singleton

-- | Mark a node as discovered in the store
label :: Node -> Store -> Store
label = Set.insert

-- | Find out whether we have labeled a node
isLabeled :: Node -> Store -> Bool
isLabeled = Set.member

{-
Here is our first implementation DFS. The action is in the recursive
function `search` that begins the search from a vertex v,
along with its helper `searchList` that goes through all
vertices adjacent to v.
-}

-- >>> dfs graph 1 10
-- True

-- >>> dfs graph 1 4
-- False

-- | Depth-first search for a goal node in a graph
-- with store passing
dfs :: Graph -> Node -> Node -> Bool
dfs g root goal = fst (search root (initStore root))
  where
    search :: Node -> Store -> (Bool, Store)
    search v s =
      if v == goal
        then (True, s)
        else
          let s' = label v s
           in searchList (adjacent g v) s'

    searchList :: [Node] -> Store -> (Bool, Store)
    searchList [] s = (False, s)
    searchList (w : ws) s =
      if isLabeled w s
        then (False, s) -- already searched here
        else
          let (b, s') = search w s
           in if b
                then (True, s') -- found it in recursive call
                else searchList ws s' -- search other children

{-
At this point, make sure that you understand why we need to pass
the state through the computation. What happens if the recursive call
to `searchList` uses state `s` instead of `s'`?

Now, let's revise the above using the State monad. To make our
code simpler, we can define the following helper function. This
function lets us ask questions about the current store.
-}

-- | Find out a fact about the current state
query :: (Store -> Bool) -> State Store Bool
query f = f <$> get

{-
Use `do`-notation, `query` and `modify` to make state passing implicit.
-}

-- >>> dfsState graph 1 10

-- >>> dfsState graph 1 4

dfsState :: Graph -> Node -> Node -> Bool
dfsState g root goal = evalState (search root) (initStore root)
  where
    search :: Node -> State Store Bool
    search = undefined

    searchList :: [Node] -> State Store Bool
    searchList = undefined

{-
Now refactor the `dfs` implementation again, this time
using the short-circuiting boolean operations, defined below, that
work in any monad. These operators should replace uses of
`if-then-else` in your implementation above.

-}

(<||>) :: (Monad m) => m Bool -> m Bool -> m Bool
m1 <||> m2 = do
  b <- m1
  if b then return True else m2

(<&&>) :: (Monad m) => m Bool -> m Bool -> m Bool
m1 <&&> m2 = do
  b <- m1
  if b then m2 else return False

{-
(Aside, you might be tempted to define these operations using `liftA2`
from the `Applicative` class. However, that version is not short-circuiting.)
-}

-- >>> dfsState2 graph 1 10
-- True

-- >>> dfsState2 graph 1 4
-- False

dfsState2 :: Graph -> Node -> Node -> Bool
dfsState2 g root goal = evalState (search root) (initStore root)
  where
    search :: Node -> State Store Bool
    search = undefined
    searchList :: [Node] -> State Store Bool
    searchList = undefined

{-
Dfs applications: Spanning Tree
-------------------------------

For any depth-first search, we can return a trace of the search as a
spanningTree (also called a [Trémaux tree](https://en.wikipedia.org/wiki/Tr%C3%A9maux_tree)).
For example, if we start with node `1`, the trace that corresponds to a
full depth first search is the tree that we saw above.
-}

-- >>> spanningTree graph 1
-- B 1 [B 2 [B 6 [B 9 [],B 5 [B 10 []]]],B 3 []]

{-
Use the `State` monad to define the `spanningTree` function so that it
searches the reachable part of a graph from a specified node and
returns all found nodes in a tree.

Hint: I found it nice to define a monadic version of the (:)
data constructor to use in my solution.
-}

(<:>) :: (Monad f) => f a -> f [a] -> f [a]
(<:>) = Monad.liftM2 (:)

spanningTree :: Graph -> Node -> Tree
spanningTree = undefined

{-
Connected components
--------------------

Now let's use depth-first search to find the connected
components of the graph. In this operation, we'll want to
visit every single node in the graph and separate them into
groups that are connected (not strongly) with eachother.

The key insight for our implementation below is that we need to both
keep track of which nodes have been visited *and* quickly find one
that we have not yet done. What this means is that we'll use the same
type of store in our algorithm, but this time we'll start with all of the
nodes in the graph as the initial store and remove them as we go.
-}

-- | initialize the store with *all* nodes in the graph
initWorkList :: Graph -> Store
initWorkList = Map.keysSet

-- | mark a node as finished by *removing* it from the store
markDone :: Node -> Store -> Store
markDone = Set.delete

-- | a node has been processed if it is no longer in the store
isDone :: Node -> Store -> Bool
isDone n s = not (Set.member n s)

{-
Now, finish the implementation of the connected component algorithm.
-}

-- >>> connected graph
-- [B 1 [B 2 [B 6 [B 9 [],B 5 [B 10 []]]],B 3 []],B 4 [B 7 [B 11 [],B 12 []],B 8 []]]

connected :: Graph -> [Tree]
connected g = evalState loop (initWorkList g)
  where
    -- \| loop through all nodes in the graph until they have all
    -- been visited.
    loop :: State Store [Tree]
    loop = do
      p <- get
      case Set.elems p of
        [] -> return []
        (n : _) -> visit n <:> loop

    visit :: Node -> State Store Tree
    visit = undefined

    visitList :: [Node] -> State Store [Tree]
    visitList = undefined

{-
Now modify the above function so that it returns the two
subgraphs instead of the spanning trees of the connected
components.
-}

-- >>> connectedGraph graph
-- [fromList [(1,[2,3]),(2,[6,5,1]),(3,[1]),(5,[9,10,2]),(6,[2,9,5]),(9,[6]),(10,[5])],fromList [(4,[7,8]),(7,[4,11,12]),(8,[4]),(11,[7]),(12,[7])]]

connectedGraph :: Graph -> [Graph]
connectedGraph g = evalState loop (initWorkList g)
  where
    -- \| loop through all nodes in the graph until they have all
    -- been visited.
    loop :: State Store [Graph]
    loop = do
      p <- get
      case Set.elems p of
        [] -> return []
        (n : _) -> visit n <:> loop

    visit :: Node -> State Store Graph
    visit = undefined

    visitList :: [Node] -> State Store Graph
    visitList = undefined

{-
Graph queries
-------------

We can fold over trees, but can we fold over graphs?
-}

foldGraph :: forall m. (Monoid m) => (Node -> m) -> Graph -> [m]
foldGraph f g = evalState loop (initWorkList g)
  where
    -- \| loop through all nodes in the graph until they have all
    -- been visited.
    loop :: State Store [m]
    loop = do
      p <- get
      case Set.elems p of
        [] -> return mempty
        (n : _) -> visit n <:> loop

    visit :: Node -> State Store m
    visit = undefined

    visitList :: [Node] -> State Store m
    visitList = undefined

-- >>> connectedGraph' graph
-- [fromList [(1,[2,3]),(2,[6,5,1]),(3,[1]),(5,[9,10,2]),(6,[2,9,5]),(9,[6]),(10,[5])],fromList [(4,[7,8]),(7,[4,11,12]),(8,[4]),(11,[7]),(12,[7])]]
connectedGraph' :: Graph -> [Graph]
connectedGraph' g =
  foldGraph (\n -> Map.singleton n (adjacent g n)) g

-- is every node has an edge back to itself
reflexive :: Graph -> Bool
reflexive g = all Monoid.getAll $ foldGraph f g
  where
    f n = Monoid.All (n `elem` adjacent g n)

-- is symmetric?
symmetric :: Graph -> Bool
symmetric g = all Monoid.getAll $ foldGraph f g
  where
    f n = Monoid.All (all (\v -> n `elem` adjacent g v) (adjacent g n))

{-
For more in-depth functional approach to Graph algorithms, see the draft book
"Algorithms: Parallel and Sequential" by Umut A. Acar and Guy E. Blelloch
available at this url: https://sites.google.com/site/alphalambdabook/
-}
