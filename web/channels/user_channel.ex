defmodule PhoenixToggl.UserChannel do
  use PhoenixToggl.Web, :channel

  alias PhoenixToggl.{TimerMonitor, TimeEntry, TimeEntryActions}

  def join("users:" <> user_id, _params, socket) do
    user_id = String.to_integer(user_id)
    current_user = socket.assigns.current_user

    if user_id == current_user.id do
      socket = set_active_time_entry(socket, user_id)

      {:ok, %{time_entry: socket.assigns.time_entry}, socket}
    else
      {:error, %{reason: "Invalid user"}}
    end
  end

  def handle_in("time_entry:current", _params, socket), do: {:reply, {:ok, socket.assigns.time_entry}, socket}

  def handle_in("time_entry:start",
  %{
    "started_at" => started_at,
    "description" => description,
    "workspace_id" => workspace_id
  }, socket) do

    current_user = socket.assigns.current_user

    attributes = %{
      description: description,
      workspace_id: workspace_id,
      user_id: current_user.id,
      started_at: started_at
    }

    case TimeEntryActions.start(attributes) do
      {:error, :active_time_entry_params_exists} ->
        {:reply, :error, socket}
      time_entry ->
        TimerMonitor.create(current_user.id)
        TimerMonitor.start(current_user.id, time_entry.id, time_entry.started_at)

        {:reply, {:ok, time_entry}, socket}
    end
  end

  def handle_in("time_entry:stop",
  %{
    "id" => id,
    "stopped_at" => stopped_at,
  }, socket) do
    current_user = socket.assigns.current_user
    {:ok, stopped_at} = Timex.DateFormat.parse(stopped_at, "{ISO}")

    time_entry = current_user
    |> assoc(:time_entries)
    |> Repo.get!(id)
    |> TimeEntry.stop(stopped_at)
    |> Repo.update!

    TimerMonitor.stop(current_user.id)

    {:reply, {:ok, time_entry}, socket}
  end

  # In case there's an existing time entry monitor running it
  # assigns it's TimeEntry to the socket. Otherwise it will try
  # find an active TimeEntry in the database and start a new monitor
  # with it.
  defp set_active_time_entry(socket, user_id) do
    case TimerMonitor.info(user_id) do
      %{time_entry_id: time_entry_id} ->
        time_entry = Repo.get! TimeEntry, time_entry_id

        assign(socket, :time_entry, time_entry)
      {:error, :invalid_timer} ->
        case TimeEntryActions.get_active_for_user(user_id) do
          nil ->
            assign(socket, :time_entry, nil)
          time_entry ->
            TimerMonitor.create(user_id)
            TimerMonitor.start(user_id, time_entry.id, time_entry.started_at)
            assign(socket, :time_entry, time_entry)
        end
    end
  end
end
