defmodule BraveWeb.Router do
  use BraveWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", BraveWeb do
    pipe_through :api

    get "/user", UserController, :show
    post "/user", UserController, :create

    get "/games", GameController, :index
    get "/completed", GameController, :index_completed
    get "/game", GameController, :show
    post "/games", GameController, :create
    patch "/action", GameController, :update
  end

  # coveralls-ignore-start

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]
      live_dashboard "/dashboard", metrics: BraveWeb.Telemetry
    end
  end

  #coveralls-ignore-stop
end
