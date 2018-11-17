module Journal

// Entries

type Entry = {
    title : string
    content : string
}

module Entry =
    let empty = { title = ""; content = "" }

let updateTitle newTitle entry = { entry with title = newTitle }
let updateContent newContent entry = { entry with content = newContent }


// Journal


type Journal = Entry[]

let empty : Journal = Array.empty<Entry>
let getEntry idx (journal:Journal) = Array.tryItem idx journal
let updateEntry idx entry (journal:Journal) = 
    Array.set journal idx entry
    journal
let addEntry entry (journal:Journal) = 
    Array.append [| entry |] journal

// Encoding/Decoding
open Thoth.Json

// let encode (journal:Journal) : Encode.Encoder<Journal> =
//     Encode.Auto.toString(2,journal)

let encodeEntry e =
    Encode.object [
        "title", Encode.string e.title
        "content", Encode.string e.content
    ]

let encode (j:Journal)  =
    Array.map encodeEntry j |> Encode.array

let decodeEntry : Decode.Decoder<Entry> =
    Decode.object (fun get -> {
            title = get.Required.Field "title" Decode.string
            content = get.Required.Field "content" Decode.string
        });
let decode : Decode.Decoder<Journal> =
    Decode.array decodeEntry