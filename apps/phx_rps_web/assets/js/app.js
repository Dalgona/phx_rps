import "phoenix_html"
import "./ui";
import Elm from "./elm"

const elmDiv = document.getElementById("elm-main");
const elmApp = Elm.Main.embed(elmDiv);
