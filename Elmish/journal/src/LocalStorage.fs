module LocalStorage

open Thoth.Json
open Fable.PowerPack

let journalKey = "journal"

let loadJournalSync decoder =
    BrowserLocalStorage.load decoder journalKey

let saveJournal journal =
    BrowserLocalStorage.save journalKey journal

