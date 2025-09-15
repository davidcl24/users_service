defmodule UsersServiceWeb.UserJSON do
  alias UsersService.Users.User

  @doc """
  Renders a list of users.
  """
  def index(%{users: users}) do
    %{data: for(user <- users, do: data(user))}
  end

  @doc """
  Renders a single user.
  """
  def show(%{user: user}) do
    %{data: data(user)}
  end

  @doc"""
  Renders the user just created with the JWT Token.
  """
  def show_with_token(%{user: user, tokens: tokens}) do
    %{
      data: data(user),
      tokens: tokens
    }
  end

  defp data(%User{} = user) do
    %{
      id: user.id,
      username: user.username,
      email: user.email,
      signup_date: user.signup_date,
      role: user.role
    }
  end
end
