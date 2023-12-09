module Frontend exposing (..)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Dict
import Html exposing (..)
import Html.Attributes as Attr exposing (class, href, rel, style, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Lamdera exposing (sendToBackend)
import Types exposing (..)
import Url


type alias Model =
    FrontendModel


app =
    Lamdera.frontend
        { init = init
        , onUrlRequest = UrlClicked
        , onUrlChange = UrlChanged
        , update = update
        , updateFromBackend = updateFromBackend
        , subscriptions = \m -> Sub.none
        , view = view
        }


init : Url.Url -> Nav.Key -> ( Model, Cmd FrontendMsg )
init url key =
    ( { fellas = Dict.empty
      , mySessionId = Nothing
      , newName = ""
      }
    , Cmd.none
    )


update : FrontendMsg -> Model -> ( Model, Cmd FrontendMsg )
update msg model =
    case msg of
        UrlClicked urlRequest ->
            ( model, Cmd.none )

        UrlChanged url ->
            ( model, Cmd.none )

        NoOpFrontendMsg ->
            ( model, Cmd.none )

        GivePointToFella fella ->
            ( { model
                | fellas =
                    Dict.update
                        fella.sessionId
                        (Maybe.map (\f -> { f | points = f.points + 1 }))
                        model.fellas
              }
            , sendToBackend (IncrementPointsForFella fella)
            )

        UpdateMyName string ->
            case model.mySessionId of
                Nothing ->
                    ( model, Cmd.none )

                Just sessionId ->
                    ( { model
                        | fellas =
                            Dict.update
                                (Dict.get sessionId model.fellas |> Maybe.map .name |> Maybe.withDefault "")
                                (Maybe.map (\f -> { f | name = string }))
                                model.fellas
                      }
                    , sendToBackend (ChangeMyNameTo string)
                    )

        ChangeMyName string ->
            ( { model | newName = string }, Cmd.none )


updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
updateFromBackend msg model =
    case msg of
        NoOpToFrontend ->
            ( model, Cmd.none )

        UpdateFellas dict ->
            ( { model | fellas = dict }
            , Cmd.none
            )

        YourSessionId sessionId ->
            ( { model | mySessionId = Just sessionId }
            , Cmd.none
            )


fellaToHtml : FrontendModel -> Fella -> Html FrontendMsg
fellaToHtml model him =
    let
        isYou =
            model.mySessionId == Just him.sessionId

        buttonOrNah =
            if isYou then
                Html.text ""

            else
                Html.button [ class "btn btn-primary", onClick (GivePointToFella him) ] [ Html.text "Give Puntos" ]
    in
    Html.div [ class "border-2 border-white flex gap-8 items-center p-4" ]
        [ Html.text
            (him.name
                ++ (if isYou then
                        " (YOU)"

                    else
                        ""
                   )
            )
        , Html.div [ class "" ] [ Html.text (String.fromInt him.points) ]
        , buttonOrNah
        ]


changeMyName : FrontendModel -> Html FrontendMsg
changeMyName model =
    Html.form [ onSubmit (UpdateMyName model.newName) ]
        [ Html.input [ type_ "text", class "input input-primary", value model.newName, onInput ChangeMyName ] []
        , Html.button [ class "btn btn-primary" ] [ Html.text "Change My Name" ]
        ]


yourPoints : FrontendModel -> Html FrontendMsg
yourPoints model =
    let
        yaPoints =
            case model.mySessionId of
                Nothing ->
                    0

                Just sessionId ->
                    Dict.get sessionId model.fellas |> Maybe.map .points |> Maybe.withDefault 0
    in
    Html.div [ class "text-5xl my-8" ] [ Html.text ("YOU HAVE " ++ String.fromInt yaPoints ++ " POINTS") ]


view : Model -> Browser.Document FrontendMsg
view model =
    { title = ""
    , body =
        [ Html.node "link" [ rel "stylesheet", href "/output.css" ] []
        , Html.div [ class "text-white" ]
            ([ changeMyName model, yourPoints model ]
                ++ (model.fellas
                        |> Dict.values
                        |> List.sortBy .points
                        |> List.reverse
                        |> List.map (fellaToHtml model)
                   )
            )
        ]
    }
