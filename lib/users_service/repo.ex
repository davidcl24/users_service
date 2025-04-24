defmodule UsersService.Repo do
  use Ecto.Repo,
    otp_app: :users_service,
    adapter: Ecto.Adapters.Postgres
end
