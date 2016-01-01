// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "deps/phoenix_html/web/static/js/phoenix_html";

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

import socket from "./socket";
let channel = socket.channel("rooms:dev", {});
channel.join()
    .receive("ok", resp => { console.log("Joined successfully", resp); })
    .receive("error", resp => { console.log("Unable to join", resp); });

function sendNewMessage(msg) {
  console.log("Sent message: ", msg.text);
  channel.push("new_msg", msg);
}

var container = document.getElementById('elm-main');
var elmApp = Elm.embed(Elm.Main, container, {messages: {userName: "", text: ""}});
channel.on("new_msg", msg => {
  console.log("Got message: ", msg);
  elmApp.ports.messages.send(msg);
});
elmApp.ports.addMessage.subscribe(sendNewMessage);
