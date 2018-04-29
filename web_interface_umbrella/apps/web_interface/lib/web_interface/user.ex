defmodule WebInterface.User do
  use GenStage

  alias WebInterface.{User, Chat, X, Y, Linker}

  require Logger

  @type t :: %User{}
  defstruct username: nil, password: nil, chats: [], writing: {nil, nil, nil}

  #####   @interface

  @spec start_link(username, password) :: GenServer.on_start()
        when username: String.t(), password: String.t()
  def start_link(username, password) do
    GenStage.start_link(__MODULE__, {username, password})
  end

  #####   @callbacks

  @spec init({username, password}) :: tuple when username: String.t(), password: String.t()
  def init({username, password}) do
    {:producer_consumer, new(username, password), dispatcher: GenStage.BroadcastDispatcher}
  end

  ## @spec handle_events(X.t:%X{type: User, state: %{}}, pid:from, term:state) :: tuple

  ## @spec handle_events(X.t:%X{type: Chat, state: %{}}, pid:from, term:state) :: tuple

  #  @spec handle_events(%Y{type: type}, GenStage.from(), User.t) :: tuple() when type: "WRITE"

  # @spec handle_events(%Y{type: type}, GenStage.from(), User.t) :: tuple() when type: "WRITTING_ON"

  # @spec handle_events(%Y{type: type}, GenStage.from(), User.t) :: tuple() when type: "WRITTING_OFF"

  @spec handle_events(%Y{type: type}, GenStage.from(), User.t()) :: tuple() when type: String.t()

  @spec handle_events(%Y{type: type, payload: payload}, GenStage.from(), User.t()) :: tuple()
        when type: String.t(), payload: term()

  def handle_events([event = %Y{type: "WRITE"}], _from, user) do
    Logger.info("Trigered WRITE")
    new_state = write(user, event.payload)
    {:noreply, [X.new(__MODULE__, new_state)], new_state}
  end

  def handle_events([%Y{type: "WRITTING_ON"}], _from, user) do
    Logger.info("Trigered WRITTING ON")
    new_state = set_write_on(user)
    {:noreply, [X.new(__MODULE__, new_state)], new_state}
  end

  def handle_events([%Y{type: "WRITING_OFF"}], _from, user) do
    Logger.info("Trigered WRITTING OFF")
    new_state = set_write_off(user)
    {:noreply, [X.new(__MODULE__, new_state)], new_state}
  end

  def handle_events([%Y{type: "SET_CHAT", payload: chat}], _from, user) do
    Logger.info("Trigered SET_CHAT")
    new_state = set_chat(user, chat)
    {:noreply, [X.new(__MODULE__, new_state)], new_state}
  end

  def handle_events([%Y{type: "CREATE_CHAT", payload: %{"name" => chat, "to" => to}}], _from, user) do
    Logger.info("Trigered CREATE_CHAT")
    new_state = create_chat(user, chat)
    start_chat(new_state, chat, to)
    {:noreply, [X.new(__MODULE__, new_state)], new_state}
  end

  def handle_events([_evt], _from, state) do
    Logger.info("Trigered OTHERS")
    {:noreply, [], state}
  end

  #####   @struct

  @spec new(username :: String.t(), password :: String.t()) :: User.t()
  def new(username, password) do
    %User{username: username, password: password}
  end

  @spec write(%User{writing: tuple()}, text :: String.t()) :: User.t()
  def write(user = %User{writing: {mode, chat, _text}}, text) do
    %User{user | writing: {mode, chat, text}}
  end

  @spec set_write_on(User.t()) :: User.t()
  def set_write_on(user = %User{writing: {_mode, chat, text}}) do
    %User{user | writing: {:on, chat, text}}
  end

  @spec set_write_off(User.t()) :: User.t()
  def set_write_off(user = %User{writing: {_mode, chat, text}}) do
    %User{user | writing: {:off, chat, text}}
  end

  @spec set_chat(User.t(), chat :: String.t()) :: User.t()
  def set_chat(user = %User{writing: {mode, _chat, text}}, chat) do
    if Enum.any?(user.chats, &(&1 == chat)) do
      %User{user | writing: {mode, chat, text}}
    else
      user
    end
  end

  @spec create_chat(user :: User.t(), chat :: String.t()) :: User.t()
  def create_chat(user = %User{chats: chats}, chat) do
    %User{user | chats: [chat | chats]}
  end

  @spec start_chat(user :: User.t(), chat :: String.t(), to: String.t()) :: User.t()
  def start_chat(user = %User{chats: chats}, chat, to) do
    if Enum.any?(chats, &(&1 == chat)) do
      {:ok, pid} = Chat.start_link(user.username <> to, chat, [{user.username, :aware}])
      Linker.link(self(), pid)
    end
  end
end
