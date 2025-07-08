defmodule UsersServiceWeb.AuthController do
  use UsersServiceWeb, :controller

  alias UsersService.Users
  alias UsersService.Users.User
  alias UsersService.Auth

  action_fallback UsersServiceWeb.FallbackController

  def login(conn , %{"email" => email, "password" => password}) do
    case Auth.authenticate_user(email, password) do
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
              |> json(%{logged: "Succesfully"})

    {:error, :invalid_email} ->
        conn |> put_status(:unauthorized) |> json(%{error: "Invalid e-mail"})

    {:error, :invalid_password} ->
        conn |> put_status(:unauthorized) |> json(%{error: "Invalid password"})
    end
  end

  def logout(conn, _params) do
    conn |> Plug.Conn.put_resp_cookie("refresh_token", "", max_age: 0)
         |> Plug.Conn.put_resp_cookie("access_token", "", max_age: 0)
         |> json(%{logout: "ok"})
  end

  def refresh(conn, _params) do
    user_id = Plug.Conn.get_req_header(conn, "x-user-id") |> List.first()

    if user_id == nil do
      {:error, :unauthorized}
    else
      user = Users.get_user!(user_id)

      new_tokens = Auth.generate_tokens(user)
      conn |> Plug.Conn.put_resp_cookie(
                "access_token",
                new_tokens.access_token,
                http_only: true,
                secure: true,
                same_site: "Lax",
                max_age: 45 * 60
              )
           |> Plug.Conn.put_resp_cookie(
                "refresh_token",
                new_tokens.refresh_token,
                http_only: true,
                secure: true,
                same_site: "Lax",
                max_age: 7 * 24 * 60 * 60
              )
           |> json(%{refresh: "Succesfully"})
    end
  end
end
