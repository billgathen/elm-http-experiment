import Html exposing (..)
import Html.Attributes exposing (..)
import Html.App as App
import Http
import Json.Decode as Json exposing(int, string, bool, list, (:=))
import Json.Decode.Extra exposing ((|:))
import Task

main =
  App.program
    { init          = init
    , view          = view
    , update        = update
    , subscriptions = subscriptions
    }


-- MODEL

type alias Users =
  { users: List User
  }

type alias User =
  { name:    String
  , id:      Int
  , reports: List Report
  }

type alias Report =
  { name:   String
  , id:     Int
  , active: Bool
  }

type alias Model =
  { greeting : String
  , error:     String
  , title:     String
  , users:     List User
  }

init : (Model, Cmd Msg)
init =
  ( Model "?" "" "Elm HTTP Experiment" []
  , usersFromServer
  )


-- UPDATE

type Msg
  = GreetingFetchSucceed String
  | GreetingFetchFail Http.Error
  | SingleUserFetchSucceed User
  | SingleUserFetchFail Http.Error
  | UsersFetchSucceed (List User)
  | UsersFetchFail Http.Error

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    GreetingFetchSucceed newGreeting ->
      ({ model | greeting = newGreeting, error = "" }, Cmd.none)
    GreetingFetchFail err ->
      ({ model | error = (toString err), greeting = "" }, Cmd.none)
    SingleUserFetchSucceed newUser ->
      ({ model | users = [ newUser ] }, Cmd.none)
    SingleUserFetchFail err ->
      ({ model | error = (toString err), users = [] }, Cmd.none)
    UsersFetchSucceed newUsers ->
      ({ model | users = newUsers }, Cmd.none)
    UsersFetchFail err ->
      ({ model | error = (toString err), users = [] }, Cmd.none)


-- VIEW

view : Model -> Html Msg
view model =
  div [ class "container" ]
    [ h1 [] [ text model.title ]
    , errorView model.error
    , usersView model.users
    ]

errorView : String -> Html Msg
errorView error =
  if (error == "") then text "" else div [ class "alert alert-danger" ] [ text "Error connecting to server" ]

usersView : List User -> Html Msg
usersView users =
  let
    userList = (List.map userView users)
  in
    ul [ class "list-group" ] userList

userView : User -> Html Msg
userView user =
  let
    classes = "list-group-item"
    label   = user.name ++ " (" ++ (toString user.id) ++ ")"
    reports = List.map reportView user.reports
  in
    li [ class classes ]
      [ text label
      , ul [] reports
      ]

reportView : Report -> Html Msg
reportView report =
  let
    status = if report.active then "list-group-item-success" else "disabled"
    classes = "list-group-item " ++ status
    label   = report.name ++ " (" ++ (toString report.id) ++ ")"
  in
    li [ class classes ]
      [ text label ]


-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none


-- HTTP

serverAddress =
  "http://localhost:8080"

greetingFromServer : Cmd Msg
greetingFromServer =
  let
      url = serverAddress ++ "/hello"
  in
     Task.perform GreetingFetchFail GreetingFetchSucceed (Http.get decodeGreeting url)

decodeGreeting : Json.Decoder String
decodeGreeting =
  Json.at ["greeting"] Json.string

usersFromServer : Cmd Msg
usersFromServer =
  let
      url = serverAddress ++ "/users"
  in
     Task.perform UsersFetchFail UsersFetchSucceed (Http.get decodeUsers url)

decodeUsers : Json.Decoder (List User)
decodeUsers =
  Json.at ["users"] (Json.list decodeUser)
  -- Json.succeed Users
  -- |: ("users" := Json.list decodeUser)

singleUserFromServer : Cmd Msg
singleUserFromServer =
  let
      url = serverAddress ++ "/user?id=1"
  in
     Task.perform SingleUserFetchFail SingleUserFetchSucceed (Http.get decodeUser url)

decodeUser : Json.Decoder User
decodeUser =
  Json.succeed User
  |: ("name" := string)
  |: ("id"   := int)
  |: ("reports" := Json.list decodeReport)

decodeReport : Json.Decoder Report
decodeReport =
  Json.succeed Report
  |: ("name"   := string)
  |: ("id"     := int)
  |: ("active" := bool)
