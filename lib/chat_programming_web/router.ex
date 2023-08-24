defmodule ChatProgrammingWeb.Router do
  use ChatProgrammingWeb, :router

  import ChatProgrammingWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {ChatProgrammingWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug CORSPlug, origin: [~r/.*/]
    plug :accepts, ["json"]
  end

  scope "/", ChatProgrammingWeb do
    pipe_through :browser

    live "/", PageLive, :index
    live "/proposal_viewer", ProposalViewerLive, :index
    live "/chat_new", ChatNewLive, :index
    live "/arweave_syncer", ArweaveSyncerLive, :index
    live "/arweave_querier", ArweaveQuerierLive, :index
    get "/test", PageController, :home

  end

  # Other scopes may use custom stacks.
  scope "/api/v1", ChatProgrammingWeb do
    pipe_through :api

    post "/proposal", ProposalController, :create
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:chat_programming, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ChatProgrammingWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", ChatProgrammingWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{ChatProgrammingWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", ChatProgrammingWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{ChatProgrammingWeb.UserAuth, :ensure_authenticated}] do
      # live "/users/settings", UserSettingsLive, :edit
      # live "/uploader", UploaderLive, :index
      # live "/chatter", ChatterLive, :index
      # live "/chatgpt", ChatGPTLive, :index
      # live "/awesome_ai", AwesomeAILive, :index
      live "/embedbase_interactor", EmbedbaseInteractorLive, :index
      # live "/chat", ChatterLive, :index
      # live "/vector_dataset_handler/move", VevtorDatasetHandler.MoveLive, :index
      # # live "/company_analyzer", CompanyAnalyzerLive, :index
      # live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", ChatProgrammingWeb do
    pipe_through [:browser, :require_authenticated_admin_user]

    live_session :require_authenticated_admin_user,
      on_mount: [{ChatProgrammingWeb.UserAuth, :ensure_authenticated}] do
      live "/embedbase_manager", EmbedbaseManagerLive, :index
      live "/manager/train", TrainLive, :index
      # live "/manager", ManagerLive, :index
      live "/manager/model_view", Manager.ModuleViewLive, :index
    end
  end

  scope "/", ChatProgrammingWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{ChatProgrammingWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
