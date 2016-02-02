defmodule PhoenixToggl.WorkspaceChannelTest do
  use PhoenixToggl.ChannelCase

  alias PhoenixToggl.WorkspaceChannel

  setup do
    {:ok, _, socket} =
      socket("current_user", %{id: 1})
      |> subscribe_and_join(WorkspaceChannel, "workspaces:1")

    {:ok, socket: socket}
  end

  # test "ping replies with status ok", %{socket: socket} do
  #   ref = push socket, "ping", %{"hello" => "there"}
  #   assert_reply ref, :ok, %{"hello" => "there"}
  # end
  #
  # test "shout broadcasts to workspaces:lobby", %{socket: socket} do
  #   push socket, "shout", %{"hello" => "all"}
  #   assert_broadcast "shout", %{"hello" => "all"}
  # end
  #
  # test "broadcasts are pushed to the client", %{socket: socket} do
  #   broadcast_from! socket, "broadcast", %{"some" => "data"}
  #   assert_push "broadcast", %{"some" => "data"}
  # end
end
