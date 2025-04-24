defmodule UsersService.Auth do
  alias UsersService.Users.User
  alias UsersService.Repo
  import Ecto.Query



  def generate_token(user) do
    claims = %{
      "sub" => user.id,
      "username" => user.username,
      "email" => user.email
    }

    secret = Application.get_env(:users_service, UsersServiceWeb.Endpoint)[:secret_key_base]

    {:ok, token, _claims} = Joken.generate_and_sign(%{}, claims, Joken.Signer.create("HS256", secret))
    token
  end
end