module Data.Journal
    exposing
        ( Journal
        , getEntry
        , updateEntry
        , addEntry
        , Entry
        , updateTitle
        , updateContent
        )

import Array exposing (Array)


type alias Journal =
    Array Entry


type alias Entry =
    { title : String
    , content : String
    }


getEntry : Int -> Journal -> Maybe Entry
getEntry idx journal =
    Array.get idx journal


updateEntry : Int -> Entry -> Journal -> Journal
updateEntry idx entry journal =
    Array.set idx entry journal


addEntry : Entry -> Journal -> Journal
addEntry entry journal =
    Array.push entry journal


updateTitle : String -> Entry -> Entry
updateTitle newTitle entry =
    { entry | title = newTitle }


updateContent : String -> Entry -> Entry
updateContent newContent entry =
    { entry | content = newContent }
