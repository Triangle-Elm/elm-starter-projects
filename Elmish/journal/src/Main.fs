
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


let loadJournalSync() =
    match LocalStorage.loadJournalSync Journal.decode with 
    | Ok j -> JournalUpdated j
    | Error e -> UnknownData e

let init() = 
  { journal = Journal.empty
    viewState = Listing }, 
    Cmd.ofMsg (loadJournalSync())

// UPDATE

let update (msg:Msg) (model:Model) =
    match msg with
    | ShowEntry i ->
      { model with viewState = Viewing i }, Cmd.Empty

    | ListEntries ->
      { model with viewState = Listing }, Cmd.Empty

    | EditEntry i ->
      match Journal.getEntry i model.journal with
      | Some entry -> { model with viewState = Editing (i, entry) }, Cmd.Empty
      | None -> model, Cmd.Empty

    | NewEntry ->
      { model with viewState = Creating Entry.empty }, Cmd.Empty

    | SaveEntry -> failwith "Not Implemented"
    | UpdateEntryTitle(_) -> failwith "Not Implemented"
    | UpdateEntryContent(_) -> failwith "Not Implemented"
    | JournalUpdated j -> { model with journal = j }, Cmd.Empty
    | UnknownData msg -> 
      printfn "%s" msg
      model, Cmd.Empty

// VIEW (rendered with React)

let view (model:Model) dispatch =

  div []
      [ button [ OnClick (fun _ -> dispatch Increment) ] [ str "+" ]
        div [] [ str (string model) ]
        button [ OnClick (fun _ -> dispatch Decrement) ] [ str "-" ] ]

// App
Program.mkProgram init update view
|> Program.withReact "elmish-app"
|> Program.withConsoleTrace
|> Program.run

