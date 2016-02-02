defmodule PhoenixToggl.WorkspaceChannelTest do
  use PhoenixToggl.ChannelCase

  alias PhoenixToggl.{User, Workspace, UserSocket, WorkspaceMonitor}

  setup do
    user = %User{}
      |> User.changeset(%{password: "12345678", email: "foo@bar.com", first_name: "John", last_name: "Doe"})
      |> Repo.insert!

    workspace = user
      |> build_assoc(:workspaces)
      |> Workspace.changeset(%{name: "Default"})
      |> Repo.insert!

    {:ok, jwt, _full_claims} = user |> Guardian.encode_and_sign(:token)

    {:ok, socket} = connect(UserSocket, %{"token" => jwt})

    {:ok, socket: socket, user: user, workspace: workspace}
  end

  test "fails to join invalid workspace", %{socket: socket} do
    assert {:error, _} = join(socket, "workspaces:9999999")
  end

  test "after joining", %{socket: socket, user: user, workspace: workspace} do
    {:ok, _, socket} = join(socket, "workspaces:#{workspace.id}")

    assert socket.assigns[:workspace] == workspace
    assert Enum.member?(WorkspaceMonitor.members(workspace.id), user.id)
  end
end
