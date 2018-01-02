const createForm = document.getElementById("create-form")
const joinForm = document.getElementById("join-form")

createForm.onsubmit = event => {
  const playerName = event.target.player_name.value
  ajax(
    "post",
    "/ajax/rps",
    { player_name: playerName },
    resp => { console.log(resp) },
    err => { console.warn(err) }
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
    resp => { console.log(resp) },
    err => { console.warn(err) }
  )
  return false;
}

/**
 * @param {string} method
 * @param {string} url
 * @param {any} data
 * @param {(data: string) => void} complete
 * @param {(data: string) => void} error
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
