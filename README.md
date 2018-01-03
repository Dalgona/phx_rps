# PhxRps

PhxRps is a multiplayer rock-paper-scissors game application built using
[Phoenix Framework](http://phoenixframework.org).

It's a single-page application which relies on Phoenix's *Channel* and
*Presence* feature.

## Requirements

Actually this is my development environment. Not tested on earlier versions of
these programs.

* Erlang/OTP 20.1
* Elixir 1.5.2
* Node.js 9.0.0

PostgreSQL or any other database software is not required, as this project
does not use Ecto at all. (Project generated with `--no-ecto` flag)

## Running the Application

* Clone this repository.
* `cd` into the repository and run `mix deps.get` to fetch the dependencies.
* Run `mix phx.server` to start the server. You can also run
    `iex -S mix phx.server`, if you want to use the IEx shell.
* Open two or more browser window and navigate to `http://localhost:4000` to
    test the multiplayer functionality.

## Structure

PhxRps is an umbrella project with three applications:

* `phx_rps`

    Intended to hold business logic for this project, but it's empty for now.

* `phx_rps_web`

    Defines the endpoint and the web interface, especially channels.

* `rps`

    The main business logic of RPS game is defined in this application.
