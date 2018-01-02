/**
 * @typedef {{room_id: string, player_name: string, is_owner: boolean}} RoomInfo
 */

import { GameSocket } from "./socket"

const formContainer = document.getElementById("form-container")
const createForm = document.getElementById("create-form")
const joinForm = document.getElementById("join-form")
const gameRoomContainer = document.getElementById("game-room-container")

createForm.onsubmit = event => {
  const playerName = event.target.player_name.value
  ajax(
    "post",
    "/ajax/rps",
    { player_name: playerName },
    onJoinSuccess,
    err => {
      alert(`Error from the server:\n${err.error}`)
    }
  )
  return false;
}

joinForm.onsubmit = event => {
  let roomId = event.target.room_id.value
  let playerName = event.target.player_name.value
  ajax(
    "post",
    `/ajax/rps/${roomId}/join`,
    { player_name: playerName },
    onJoinSuccess,
    err => {
      alert(`Error from the server:\n${err.error}`)
    }
  )
  return false;
}

/**
 * @param {string} method
 * @param {string} url
 * @param {any} data
 * @param {(data: RoomInfo) => void} complete
 * @param {(data: {error: string}) => void} error
 */
function ajax(method, url, data, complete, error) {
  var xhr = new XMLHttpRequest()
  xhr.onload = e => {
    if (e.target.status >= 200 && e.target.status < 400) {
      complete(JSON.parse(e.target.responseText))
    } else {
      error(JSON.parse(e.target.responseText))
    }
  }
  xhr.onerror = e => {
    error(JSON.parse(e.target.responseText))
  }
  xhr.open(method, url, true)
  xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded")
  let params = []
  for (let key in data) {
    let name = encodeURIComponent(key)
    let value = encodeURIComponent(data[key])
    params.push(`${name}=${value}`)
  }
  xhr.send(params.join("&"))
}

function emptyElement(element) {
  while (element.firstChild) {
    element.removeChild(element.firstChild)
  }
}

/**
 * @param {RoomInfo} roomInfo
 */
function onJoinSuccess(roomInfo) {
  let room = new GameRoom(roomInfo)
  formContainer.style.display = "none"
  emptyElement(gameRoomContainer)
  gameRoomContainer.appendChild(room.element)
}

/**
 * @param {RoomInfo} roomInfo
 */
function GameRoom(roomInfo) {
  /** @type {GameRoom} */
  const that = this
  /** @type {HTMLDivElement} */
  const elem = document.getElementById("template-game-room").cloneNode(true)
  const playerList = elem.getElementsByClassName("player-list")[0]
  const moveButtons = elem.querySelectorAll(".move-buttons button")
  const sock = new GameSocket(roomInfo)
  let presences = {}

  elem.id = ""
  if (!roomInfo.is_owner) {
    const adminOnly = [...elem.getElementsByClassName("owner-only")]
    for (var e of adminOnly) {
      e.remove()
    }
  } else {
    elem.getElementsByClassName("room-id")[0].textContent = roomInfo.room_id
    elem.getElementsByClassName("start-button")[0].onclick = event => {
      sock.startGame()
    }
  }
  elem.getElementsByClassName("current-player-name")[0].textContent = roomInfo.player_name
  elem.getElementsByClassName("leave-button")[0].onclick = event => {
    that.leave()
  }
  for (let btn of moveButtons) {
    btn.onclick = event => {
      sock.play(btn.getAttribute("data-move"))
    }
  }
  disableMoveButtons(true)

  sock.presenceUpdated = data => {
    presences = data
    renderPlayerList(data)
  }

  sock.roomClosed = _ => {
    alert("Room closed by the owner.")
    that.leave()
  }

  sock.gameStarted = _ => {
    renderPlayerList(presences)
    disableMoveButtons(false)
  }

  sock.gameFinished = (winners, plays) => {
    console.log(winners, plays)
    for (let player in presences) {
      let playerElem = playerList.querySelector(`[data-player-name="${player}"]`)
      playerElem.getElementsByClassName("status")[0].textContent = plays[player]
    }
    for (let winner of winners) {
      let playerElem = playerList.querySelector(`[data-player-name="${winner}"]`)
      console.log(winner, playerElem)
      playerElem.classList.add("winner")
    }
    disableMoveButtons(true)
  }

  sock.someonePlayed = player => {
    let playerElem = playerList.querySelector(`[data-player-name="${player}"]`)
    playerElem.classList.add("decided")
    playerElem.getElementsByClassName("status")[0].textContent = "Decided"
  }

  this.element = elem

  this.leave = () => {
    sock.close()
    formContainer.style.display = "block"
    emptyElement(gameRoomContainer)
  }

  function disableMoveButtons(disabled) {
    for (let btn of moveButtons) {
      btn.disabled = disabled
    }
  }

  function renderPlayerList(presences) {
    emptyElement(playerList)
    for (let player in presences) {
      let li = document.createElement("li")
      li.setAttribute("data-player-name", player)
      li.className = "player"
      li.innerHTML = `<span class="name">${player}</span><br><span class="status">Waiting</span>`
      playerList.appendChild(li)
    }
  }
}
