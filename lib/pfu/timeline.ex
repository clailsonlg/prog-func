defmodule Pfu.Timeline do
  @moduledoc """
  The Timeline context.
  """

  import Ecto.Query, warn: false
  alias Pfu.Repo
  alias Pfu.Timeline.Post
  alias Pfu.User #Programado

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def list_posts do
    #Repo.all(from p in Post, join: u in User, on: p.user_id == u.id, select: %Post{id: p.id, body: p.body, likes_count: p.likes_count, reposts_count: p.reposts_count, user_id: p.user_id, username: u.username}, order_by: [desc: p.id])
    Repo.all(from p in Post, join: u in assoc(p, :user), preload: [user: u], order_by: [asc: p.likes_count])
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(id), do: Repo.get!(Post, id)

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(attrs \\ %{}) do
    {:ok, post} = %Post{} |> Post.changeset(attrs) |> Repo.insert()

    user = Repo.get(User, post.user_id)
    post = Map.merge(post, %{user: user})

    {:ok, post} |> broadcast(:post_created) #Programado
  end

  @doc """
  Updates a post.

  ## Examples

      iex> update_post(post, %{field: new_value})
      {:ok, %Post{}}

      iex> update_post(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_post(%Post{} = post, attrs) do
    {:ok, post} = post |> Post.changeset(attrs) |> Repo.update()

    user = Repo.get(User, post.user_id)
    post = Map.merge(post, %{user: user})

    {:ok, post} |> broadcast(:post_updated) #Programado
  end

  @doc """
  Deletes a post.

  ## Examples

      iex> delete_post(post)
      {:ok, %Post{}}

      iex> delete_post(post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post(%Post{} = post) do
    Repo.delete(post)
    |> broadcast(:post_deleted) #Programado
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{data: %Post{}}

  """
  def change_post(%Post{} = post, attrs \\ %{}) do
    Post.changeset(post, attrs)
  end

  # programado
    def inc_likes(%Post{id: id}) do
      {1, [[post, user]]} =
        from(p in Post, join: u in User, on: p.user_id == u.id, where: p.id == ^id, select: [p,u])
        |> Repo.update_all(inc: [likes_count: 1])

      post = Map.merge(post, %{user: user})
      broadcast({:ok, post}, :post_updated)
    end

    def inc_reposts(%Post{id: id}) do
      {1, [[post, user]]} =
        from(p in Post, join: u in User, on: p.user_id == u.id, where: p.id == ^id, select: [p,u])
        |> Repo.update_all(inc: [reposts_count: 1])

      post = Map.merge(post, %{user: user})
      broadcast({:ok, post}, :post_updated)
    end

    def subscribe do
      Phoenix.PubSub.subscribe(Pfu.PubSub, "posts")
    end

    defp broadcast({:error, _reason} = error, _event), do: error

    defp broadcast({:ok, post}, event) do
      Phoenix.PubSub.broadcast(Pfu.PubSub, "posts", {event, post})
      {:ok, post}
    end
    #End Programado

end
