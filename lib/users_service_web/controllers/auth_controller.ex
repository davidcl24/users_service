defmodule UsersServiceWeb.AuthController do
  @moduledoc """
  This controller manages all of the requests related to authentication
  """
  use UsersServiceWeb, :controller

  alias UsersService.Users
  alias UsersService.Users.User
  alias UsersService.Auth

  action_fallback UsersServiceWeb.FallbackController

  @doc """
  It receives the email and password from the email and returns a new pair of tokens as cookies if the authentication was correct
  """
  def login(conn , %{"email" => email, "password" => password}) do
    case Auth.authenticate_user(email, password) do
      {:ok, user} ->
        tokens = Auth.generate_tokens(user)
        conn |> Plug.Conn.put_resp_cookie(
                  "access_token",
                  tokens.access_token,
                  http_only: true,
                  secure: false,
                  same_site: "Lax",
                  max_age: 45 * 60
                )
              |> Plug.Conn.put_resp_cookie(
                   "refresh_token",
                   tokens.refresh_token,
                   http_only: true,
                   secure: false,
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

  @doc """
  It returns a pair of empty tokens as cookies
  """
  def logout(conn, _params) do
    conn |> Plug.Conn.put_resp_cookie("refresh_token", "", max_age: 0)
         |> Plug.Conn.put_resp_cookie("access_token", "", max_age: 0)
         |> json(%{logout: "ok"})
  end

  @doc """
  It generates a new pair of tokens if the user that made the request exists and returns them as cookies
  """
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
