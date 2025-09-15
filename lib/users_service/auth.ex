defmodule UsersService.Auth do
  alias UsersService.Users.User
  alias UsersService.Repo
  import Ecto.Query



  def authenticate_user(email, password) do
    query = from(u in User, where: u.email == ^email)
    case Repo.one(query) do
      nil -> Pbkdf2.no_user_verify()
             {:error, :invalid_email}

      user ->
        if (Pbkdf2.verify_pass(password, user.password_hash)) do
          {:ok, user}
        else
          {:error, :invalid_password}
        end
      end
  end

  def generate_tokens(user) do
    secret = Application.get_env(:users_service, UsersServiceWeb.Endpoint)[:secret_key_base]
    signer = Joken.Signer.create("HS256", secret)

    now = Joken.current_time()

    # Access token: expires in 45 minutes
    access_exp = now + (45 * 60);

    access_claims = %{
      "sub" => user.id,
      "username" => user.username,
      "email" => user.email,
      "role" => user.role,
      "type" => "access"
    }

    # Refresh token: expires in 7 days
    refresh_exp = now + (7 * 24 * 60 * 60)

    refresh_claims = %{
      "sub" => user.id,
      "type" => "refresh"
    }

    {:ok, access_token, _claims} = Joken.generate_and_sign(%{"exp" => access_exp}, access_claims, signer)

    {:ok, refresh_token, _claims} = Joken.generate_and_sign(%{"exp" => refresh_exp}, refresh_claims, signer)

    %{
      access_token: access_token,
      refresh_token: refresh_token
    }
  end
end