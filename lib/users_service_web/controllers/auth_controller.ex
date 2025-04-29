defmodule UsersServiceWeb.AuthController do
  use UsersServiceWeb, :controller

  alias UsersService.Users
  alias UsersService.Users.User
  alias UsersService.Auth

  def login(conn , %{"username" => username, "password" => password}) do
    case Auth.authenticate_user(username, password) do
      {:ok, user} ->
        tokens = Auth.generate_tokens(user)
        conn |> Plug.Conn.put_resp_cookie(
                  "access_token",
                  tokens.access_token,
                  http_only: true,
                  secure: true,
                  same_site: "Lax",
                  max_age: 45 * 60
                )
              |> Plug.Conn.put_resp_cookie(
                   "refresh_token",
                   tokens.refresh_token,
                   http_only: true,
                   secure: true,
                   same_site: "Lax",
                   max_age: 7 * 24 * 60 * 60
                 )

      {:error, :invalid_username} ->
        conn |> put_status(:unauthorized) |> json(%{error: "Invalid username"})

      {:error, :invalid_password} ->
        conn |> put_status(:unauthorized) |> json(%{error: "Invalid password"})
    end
  end

  def logout(conn, _params) do
    conn |> Plug.Conn.put_resp_cookie("refresh_token", "", max_age: 0)
         |> Plug.Conn.put_resp_cookie("access_token", "", max_age: 0)
  end
end
