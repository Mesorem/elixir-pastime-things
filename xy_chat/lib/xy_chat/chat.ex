defmodule XYChat.Chat do
  use GenStage

  require Logger

  alias XYChat.{Chat, X, User}

  @type t :: %Chat{}
  defstruct id: nil, name: nil, text: [], users: []

  #####   @interface

  @spec start_link(id :: String.t(), name :: String.t(), users: list()) :: GenServer.on_start()
  def start_link(id, name, users) do
    GenStage.start_link(__MODULE__, {id, name, users})
  end

  #  @spec join({String.t :: user, pid() :: pid}) :: :ok

  #  @spec leave({String.t :: user, pid() :: pid}) :: :ok

  #  @spec ignore(String.t :: user) :: :ok

  #####   @callbacks

  @spec init({id :: String.t(), name :: String.t(), users :: list()}) :: {:ok, Chat.t()}
  def init({id, name, users}) do
    send(self(), :broadcast_creation)
    {:producer_consumer, new(id, name, users)}
  end

  #  @spec handle_events([%X{type: User, state: %{writing: {:on, this_chat}}}], pid:from, term:state = {this_chat,_}) :: tuple
  @spec handle_events([evt :: X.t()], from :: pid(), chat :: Chat.t()) :: tuple()
  def handle_events(
        [%X{state: %User{username: username, writing: {:on, this_chat, nil}}}],
        _from,
        chat = %Chat{name: this_chat}
      ) do
    Logger.info("CHAT -> Triggered WRITE ON")
    new_chat = add_text(chat, username, "#{username} is writing...")
    {:noreply, [X.new(__MODULE__, new_chat)], new_chat}
  end

  def handle_events(
        [%X{state: %User{username: username, writing: {:off, this_chat, _text}}}],
        _from,
        chat = %Chat{name: this_chat}
      ) do
    Logger.info("CHAT -> Triggered WRITE OFF")
    new_chat = add_text(chat, username, "#{username} is not writing anymore...")
    {:noreply, [X.new(__MODULE__, new_chat)], new_chat}
  end

  def handle_events(
        [%X{state: %User{username: username, writing: {:on, this_chat, text}}}],
        _from,
        chat = %Chat{name: this_chat}
      ) do
    Logger.info("CHAT -> Triggered WRITE")
    new_chat = add_text(chat, username, text)
    {:noreply, [X.new(__MODULE__, new_chat)], new_chat}
  end

  def handle_events(evts, _from, chat) do
    Logger.info("CHAT -> Triggered OTHERS")
    IO.inspect(evts)
    {:noreply, [X.new(__MODULE__, evts)], chat}
  end

  # @spec handle_events(event = [%X{}], pid:from, term:state) :: tuple

  @spec handle_info(info :: term(), state :: Chat.t()) :: tuple
  def handle_info(:broadcast_creation, chat = %Chat{id: _id, name: _name, users: _user}) do
    {:noreply, [], chat}
  end

  def handle_info(_info, state) do
    {:noreply, [], state}
  end

  #####    @functions

  @spec add_text(chat :: Chat.t(), username :: String.t(), text :: String.t()) :: Chat.t()
  def add_text(chat, username, text) do
    %Chat{chat | text: [{username, text} | chat.text]}
  end

  #####    @struct

  @spec new(id :: String.t(), name :: String.t(), users :: list()) :: Chat.t()
  def new(id, name, users) do
    %Chat{id: id, name: name, users: users}
  end
end
