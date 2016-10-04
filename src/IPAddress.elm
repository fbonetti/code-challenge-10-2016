module IPAddress exposing (IPAddress, parseIPAddress, toString)

import Result
import Combine exposing (..)
import Combine.Num exposing (int)
import Combine.Char exposing (char)
import Bitwise exposing (shiftRight, and)
import String

type alias IPAddress = Int

toString : IPAddress -> String
toString ip =
  let
    a = (ip `shiftRight` 24) `and` 0xFF
    b = (ip `shiftRight` 16) `and` 0xFF
    c = (ip `shiftRight` 8) `and` 0xFF
    d = ip `and` 0xFF
  in
    (List.map Basics.toString >> String.join ".") [a,b,c,d]

parseIPAddress : String -> Maybe IPAddress
parseIPAddress =
  parse ipAddressParser >> fst >> Result.toMaybe

ipAddressParser : Parser IPAddress
ipAddressParser =
  byteParser `andThen` \a ->
    (skip (char '.')) `andThen` \_ ->
      byteParser `andThen` \b ->
        (skip (char '.')) `andThen` \_ ->
          byteParser `andThen` \c ->
            (skip (char '.')) `andThen` \_ ->
              byteParser `andThen` \d ->
                succeed ((a * (2 ^ 24)) + (b * (2 ^ 16)) + (c * (2 ^ 8)) + d)

byteParser : Parser Int
byteParser =
  int `andThen` \x ->
    if x >= 0 && x <= 255 then
      succeed x
    else
      fail []
