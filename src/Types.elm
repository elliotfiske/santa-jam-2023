module Types exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Dict exposing (Dict)
import Lamdera exposing (SessionId)
import Url exposing (Url)


type alias FrontendModel =
    { key : Key
    , message : String
    , fellas : Dict SessionId Fella
    }


type alias BackendModel =
    {
        fellas: Dict SessionId Fella
    }

type alias Fella =
    { sessionId: SessionId
    , name: String
    , points: Int
     }


type FrontendMsg
    = UrlClicked UrlRequest
    | UrlChanged Url
    | NoOpFrontendMsg


type ToBackend
    = NoOpToBackend
    | IncrementPointsForFella Fella


type BackendMsg
    = NoOpBackendMsg


type ToFrontend
    = NoOpToFrontend
    | UpdateFellas (Dict SessionId Fella)