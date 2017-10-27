module Main exposing (main)

import Html
    exposing
        ( Html
        , text
        , div
        , nav
        , input
        , textarea
        , h1
        , a
        , ul
        , li
        , button
        )
import Html.Attributes exposing (class, value, href)
import Html.Events exposing (onInput, onClick)
import Markdown
import Journal exposing (Journal, Entry, updateTitle, updateContent)
import Array exposing (Array)
import Ports


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- Model


type alias Model =
    { entries : Journal
    , viewState : ViewState
    }


type ViewState
    = Listing
    | Viewing Int
    | Editing Int Entry
    | Creating Entry
    | NotFound


init : ( Model, Cmd Msg )
init =
    ( { entries = Journal.empty
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
            case Journal.getEntry pos model.entries of
                Just entry ->
                    ( { model | viewState = Editing pos entry }, Cmd.none )

                Nothing ->
                    ( { model | viewState = NotFound }, Cmd.none )

        NewEntry ->
            ( { model | viewState = Creating (Entry "" "") }, Cmd.none )

        SaveEntry ->
            case model.viewState of
                Editing pos entry ->
                    let
                        newJournal =
                            Journal.updateEntry pos entry model.entries
                    in
                        ( { model | viewState = Viewing pos }
                        , Ports.saveJournal newJournal
                        )

                Creating entry ->
                    let
                        newJournal =
                            Journal.addEntry entry model.entries
                    in
                        ( { model | viewState = Listing }
                        , Ports.saveJournal newJournal
                        )

                _ ->
                    ( model, Cmd.none )

        UpdateEntryTitle newTitle ->
            case model.viewState of
                Editing pos entry ->
                    ( { model | viewState = Editing pos (Journal.updateTitle newTitle entry) }
                    , Cmd.none
                    )

                Creating entry ->
                    ( { model | viewState = Creating (Journal.updateTitle newTitle entry) }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        UpdateEntryContent newContent ->
            case model.viewState of
                Editing pos entry ->
                    ( { model | viewState = Editing pos (Journal.updateContent newContent entry) }
                    , Cmd.none
                    )

                Creating entry ->
                    ( { model | viewState = Creating (Journal.updateContent newContent entry) }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        JournalUpdated journal ->
            ( { model | entries = journal }, Cmd.none )

        UnknownData description ->
            ( model, Cmd.none )



-- View


view : Model -> Html Msg
view model =
    case model.viewState of
        Listing ->
            listView model.entries

        Viewing pos ->
            entryViewer pos model.entries

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
                    [ input [ onInput (UpdateEntryTitle), value entry.title ] []
                    ]
                , div [ class "content" ]
                    [ textarea [ onInput (UpdateEntryContent), value entry.content ] []
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
