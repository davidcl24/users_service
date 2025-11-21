# ============================
# 1) Etapa de build
# ============================
FROM elixir:1.18.4-alpine AS build

# Instalar dependencias del sistema
RUN apk add --no-cache build-base git npm

# Crear directorio de la app
WORKDIR /app

# Instalar hex y rebar (no piden confirmación)
RUN mix do local.hex --force, local.rebar --force

# Copiar mix.exs y mix.lock
COPY mix.exs mix.lock ./

# Descargar dependencias
RUN mix deps.get --only prod

# Copiar todo el proyecto
COPY . .

# Compilar el release de Phoenix
RUN MIX_ENV=prod mix assets.deploy
RUN MIX_ENV=prod mix release

# ============================
# 2) Runtime: imagen final
# ============================
FROM elixir:1.18.4-alpine AS app

# Instalar paquetes mínimos necesarios
RUN apk add --no-cache openssl ncurses-libs

WORKDIR /app

# Copiar el release generado
COPY --from=build /app/_build/prod/rel/* ./users_service/

# Exponer el puerto de Phoenix
EXPOSE 4000

# Iniciar la aplicación
CMD ["./users_service/bin/users_service", "start"]
