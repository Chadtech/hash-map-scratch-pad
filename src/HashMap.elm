module HashMap exposing (HashMap)

import Array exposing (Array)
import Dict exposing (Dict)


title =
    """
   ▄█    █▄       ▄████████    ▄████████    ▄█    █▄         
  ███    ███     ███    ███   ███    ███   ███    ███        
  ███    ███     ███    ███   ███    █▀    ███    ███        
 ▄███▄▄▄▄███▄▄   ███    ███   ███         ▄███▄▄▄▄███▄▄      
▀▀███▀▀▀▀███▀  ▀███████████ ▀███████████ ▀▀███▀▀▀▀███▀       
  ███    ███     ███    ███          ███   ███    ███        
  ███    ███     ███    ███    ▄█    ███   ███    ███        
  ███    █▀      ███    █▀   ▄████████▀    ███    █▀         
                                                             
   ▄▄▄▄███▄▄▄▄      ▄████████    ▄███████▄    ▄████████      
 ▄██▀▀▀███▀▀▀██▄   ███    ███   ███    ███   ███    ███      
 ███   ███   ███   ███    ███   ███    ███   ███    █▀       
 ███   ███   ███   ███    ███   ███    ███   ███             
 ███   ███   ███ ▀███████████ ▀█████████▀  ▀███████████      
 ███   ███   ███   ███    ███   ███                 ███      
 ███   ███   ███   ███    ███   ███           ▄█    ███      
  ▀█   ███   █▀    ███    █▀   ▄████▀       ▄████████▀    

    """


users : Dict String User
users =
    Dict.empty


{-|

    usersHashMap : HashMap String User

-}
thesis =
    """
HashMaps are like arrays, where an element’s index
is determined by passing the key into a function.

We turn a key into an index by a “Hash function”,
a function that transforms any kind of data into a
number.
    """


type alias HashMap key value =
    Array (Slot key value)


{-|

    In an Array, if an index is out of bounds, the
    get function returns `Nothing`, representing nothing
    being at that index. Our HashMap differs slightly in
    that some of the indices are filled with `Empty`.

    A HashMap is also kind of like an array that can
    have holes in it.

-}
type Slot key value
    = Entry key value
    | Empty
    | Tombstone


{-|

    There are two important ingredients to our HashMap
    that I will state outright here, but will make more
    sense later

    We have our hash function, which takes any thing
    and returns a number unique to the input value

    hash : a -> Int

    And an arbitrary "level size" number, which for
    the purposes of this talk will be 4

    levelSize : Int
    levelSize =
        4

-}


{-|

    Lets make a HashMap that takes people's names as keys,
    and stores their favorite color as values.

    Lets start with an empty HashMap..

-}
s0 =
    []


type Color
    = OliveDrab
    | Yellow
    | Red


{-|

    Lets add `Yellow` under the key "Chad".

    Suppose "Chad" hashes to `2`, meaning we want to
    add "Chad" => Yellow to index 2 in the HashMap

    We have a problem! The hashmap is currently empty,
    and there is no index 2. We need to allocate
    some space for it's first entry. Lets add a "level"
    to the hashmap, which we arbitrarily picked
    1 level = 4 slots long..

-}
s1 =
    [ Empty
    , Empty
    , Empty
    , Empty
    ]


{-|

    Now there is enough space to insert

    "Chad" => Yellow

-}
s2 =
    [ Empty
    , Empty
    , Entry "Chad" Yellow
    , Empty
    ]


{-|

    Lets add `OliveDrab` under the key "Becky", suppose
    "Becky" hashes to `1` our HashMap becomes..

-}
s3 =
    [ Empty
    , Entry "Becky" OliveDrab
    , Entry "Chad" Yellow
    , Empty
    ]


{-|

    Lets add `Red` under the key "Walter", suppose "Walter"
    hashes to `2` our HashMap becomes..
    Uh oh! Index `2` is already taken. We need more space
    in our HashMap. So lets grow the HashMap from 1 level
    to 2 levels, which is another way of saying grow it
    from 4 slots to 8 slots..

-}
s4 =
    [ Empty
    , Entry "Becky" OliveDrab
    , Entry "Chad" Yellow
    , Empty
    , Empty
    , Empty
    , Empty
    , Empty
    ]


{-|

     ..and then add "Walter" to the next level in the
     HashMap (indices 4 through 7). Say in the next
     level "Walter" hashes to `0`, then we add "Walter"
     to index 4, because 4 = 1 * levelSize + 0.

-}
s5 =
    [ Empty
    , Entry "Becky" OliveDrab
    , Entry "Chad" Yellow
    , Empty
    , Entry "Walter" Red
    , Empty
    , Empty
    , Empty
    ]


{-|

     Now say we want to retrieve Walter's favorite color.
     We first hash "Walter", which gives us `2`, and then
     we get the entry at index 2..

-}
s6 =
    Entry "Chad" Yellow


{-|

     ..but the entry at `2` is stored under the key "Chad",
      which is not what we are looking for, so we have to
      move on and search for "Walter" in the next level of
      this HashMap..

      In the next level we rehash "Walter", which hashes to
      "0", and we get index 4, because 4 = 1 * levelSize + 0.
      This entry does have the key "Walter" so we know we
      found the correct entry.

-}
s7 =
    Entry "Walter" Red


{-|

     Lets delete Chad's favorite color from the HashMap

     We hash "Chad" to `2`, check the key at 2 to make sure
     its "Chad", and then we replace the whole entry with `Tombstone`.

-}
s8 =
    [ Empty
    , Entry "Becky" OliveDrab
    , Tombstone
    , Empty
    , Entry "Walter" Red
    , Empty
    , Empty
    , Empty
    ]


{-|

     Suppose we want to look up Katerina's favorite color,
     who is absent from our HashMap. We hash "Katerina" to
     `0`, and we look up that slot to find `Empty`, so we
     conclude Katerina's favorite color  is not stored
     in this HashMap.

     Reaching `Empty` leads us to stop our search.

     If "Katerina" hashed to `1` instead, we would check
     if it matches the key at that slot "Becky", see that
     it doesnt, and move onto check the next level in the
     same way we checked the first.

     If "Katerina" hashed to `2` instead, we would look up
     index 2 and find Tombstone. Since the value is
     Tombstone, there was once a value, there, and there
     may have been a collision with that value, and
     "Katerina" may be in a subsequent level

-}
s9 =
    [ Empty
    , Entry "Becky" OliveDrab
    , Tombstone
    , Empty
    , Entry "Walter" Red
    , Empty
    , Empty
    , Empty
    ]


levelSize : Int
levelSize =
    4


hash : a -> Int -> Int
hash value seed =
    --
    -- Nevermind how this is implemented..
    --
    --
    --
    --
    --
    --
    --
    --
    --
    --
    --
    --
    --
    --
    --
    --
    --
    --
    --
    --
    --
    --
    --
    --
    --
    --
    --
    --
    let
        x =
            value

        y =
            hash

        z =
            levelSize

        a =
            thesis
    in
    4


type User
    = User
