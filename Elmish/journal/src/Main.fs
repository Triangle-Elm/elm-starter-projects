
module App

(**
 The famous Increment/Decrement ported from Elm.
 You can find more info about Emish architecture and samples at https://elmish.github.io/
*)

open Elmish
open Elmish.React
open Fable.Helpers.React
open Fable.Helpers.React.Props

open Journal

// MODEL

type ViewState =
  | Listing
  | Viewing of int
  | Editing of int*Entry
  | Creating of Entry
  | NotFound

type Model = { 
  journal : Journal
  viewState : ViewState
}

type Msg =
| ShowEntry of int
| EditEntry of int
| ListEntries
| NewEntry
| SaveEntry
| UpdateEntryTitle of string
| UpdateEntryContent of string
| JournalUpdated of Journal
| UnknownData of string

let init() : Model*Cmd<Msg> = 
  { journal = Journal.empty
    viewState = Listing }, 
    Cmd.ofSub (LocalStorage.journalSub Journal.decode JournalUpdated)

// UPDATE

let updateEditingState viewState updateFn =
  match viewState with
  | Editing (pos,entry) ->
    Editing (pos,updateFn entry)
  | Creating entry ->
    Creating (updateFn entry)
  | _ -> viewState

let update (msg:Msg) (model:Model) : Model*Cmd<Msg> =
    match msg with
    | ShowEntry i ->
      { model with viewState = Viewing i }, Cmd.none

    | ListEntries ->
      { model with viewState = Listing }, Cmd.none

    | EditEntry i ->
      match Journal.getEntry i model.journal with
      | Some entry -> { model with viewState = Editing (i, entry) }, Cmd.none
      | None -> model, Cmd.none

    | NewEntry ->
      { model with viewState = Creating Entry.empty }, Cmd.none

    | SaveEntry -> 
      match model.viewState with
      | Editing (pos,entry) ->
        let cmd = LocalStorage.saveJournal (Journal.updateEntry pos entry model.journal) JournalUpdated
        model, [cmd]
      | Creating entry ->
        model, [LocalStorage.saveJournal (Journal.addEntry entry model.journal) JournalUpdated]
      | _ -> model, Cmd.none

    | UpdateEntryTitle newTitle ->
      let newViewState = updateEditingState model.viewState (Journal.updateTitle newTitle)
      { model with viewState = newViewState }, Cmd.none

    | UpdateEntryContent content -> 
      let newViewState = updateEditingState model.viewState (Journal.updateContent content)
      { model with viewState = newViewState }, Cmd.none

    | JournalUpdated j -> 
      let newView =
        match model.viewState with
        | Editing (pos,_) -> Viewing pos
        | Creating _ -> Listing
        | _ -> model.viewState
      { model with journal = j; viewState = newView }, Cmd.none

    | UnknownData msg -> 
      // Unused
      model, Cmd.none


// VIEW (rendered with React)

let placeHolder = div [] [ str "Placeholder"]

let listingView dispatch journal = 
  let entrySummary idx (entry:Entry) =
    li [ ClassName "entry-summary"] [
      a [ ClassName "title"; OnClick (fun _ -> ShowEntry idx |> dispatch); Href "#" ] [
        str entry.title
      ]
    ]
  div [] [
    button [ClassName "button-primary"; OnClick (fun _ -> dispatch NewEntry) ] [ str "New" ]
    ul [ ClassName "journal" ] ( 
      Array.mapi entrySummary journal |> Array.toList
    )
  ]

let navLink click content =
  a [OnClick click] [str content]

let entryDisplay entry =
  Markdown.preview entry

let notFoundView = placeHolder

let entryViewer dispatch pos journal =
  match Journal.getEntry pos journal with
  | None -> notFoundView
  | Some entry ->
    div[] [
      nav [] [
        navLink (fun _ -> ListEntries |> dispatch) "< Back"
        navLink (fun _ -> EditEntry pos |> dispatch) "Edit"
      ]
      entryDisplay entry
    ]

let entryEditor dispatch onSave onCancel entry = 
  div [] [
    div [ClassName "editor"] [
      div [ClassName "inputs"] [
        div [ClassName "title"] [
          input [OnInput (fun arg -> UpdateEntryTitle arg.Value |> dispatch)]
        ]
        div [ClassName "content"] [
          textarea [OnInput (fun arg -> UpdateEntryContent arg.Value |> dispatch)] []
        ]
        nav [] [
          navLink (fun _ -> dispatch onCancel) "Cancel"
          button [ClassName "button-primary"; OnClick (fun _ -> dispatch onSave)] [
            str "Save"]
        ]
      ]
      div [ ClassName "preview" ] [
        entryDisplay entry
      ]
    ]
  ]


let view (model:Model) dispatch =
  match model.viewState with
  | Listing -> listingView dispatch model.journal
  | Viewing pos -> entryViewer dispatch pos model.journal
  | Creating entry -> entryEditor dispatch SaveEntry ListEntries entry
  | Editing (pos,entry) -> entryEditor dispatch SaveEntry (ShowEntry pos) entry
  | NotFound -> notFoundView

// App
Program.mkProgram init update view
|> Program.withReact "elmish-app"
|> Program.withConsoleTrace
|> Program.run

