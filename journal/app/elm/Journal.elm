module Journal
    exposing
        ( Journal
        , getEntry
        , updateEntry
        , addEntry
        , Entry
        , updateTitle
        , updateContent
        , encode
        , decoder
        , empty
        )

import Array exposing (Array)
import Json.Encode as Encode exposing (object)
import Json.Decode as Decode exposing (Decoder)


type alias Journal =
    Array Entry


empty : Journal
empty =
    Array.empty


getEntry : Int -> Journal -> Maybe Entry
getEntry idx journal =
    Array.get idx journal


updateEntry : Int -> Entry -> Journal -> Journal
updateEntry idx entry journal =
    Array.set idx entry journal


addEntry : Entry -> Journal -> Journal
addEntry entry journal =
    Array.push entry journal



-- Entries


type alias Entry =
    { title : String
    , content : String
    }


updateTitle : String -> Entry -> Entry
updateTitle newTitle entry =
    { entry | title = newTitle }


updateContent : String -> Entry -> Entry
updateContent newContent entry =
    { entry | content = newContent }



-- Encoding/Decoding


encode : Journal -> Encode.Value
encode journal =
    Array.toList journal
        |> List.map encodeEntry
        |> Encode.list


decoder : Decoder Journal
decoder =
    Decode.array decodeEntry


encodeEntry : Entry -> Encode.Value
encodeEntry entry =
    object
        [ ( "title", Encode.string entry.title )
        , ( "content", Encode.string entry.content )
        ]


decodeEntry : Decoder Entry
decodeEntry =
    Decode.map2 Entry
        (Decode.field "title" Decode.string)
        (Decode.field "content" Decode.string)
