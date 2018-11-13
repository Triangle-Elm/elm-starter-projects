module LocalStorage

open Thoth.Json
open Fable.PowerPack

let journalKey = "journal"

let loadJournalSync decoder =
    BrowserLocalStorage.load decoder journalKey

let saveJournal journal msg dispatch : unit =
    BrowserLocalStorage.save journalKey journal
    msg journal |> dispatch

let private onJournal decoder dispatch (e:Fable.Import.Browser.StorageEvent) =
    if e.key = Some journalKey then
        match e.newValue with
        | None -> ()
        | Some value ->
            match Decode.fromString decoder value with
            | Ok journal -> dispatch journal
            | Error(s) -> printfn "%s" s

let journalSub decoder msg dispatch =
    match loadJournalSync decoder with
    | Ok (journal) -> msg journal |> dispatch
    | Error (msg) -> printfn "%s" msg
    Fable.Import.Browser.window.addEventListener_storage (onJournal decoder (msg>>dispatch))