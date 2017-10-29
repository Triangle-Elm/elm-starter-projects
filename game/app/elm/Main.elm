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
    , velocity : ( Float, Float )
    , baseSpeed : Float
    , jumpVel : Float
    , gravity : Float
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
            , velocity = ( 0, 0 )
            , baseSpeed = 400
            , jumpVel = 400
            , gravity = 1000
            }
      }
    , Cmd.none
    )


currentDirection : Character -> Maybe Direction
currentDirection character =
    let
        xVel =
            Tuple.first character.velocity
    in
        if xVel > 0 then
            Just Right
        else if xVel < 0 then
            Just Left
        else
            Nothing



-- Update


type Msg
    = MoveStart Direction
    | MoveEnd Direction
    | Jump
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
            let
                xVel =
                    case direction of
                        Left ->
                            -character.baseSpeed

                        Right ->
                            character.baseSpeed
            in
                { character | velocity = ( xVel, Tuple.second character.velocity ) }

        MoveEnd direction ->
            if currentDirection character == Just direction then
                { character | velocity = ( 0, Tuple.second character.velocity ) }
            else
                character

        Jump ->
            if (Tuple.second character.velocity) == 0 then
                { character | velocity = ( Tuple.first character.velocity, character.jumpVel ) }
            else
                character

        Frame dt ->
            movement dt level character

        NoOp ->
            character


movement : Time -> Level -> Character -> Character
movement dtMillis level obj =
    let
        halfLevel =
            (toFloat level.xSize) / 2

        levelFloor =
            10 - (toFloat level.ySize) / 2

        dt =
            Time.inSeconds dtMillis

        dx =
            Tuple.first obj.velocity

        dy =
            Tuple.second obj.velocity
    in
        { obj
            | position =
                obj.position
                    |> Tuple.mapFirst ((+) (dx * dt))
                    |> Tuple.mapFirst (min halfLevel)
                    |> Tuple.mapFirst (max -halfLevel)
                    |> Tuple.mapSecond ((+) (dy * dt))
                    |> Tuple.mapSecond (max levelFloor)
            , velocity =
                obj.velocity
                    |> Tuple.mapSecond
                        (\vel ->
                            if vel <= 0 && (Tuple.second obj.position) == levelFloor then
                                0
                            else
                                vel - obj.gravity * dt
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


type alias Controls =
    { left : KeyCode
    , right : KeyCode
    , jump : KeyCode
    }


controls : Controls
controls =
    { left = Char.toCode 'J'
    , right = Char.toCode 'L'
    , jump = Char.toCode ' '
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
    if (key == controls.left) then
        MoveStart Left
    else if (key == controls.right) then
        MoveStart Right
    else if (key == controls.jump) then
        Jump
    else
        NoOp


actionEnds : KeyCode -> Msg
actionEnds key =
    if (key == controls.left) then
        MoveEnd Left
    else if (key == controls.right) then
        MoveEnd Right
    else
        NoOp
