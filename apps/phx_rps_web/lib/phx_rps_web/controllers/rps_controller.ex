defmodule PhxRpsWeb.RpsController do
  use PhxRpsWeb, :controller

  def create(conn, %{"player_name" => player_name}) do
    room_id = Base.url_encode64 <<System.monotonic_time::48>>
    case RPS.create_room room_id, player_name do
      {:ok, _pid} ->
        conn
        |> put_status(:created)
        |> json(%{
          room_id: room_id,
          player_name: player_name,
          is_owner: true
        })
      {:error, reason} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: to_string(reason)})
    end
  end

  def join(conn, %{"id" => room_id, "player_name" => player_name}) do
    case RPS.add_player room_id, player_name do
      {:ok, new_name} ->
        conn
        |> json(%{
          room_id: room_id,
          player_name: new_name,
          is_owner: false
        })
      {:error, :no_such_room = reason} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: to_string(reason)})
    end
    json conn, %{message: "show room #{room_id}"}
  end
end
