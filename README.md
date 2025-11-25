# Users Service
This service manages the creation, update and authentication of users in a streaming app

## Characteristics
- It offers a full CRUD for users.
- It allows users to register a new account, login to an existing account and logout from their current session.
- It manages the authentication of users and creates JWT tokens.
- It connects to a PostgreSQL making use of Ecto.

## Configuration
The app uses environment to create the database connection when in development
```
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=default
DB_PASSWORD=example
DB_DATABASE=streamingdb
```
While in production, due to the characteristics of Phoenix, it will make use of
an environment variable that defines the full connection URL.

`DATABASE_URL=postgres://user:passwd@hostname:5432/database_name`

In order to indicate we want to set the server in production mode, we must set the next env variable.

`PHX_SERVER=true`

It also needs a secret key for the tokens.

`SECRET_KEY=super-secret-key`

## Setup
To start your Phoenix server:

  * Run `mix deps.get --only prod` to install and setup dependencies.
  * Set the env variable `MIX_ENV=prod` to set the app in production mode.
  * Run `mix release` to build the release.
  * Start Phoenix endpoint with `./app/_build/prod/rel/user_service start`.

Now the server will be active at [`localhost:4000`](http://localhost:4000).

