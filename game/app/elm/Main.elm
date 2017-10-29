module Main exposing (main)

import Html exposing (Html, text, div, button)
import AnimationFrame
import Time exposing (Time)
import Collage exposing (Form, collage, square, filled, moveX)
import Element
import Color
import Char
import Keyboard exposing (KeyCode)


main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subs
        }



-- Model


type alias Model =
    { moveState : MoveState
    , position : ( Float, Float )
    }


type MoveState
    = Stationary
    | Moving Direction


type Direction
    = Left
    | Right


init : ( Model, Cmd Msg )
init =
    ( { moveState = Stationary
      , position = ( 0, 0 )
      }
    , Cmd.none
    )


currentDirection : Model -> Maybe Direction
currentDirection model =
    case model.moveState of
        Moving direction ->
            Just direction

        Stationary ->
            Nothing



-- Update


type Msg
    = MoveStart Direction
    | MoveEnd Direction
    | Frame Time
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MoveStart direction ->
            ( { model | moveState = Moving direction }, Cmd.none )

        MoveEnd direction ->
            if currentDirection model == Just direction then
                ( { model | moveState = Stationary }, Cmd.none )
            else
                ( model, Cmd.none )

        Frame dt ->
            ( model
                |> move dt
            , Cmd.none
            )

        NoOp ->
            ( model, Cmd.none )


move : Time -> Model -> Model
move dt obj =
    let
        baseSpeed =
            400

        speed =
            case obj.moveState of
                Moving Left ->
                    -1 * baseSpeed

                Moving Right ->
                    1 * baseSpeed

                Stationary ->
                    0
    in
        { obj
            | position =
                obj.position
                    |> Tuple.mapFirst
                        (\pos ->
                            pos + (speed * (Time.inSeconds dt))
                        )
        }



-- View


view : Model -> Html Msg
view model =
    Element.toHtml <|
        collage
            500
            500
            [ character model ]



-- Subscriptions


type alias Keys =
    { left : KeyCode
    , right : KeyCode
    }


keys : Keys
keys =
    { left = Char.toCode 'J'
    , right = Char.toCode 'L'
    }


subs : Model -> Sub Msg
subs model =
    Sub.batch
        [ AnimationFrame.diffs Frame
        , Keyboard.downs actionStarts
        , Keyboard.ups actionEnds
        ]


actionStarts : KeyCode -> Msg
actionStarts key =
    if (key == keys.left) then
        MoveStart Left
    else if (key == keys.right) then
        MoveStart Right
    else
        NoOp


actionEnds : KeyCode -> Msg
actionEnds key =
    if (key == keys.left) then
        MoveEnd Left
    else if (key == keys.right) then
        MoveEnd Right
    else
        NoOp


character : Model -> Form
character model =
    square 10
        |> filled Color.blue
        |> moveX (Tuple.first model.position)
