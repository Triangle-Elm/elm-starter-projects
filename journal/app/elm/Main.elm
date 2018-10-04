module Main exposing (main)

import Array exposing (Array)
import Browser exposing (Document)
import Html
    exposing
        ( Html
        , a
        , button
        , div
        , h1
        , input
        , li
        , nav
        , text
        , textarea
        , ul
        )
import Html.Attributes exposing (class, href, value)
import Html.Events exposing (onClick, onInput)
import Journal exposing (Entry, Journal, updateContent, updateTitle)
import Markdown
import Ports


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- Model


type alias Model =
    { journal : Journal
    , viewState : ViewState
    }


type ViewState
    = Listing
    | Viewing Int
    | Editing Int Entry
    | Creating Entry
    | NotFound


init : () -> ( Model, Cmd Msg )
init _ =
    ( { journal = Journal.empty
      , viewState = Listing
      }
    , Ports.loadJournal
    )



-- Update


type Msg
    = ShowEntry Int
    | EditEntry Int
    | ListEntries
    | NewEntry
    | UpdateEntryTitle String
    | UpdateEntryContent String
    | SaveEntry
    | JournalUpdated Journal
    | UnknownData String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ShowEntry pos ->
            ( { model | viewState = Viewing pos }, Cmd.none )

        ListEntries ->
            ( { model | viewState = Listing }, Cmd.none )

        EditEntry pos ->
            case Journal.getEntry pos model.journal of
                Just entry ->
                    ( { model | viewState = Editing pos entry }, Cmd.none )

                Nothing ->
                    ( { model | viewState = NotFound }, Cmd.none )

        NewEntry ->
            ( { model | viewState = Creating (Entry "" "") }, Cmd.none )

        SaveEntry ->
            case model.viewState of
                Editing pos entry ->
                    saveJournal model (Journal.updateEntry pos entry model.journal)

                Creating entry ->
                    saveJournal model (Journal.addEntry entry model.journal)

                _ ->
                    ( model, Cmd.none )

        UpdateEntryTitle newTitle ->
            let
                newViewState =
                    updateEditingState model.viewState (Journal.updateTitle newTitle)
            in
            ( { model | viewState = newViewState }, Cmd.none )

        UpdateEntryContent newContent ->
            let
                newViewState =
                    updateEditingState model.viewState (Journal.updateContent newContent)
            in
            ( { model | viewState = newViewState }, Cmd.none )

        JournalUpdated journal ->
            let
                newView =
                    case model.viewState of
                        Editing pos _ ->
                            Viewing pos

                        Creating _ ->
                            Listing

                        _ ->
                            model.viewState
            in
            ( { model
                | journal = journal
                , viewState = newView
              }
            , Cmd.none
            )

        -- unrecognized message from js
        UnknownData description ->
            ( model, Cmd.none )


saveJournal : Model -> Journal -> ( Model, Cmd Msg )
saveJournal model newJournal =
    ( model, Ports.saveJournal newJournal )


updateEditingState : ViewState -> (Entry -> Entry) -> ViewState
updateEditingState viewState updateFn =
    case viewState of
        Editing pos entry ->
            Editing pos (updateFn entry)

        Creating entry ->
            Creating (updateFn entry)

        _ ->
            viewState



-- View


view model =
    Document "Journal App" [ body model ]


body : Model -> Html Msg
body model =
    case model.viewState of
        Listing ->
            listView model.journal

        Viewing pos ->
            entryViewer pos model.journal

        Creating entry ->
            entryEditor SaveEntry ListEntries entry

        Editing pos entry ->
            entryEditor SaveEntry (ShowEntry pos) entry

        NotFound ->
            notFoundView


listView : Journal -> Html Msg
listView journal =
    let
        entrySummary idx entry =
            li [ class "entry-summary" ]
                [ a [ class "title", onClick (ShowEntry idx), href "#" ] [ text entry.title ]
                ]
    in
    div []
        [ button [ class "button-primary", onClick NewEntry ] [ text "New" ]
        , ul [ class "journal" ]
            (Array.indexedMap entrySummary journal
                |> Array.toList
            )
        ]


entryEditor : Msg -> Msg -> Entry -> Html Msg
entryEditor onSave onCancel entry =
    div []
        [ div [ class "editor" ]
            [ div [ class "inputs" ]
                [ div [ class "title" ]
                    [ input [ onInput UpdateEntryTitle, value entry.title ] []
                    ]
                , div [ class "content" ]
                    [ textarea [ onInput UpdateEntryContent, value entry.content ] []
                    ]
                , nav []
                    [ navLink onCancel "Cancel"
                    , button [ class "button-primary", onClick onSave ] [ text "Save" ]
                    ]
                ]
            , div [ class "preview" ]
                [ entryDisplay entry
                ]
            ]
        ]


entryViewer : Int -> Journal -> Html Msg
entryViewer pos journal =
    case Journal.getEntry pos journal of
        Just entry ->
            div []
                [ nav []
                    [ navLink ListEntries "< Back"
                    , navLink (EditEntry pos) "Edit"
                    ]
                , entryDisplay entry
                ]

        Nothing ->
            notFoundView


entryDisplay : Entry -> Html Msg
entryDisplay entry =
    div [ class "entry" ]
        [ h1 [ class "title" ] [ text entry.title ]
        , div [ class "content" ]
            [ Markdown.toHtml [] entry.content ]
        ]


notFoundView : Html Msg
notFoundView =
    div []
        [ h1 [] [ text "Not found" ]
        , navLink ListEntries "Back to journal"
        ]


navLink : Msg -> String -> Html Msg
navLink msg content =
    a [ onClick msg, href "#" ] [ text content ]



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Ports.journalUpdates JournalUpdated UnknownData
