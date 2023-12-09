module Types exposing (..)

import Browser exposing (UrlRequest)
import Dict exposing (Dict)
import Lamdera exposing (ClientId, SessionId)
import Url exposing (Url)


type alias FrontendModel =
    { fellas : Dict SessionId Fella
    , mySessionId : Maybe SessionId
    , newName : String
    }


type alias BackendModel =
    { fellas : Dict SessionId Fella
    }


type alias Fella =
    { sessionId : SessionId
    , name : String
    , points : Int
    }


type FrontendMsg
    = UrlClicked UrlRequest
    | UrlChanged Url
    | GivePointToFella Fella
    | NoOpFrontendMsg
    | UpdateMyName String
    | ChangeMyName String


type ToBackend
    = NoOpToBackend
    | IncrementPointsForFella Fella
    | ChangeMyNameTo String


type BackendMsg
    = NoOpBackendMsg
    | ClientConnected SessionId ClientId


type ToFrontend
    = NoOpToFrontend
    | UpdateFellas (Dict SessionId Fella)
    | YourSessionId SessionId
