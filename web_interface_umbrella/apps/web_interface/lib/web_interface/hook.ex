defmodule WebInterface.Hook do
  use GenStage

  require Logger

  alias WebInterface.{Hook, X, Y}

  @type hook_mode :: :in | :out

  #####   @interface

  @doc """
    Starts a hook and hooks in or out mode to a subject
  """
  @spec start_link(mode :: hook_mode, subject :: pid()) :: GenServer.on_start()
  def start_link(mode, subject) do
    GenStage.start_link(__MODULE__, {mode, subject})
  end

  @doc """
    Hooks an in and out hook to the subject
  """
  @spec io_hook(subject :: pid()) :: {:ok, in_pid :: pid()}
  def io_hook(subject) do
    {:ok, out_hook} = Hook.start_link(:out, subject)
    {:ok, in_hook} = Hook.start_link(:in, subject)
    {out_hook, in_hook}
  end

  @doc """
    Pushes an Y.t event to an in hook
  """
  @spec push(event, in_hook_pid) :: :ok when in_hook_pid: pid(), event: Y.t()
  def push(event, in_hook_pid) do
    GenServer.call(in_hook_pid, event)
  end

  #####   @callbacks

  @spec init({mode, subject}) :: tuple() when mode: hook_mode, subject: pid()
  def init(args = {:in, _subject}) do
    send(self(), :subscribe)
    {:producer, args}
  end

  def init(args = {:out, _subject}) do
    send(self(), :subscribe)
    {:consumer, args}
  end

  def init(args = {{:out, pid}, _subject}) do
    send(self(), :subscribe)
    {:consumer, args}
  end

  @spec handle_events(list(), GenStage.from(), pid()) :: tuple()
  def handle_events([event = %X{}], _from, state = {:out, _}) do
    IO.inspect(event)
    {:noreply, [], state}
  end

  def handle_events([event = %X{}], _from, state = {{:out, pid}, _}) do
    GenServer.cast(pid, {:change, event})
    {:noreply, [], state}
  end

  def handle_events([event | []], _from, state = {:out, _}) do
    IO.inspect event
    {:noreply, [event], state}
  end

  def handle_events(events, _from, state = {:out, _}) do
    {:noreply, [], state}
  end

  @spec handle_demand(demand :: term(), state :: term()) :: tuple()
  def handle_demand(demand, state = {:in, _}) when demand > 0 do
    {:noreply, [], state}
  end

  @spec handle_call(event :: Y.t(), from :: GenServer.from(), state :: tuple()) ::
          {:reply, reply, [event], new_state}
          | {:reply, reply, [event], new_state, :hibernate}
          | {:noreply, [event], new_state}
          | {:noreply, [event], new_state, :hibernate}
          | {:stop, reason, reply, new_state}
          | {:stop, reason, new_state}
        when reply: term(), new_state: term(), reason: term(), event: term()
  def handle_call(event, _from, state) do
    IO.inspect event
    {:reply, :pushed, [event], state}
  end

  @spec handle_info(:subscribe, state :: {mode :: hook_mode, subject :: pid()}) :: tuple()
  @spec handle_info(info :: term(), state :: tuple()) ::
          {:noreply, [event], new_state}
          | {:noreply, [event], new_state, :hibernate}
          | {:stop, reason :: term(), new_state}
        when new_state: term(), event: term()

  def handle_info(:subscribe, state = {:out, subject}) do
    GenStage.async_subscribe(self(), to: subject, min_demand: 0, max_demand: 1)
    {:noreply, [], state}
  end

  def handle_info(:subscribe, state = {:in, subject}) do
    GenStage.async_subscribe(subject, to: self(), min_demand: 0, max_demand: 1)
    {:noreply, [], state}
  end

  def handle_info(_info, state) do
    {:noreply, [], state}
  end
end
