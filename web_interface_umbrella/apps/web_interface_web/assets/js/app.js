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
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

import socket from "./socket"

(function() {

  console.log('Trying to connect socket...')

  socket.connect()
  console.log('Connected successfully.')

  console.log('Trying to connect to user channel...')
  let channel = socket.channel("user:adriax", {})
  channel.join()
    .receive("ok", resp => console.log("Connected successfully to user channel. ", resp))
    .receive("error", resp => console.log("Error conncting to user channel. ", resp))

  setTimeout(() => channel.push("CREATE_CHAT", {name: "test_chat1", to: "test_user_"}), 3000)
  setTimeout(() => channel.push("SET_CHAT", {chat: "test_chat1"}), 6000)
  setTimeout(() => channel.push("WRITTING_ON", {}), 9000)
  setTimeout(() => channel.push("WRITE", {text: "text1"}), 12000)
  setTimeout(() => channel.push("WRITTING_OFF", {}), 12000)

})();
