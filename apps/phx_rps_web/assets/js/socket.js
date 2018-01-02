import {Socket, Presence} from "phoenix"

function GameSocket(roomInfo) {
  /** @type {GameSocket} */
  const that = this;
  let socket = new Socket("/socket", {params: roomInfo})
  let presences = {}
  socket.connect()

  let channel = socket.channel(`rps_room:${roomInfo.room_id}`, {})
  channel.join()
    .receive("ok", resp => that.connectSucceeded)
    .receive("error", resp => that.connectFailed)

  channel.on("rps_room_closed", data => {
    that.roomClosed(data.room_id)
  })

  channel.on("rps_game_started", data => {
    that.gameStarted(data.room_id)
  })

  channel.on("rps_game_finished", data => {
    that.gameFinished(data.winners, data.plays, data.room_id)
  })

  channel.on("rps_play", data => {
    that.someonePlayed(data.by, data.room_id)
  })

  channel.on("presence_state", state => {
    presences = Presence.syncState(presences, state)
    that.presenceUpdated(presences)
  })

  channel.on("presence_diff", diff => {
    presences = Presence.syncDiff(presences, diff)
    that.presenceUpdated(presences)
  })

  //
  // Methods
  //

  /** @type {() => void} */
  this.close = () => {
    channel.leave()
    socket.disconnect()
  }

  /** @type {() => void} */
  this.startGame = () => {
    if (!roomInfo.is_owner) {
      throw "Cannot start the game: You are not the owner of this room."
    }
    channel.push("rps_start_game", {})
  }

  /** @type {(move: string) => void} */
  this.play = move => {
    channel.push("rps_play", {move: move})
  }

  //
  // Callbacks
  //

  /** @type {(response: any) => void} */
  this.connectSucceeded = resp => { console.log("Successfuly connected:", resp) }
  /** @type {(response: any) => void} */
  this.connectFailed = resp => { console.warn("Unable to connect:", resp) }
  /** @type {(presences: any) => void} */
  this.presenceUpdated = null
  /** @type {(roomId: string) => void} */
  this.roomClosed = null
  /** @type {(roomId: string) => void} */
  this.gameStarted = null
  /** @type {(winners: [string], plays: any, roomId: string) => void} */
  this.gameFinished = null
  /** @type {(by: string, roomId: string) => void} */
  this.someonePlayed = null
}

export { GameSocket }
