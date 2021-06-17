defmodule Pfu.Timeline.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :body, :string
    field :url_video, :string
    field :likes_count, :integer, default: 0
    field :reposts_count, :integer, default: 0
    # filed :username, :string, deafult: "user"
    field :photo_urls, {:array, :string}, default: []

    belongs_to :user, Pfu.User

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:body, :user_id, :url_video])
    |> validate_required([:body, :user_id])
    |> validate_length(:body, min: 3, max: 250)
  end
end
