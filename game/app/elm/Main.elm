module Main exposing (main)

import Html exposing (Html, text, div, button)
import AnimationFrame
import Time exposing (Time)
import Collage exposing (Form, collage, square, filled, move, rect)
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
    { level : Level
    , character : Character
    }


type alias Level =
    { xSize : Int
    , ySize : Int
    }


type alias Character =
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
    ( { level =
            { xSize = 800
            , ySize = 500
            }
      , character =
            { moveState = Stationary
            , position = ( 0, -240 )
            }
      }
    , Cmd.none
    )


currentDirection : Character -> Maybe Direction
currentDirection character =
    case character.moveState of
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
    ( { model
        | character =
            updateCharacter msg model.level model.character
      }
    , Cmd.none
    )


updateCharacter : Msg -> Level -> Character -> Character
updateCharacter msg level character =
    case msg of
        MoveStart direction ->
            { character | moveState = Moving direction }

        MoveEnd direction ->
            if currentDirection character == Just direction then
                { character | moveState = Stationary }
            else
                character

        Frame dt ->
            movement dt level character

        NoOp ->
            character


movement : Time -> Level -> Character -> Character
movement dt level obj =
    let
        halfLevel =
            (toFloat level.xSize) / 2

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
                            (pos + (speed * (Time.inSeconds dt)))
                                |> max -halfLevel
                                |> min halfLevel
                        )
        }



-- View


view : Model -> Html Msg
view model =
    Element.toHtml <|
        collage
            model.level.xSize
            model.level.ySize
            [ background model.level
            , character model.character
            ]


background : Level -> Form
background level =
    rect (toFloat level.xSize) (toFloat level.ySize)
        |> filled Color.blue


character : Character -> Form
character character =
    square 10
        |> filled Color.yellow
        |> move character.position



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
