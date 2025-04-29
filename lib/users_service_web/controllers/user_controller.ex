defmodule UsersServiceWeb.UserController do
  use UsersServiceWeb, :controller

  alias UsersService.Users
  alias UsersService.Users.User
  alias UsersService.Auth

  action_fallback UsersServiceWeb.FallbackController

  def index(conn, _params) do
    users = Users.list_users()
    render(conn, :index, users: users)
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Users.create_user(user_params) do
      tokens = Auth.generate_tokens(user)
      conn
      |> Plug.Conn.put_resp_cookie(
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
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/users/#{user}")
      |> render(:show, user: user)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Users.get_user!(id)
    render(conn, :show, user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Users.get_user!(id)

    with {:ok, %User{} = user} <- Users.update_user(user, user_params) do
      render(conn, :show, user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Users.get_user!(id)

    with {:ok, %User{}} <- Users.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end
end
