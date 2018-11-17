module Markdown

open Fable.Helpers.React
open Fable.Core
open Fable.Core.JsInterop

// https://github.com/rexxars/react-markdown

type MarkdownProps =
    | Source of string
    | ClassName of string
    | EscapeHtml of bool
    | LinkTarget of string

let markdown (props:MarkdownProps list) = 
    ofImport "default" "react-markdown" (keyValueList CaseRules.LowerFirst props) []