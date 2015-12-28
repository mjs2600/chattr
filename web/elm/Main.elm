module Main where

import Html exposing(..)
import Html.Attributes exposing(..)
import Html.Events exposing(..)
import Json.Decode as Json
import Effects exposing (..)

-- import Graphics.Element exposing(..)
-- import Text
import List
import StartApp
import Signal
import Task

-- MODEL
type alias Message = {userName: String, text: String}
type alias Model =
  { messages: List Message
  , currentUser: String
  , newMessage: String
  }

defaultMessage: Message
defaultMessage = {userName="", text=""}

initialModel: Model
initialModel =
  { messages = [{userName = "me", text = "Hello, World!"}]
  , currentUser = "mjs2600"
  , newMessage = ""
  }

-- VIEW

view: Signal.Address Action -> Model -> Html
view address model = div []
                     [ chatMessages model.messages
                     , newChatMessage address model.newMessage model.currentUser
                     ]

newChatMessage: Signal.Address Action -> String -> String -> Html
newChatMessage address newMessage user = Html.form [onSubmitWithOptions address newMessage user]
                                    [ input [type' "text"
                                            , onInput address UpdateMessage
                                            , value newMessage] []
                                    , input [type' "submit", value "Send"] []]

onInput : Signal.Address a -> (String -> a) -> Attribute
onInput address f =
  on "input" targetValue (\v -> Signal.message address (f v))

onSubmitWithOptions: Signal.Address Action -> String -> String -> Attribute
onSubmitWithOptions address newMessage user =
  onWithOptions "submit"
                  {defaultOptions | preventDefault = True}
                  Json.value
                        (\_ -> Signal.message address (SendMessage newMessage user))

stringToChat: Message -> Html
stringToChat message = li [] [text (message.userName ++ ": " ++ message.text)]

chatMessages: List Message -> Html
chatMessages messages = messages
                      |> List.map stringToChat
                      |> ul []

-- PORTS
port messages : Signal Message

port tasks : Signal (Task.Task Never ())
port tasks = app.tasks

port addMessage : Signal Message
port addMessage = sendMessageMailbox.signal
  |> Signal.map processAction

processAction: Action -> Message
processAction action =
  case action of
    SendMessage msg user -> {userName=user, text=msg}
    _ -> defaultMessage

sendMessageMailbox: Signal.Mailbox Action
sendMessageMailbox = Signal.mailbox NoOp

-- UPDATE
type Action = NoOp | AddMessage Message | UpdateMessage String | SendMessage String String

update: Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    NoOp -> (model, none)
    AddMessage message ->
        ({model | messages = message::model.messages}, none)
    UpdateMessage updatedMessage ->
      ({model | newMessage = updatedMessage}, none)
    SendMessage msg user -> ({model | newMessage=""},
                             Effects.task (socketMessage action))

socketMessage: Action-> Task.Task x Action
socketMessage action = action
  |> Signal.send sendMessageMailbox.address
  |> Task.map (\_ -> NoOp)

incomingActions: Signal Action
incomingActions = Signal.map AddMessage messages

main: Signal Html
main = app.html

app: { html : Signal Html, model : Signal Model, tasks: Signal (Task.Task Never ())}
app = StartApp.start {
        init=(initialModel, none),
        view=view,
        update=update,
        inputs=[incomingActions]
      }
