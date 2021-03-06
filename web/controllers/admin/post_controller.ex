defmodule Changelog.Admin.PostController do
  use Changelog.Web, :controller

  alias Changelog.Post

  plug :scrub_params, "post" when action in [:create, :update]

  def index(conn, params) do
    page = Post
    |> order_by([p], desc: p.published_at)
    |> preload(:author)
    |> Repo.paginate(params)

    render conn, :index, posts: page.entries, page: page
  end

  def new(conn, _params) do
    changeset = Post.changeset(%Post{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, params = %{"post" => post_params}) do
    changeset = Post.changeset(%Post{}, post_params)

    case Repo.insert(changeset) do
      {:ok, post} ->
        conn
        |> put_flash(:result, "success")
        |> smart_redirect(post, params)
      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render("new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    post = Repo.get!(Post, id) |> Post.preload_all

    changeset = Post.changeset(post)
    render conn, "edit.html", post: post, changeset: changeset
  end

  def update(conn, params = %{"id" => id, "post" => post_params}) do
    post = Repo.get!(Post, id) |> Post.preload_all
    changeset = Post.changeset(post, post_params)

    case Repo.update(changeset) do
      {:ok, post} ->
        conn
        |> put_flash(:result, "success")
        |> smart_redirect(post, params)
      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render("edit.html", post: post, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    post = Repo.get!(Post, id)
    Repo.delete!(post)

    conn
    |> put_flash(:result, "success")
    |> redirect(to: admin_post_path(conn, :index))
  end

  defp smart_redirect(conn, _post, %{"close" => _true}) do
    redirect(conn, to: admin_post_path(conn, :index))
  end
  defp smart_redirect(conn, post, _params) do
    redirect(conn, to: admin_post_path(conn, :edit, post))
  end
end
