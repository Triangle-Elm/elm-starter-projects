port module Ports exposing (loadJournal, saveJournal, journalUpdates)

import Json.Decode exposing (Value, decodeValue)
import Json.Encode as Encode exposing (object)
import Journal exposing (Journal)


saveJournal : Journal -> Cmd msg
saveJournal journal =
    object
        [ ( "action", Encode.string "saveJournal" )
        , ( "data", Journal.encode journal )
        ]
        |> toJs


loadJournal : Cmd msg
loadJournal =
    object [ ( "action", Encode.string "loadJournal" ) ]
        |> toJs


journalUpdates : (Journal -> msg) -> (String -> msg) -> Sub msg
journalUpdates successMsg unknownMsg =
    fromJs (parseMessage successMsg unknownMsg)


port toJs : Value -> Cmd msg


port fromJs : (Value -> msg) -> Sub msg


type Msg
    = JournalUpdate Journal
    | UnknownMessage String


parseMessage : (Journal -> msg) -> (String -> msg) -> Value -> msg
parseMessage success unknown json =
    let
        parseResult =
            decodeValue Journal.decoder json
                |> Result.map success
    in
        case parseResult of
            Ok msg ->
                msg

            Err str ->
                unknown str
