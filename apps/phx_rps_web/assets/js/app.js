import "phoenix_html"
import "./ui";

const elmDiv = document.getElementById("elm-main");
const elmApp = Elm.Main.embed(elmDiv, { csrfToken: window.csrfToken });
