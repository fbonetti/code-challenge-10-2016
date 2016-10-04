module Firewall exposing (parseLines)

import String
import Dict exposing (Dict)
import IPAddress exposing (IPAddress, parseIPAddress)

type alias Config =
  { port' : Int
  , mappings : Dict String Port
  , redirects : Dict String String
  }

type alias Port = Int

defaultConfig : Config
defaultConfig =
  { port' = 1025
  , mappings = Dict.fromList []
  , redirects = Dict.fromList []
  }

parseLines : String -> String
parseLines lines =
  List.foldl
    (\line ( output, config ) ->
        let
          ( output', config' ) = parseLine config line
        in
          case output' of
            Just str ->
              ( output ++ "\n" ++ str, config' )
            Nothing ->
              ( output, config' )

    )
    ( "", defaultConfig )
    (String.lines lines)

  |> fst



parseLine : Config -> String -> ( Maybe String, Config )
parseLine ({ port', mappings, redirects } as config) line =
  case (splitLine line) of
    Just (sourceIp, sourcePort, destinationIp, destinationPort) ->
      let
        fullSource = (IPAddress.toString sourceIp) ++ ":" ++ (toString sourcePort)
        fullDestination = (IPAddress.toString destinationIp) ++ ":" ++ (toString destinationPort)
      in

        if isLocalIP sourceIp && destinationIp == routerPublicAddress then
          ( Nothing, config )

        else
          if isLocalIP sourceIp && isLocalIP destinationIp then
            ( Just (String.join " " [ fullSource, fullDestination, "local" ])
            , config
            )

          else
            if destinationIp == routerPublicAddress then
              let
                key = fullSource ++ "-" ++ "53.0.0.1" ++ ":" ++ (toString destinationPort)
              in
                case Dict.get key redirects of
                  Just redirect ->
                    ( Just (String.join " " ["Accept", fullSource, fullDestination, "redirect", redirect])
                    , config
                    )

                  Nothing ->
                    ( Just ("Reject " ++ fullSource ++ " " ++ fullDestination)
                    , config
                    )

            else
              if isLocalIP sourceIp && isExternalIP destinationIp then
                let
                  key = fullSource ++ "-" ++ fullDestination
                in
                  if Dict.member key mappings then
                    ( Nothing, config )

                  else
                    let
                      str = String.join " " ["Mapped", fullSource, "to", fullDestination, "assigned", (toString port')]
                      redirectKey = fullDestination ++ "-53.0.0.1" ++ ":" ++ (toString port')
                      config' =
                        { port' = port' + 1
                        , mappings = Dict.insert key port' mappings
                        , redirects = Dict.insert redirectKey fullSource redirects
                        }
                    in
                      ( Just str
                      , config'
                      )

              else
                ( Nothing, config )

    Nothing ->
      ( Nothing, config )


splitLine : String -> Maybe ( IPAddress, Port, IPAddress, Port )
splitLine str =
  case (String.split " " str) of
    sourceIp :: sourcePort :: destinationIp :: destinationPort :: [] ->
      let
        sourceIp' = parseIPAddress sourceIp
        sourcePort' = (String.toInt >> Result.toMaybe) sourcePort
        destinationIp' = parseIPAddress destinationIp
        destinationPort' = (String.toInt >> Result.toMaybe) destinationPort
      in
        Maybe.map4
          (,,,)
          sourceIp'
          sourcePort'
          destinationIp'
          destinationPort'

    _ ->
      Nothing



isValidPort : Port -> Bool
isValidPort port' =
  port' >= 0 && port' <= 65535

isLocalIP : IPAddress -> Bool
isLocalIP ip =
  -- 167772160 == "10.0.0.0"
  -- 184549375 == "10.255.255.255"
  ip >= 167772160 && ip <= 184549375

isExternalIP : IPAddress -> Bool
isExternalIP =
  not << isLocalIP

routerPublicAddress : IPAddress
routerPublicAddress =
  -- "53.0.0.1"
  889192449
