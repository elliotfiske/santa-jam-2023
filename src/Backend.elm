module Backend exposing (..)

import Dict
import Html
import Lamdera exposing (ClientId, SessionId, broadcast, sendToFrontend)
import Types exposing (..)


type alias Model =
    BackendModel


subscriptions model =
    Sub.batch
        [ Lamdera.onConnect ClientConnected
        ]


app =
    Lamdera.backend
        { init = init
        , update = update
        , updateFromFrontend = updateFromFrontend
        , subscriptions = subscriptions
        }


init : ( Model, Cmd BackendMsg )
init =
    ( { fellas = Dict.empty }
    , Cmd.none
    )


update : BackendMsg -> Model -> ( Model, Cmd BackendMsg )
update msg model =
    case msg of
        NoOpBackendMsg ->
            ( model, Cmd.none )

        ClientConnected sessionId clientId ->
            let
                newFella =
                    Maybe.withDefault
                        { sessionId = sessionId
                        , points = 0
                        , name = "Coolguy " ++ (model.fellas |> Dict.size |> String.fromInt)
                        }
                        (Dict.get sessionId model.fellas)
            in
            ( { model | fellas = Dict.insert sessionId newFella model.fellas }
            , Cmd.batch [ broadcast (UpdateFellas model.fellas), sendToFrontend clientId (YourSessionId sessionId) ]
            )


updateFromFrontend : SessionId -> ClientId -> ToBackend -> Model -> ( Model, Cmd BackendMsg )
updateFromFrontend sessionId clientId msg model =
    case msg of
        NoOpToBackend ->
            ( model, Cmd.none )

        IncrementPointsForFella fella ->
            let
                updatedFella =
                    { fella | points = fella.points + 1 }

                newModel =
                    { model | fellas = Dict.insert fella.sessionId updatedFella model.fellas }
            in
            ( newModel, broadcast (UpdateFellas newModel.fellas) )

        ChangeMyNameTo string ->
            let
                existingFella =
                    Dict.get sessionId model.fellas
            in
            case existingFella of
                Nothing ->
                    ( model, Cmd.none )

                Just fella ->
                    let
                        updatedFella =
                            { fella | name = string }

                        newModel =
                            { model | fellas = Dict.insert sessionId updatedFella model.fellas }
                    in
                    ( newModel, broadcast (UpdateFellas newModel.fellas) )
