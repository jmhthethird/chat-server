defmodule ChatServer.UpdateState do
  require Logger

  alias ChatServer.Schema

  defmodule State do
    @derive {Poison.Encoder, only: [room: [:id, :slug, :name]]}

    defstruct [:room]
  end

  def call(params \\ %{}, _user, state) do
    Logger.info "Updating room " <> inspect(params)

    # TODO verify user is allowed to update room of that type

    with {:ok, record} <- update(params, state),
         :ok <- broadcast_update(record) do
      {:ok, record}
    else
      _ -> :error
    end
  end

  defp update(params, state) do
    changeset = params
    |> Map.take([:id, :name])
    |> Map.put(:status, state)

    Schema.Room.update(params, changeset)
  end

  defp broadcast_update(room) do
    event = %State{room: room}

    ChatPubSub.broadcast! "events", "room:updated", event
  end
end
