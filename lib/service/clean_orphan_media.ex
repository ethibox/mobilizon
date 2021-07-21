defmodule Mobilizon.Service.CleanOrphanMedia do
  @moduledoc """
  Service to clean orphan media
  """

  alias Mobilizon.Actors.Actor
  alias Mobilizon.Medias
  alias Mobilizon.Medias.Media
  alias Mobilizon.Storage.Repo
  import Ecto.Query

  @doc """
  Clean orphan media

  Remove media that is not attached to an entity, such as media uploads that were never used in entities.

  Options:
   * `grace_period` how old in hours can the media be before it's taken into account for deletion
   * `dry_run` just return the media that would have been deleted, don't actually delete it
  """
  @spec clean(Keyword.t()) :: {:ok, list(Media.t())} | {:error, String.t()}
  def clean(opts \\ []) do
    medias = find_media(opts)

    if Keyword.get(opts, :dry_run, false) do
      {:ok, medias}
    else
      Enum.each(medias, fn media ->
        Medias.delete_media(media, ignore_file_not_found: true)
      end)

      {:ok, medias}
    end
  end

  # Ecto doesn't currently allow us to use exists with a subquery,
  # so we can't create the union through Ecto
  # https://github.com/elixir-ecto/ecto/issues/3619
  @union_query [
                 [from: "events", param: "picture_id"],
                 [from: "events_medias", param: "media_id"],
                 [from: "posts", param: "picture_id"],
                 [from: "posts_medias", param: "media_id"],
                 [from: "comments_medias", param: "media_id"]
               ]
               |> Enum.map(fn [from: from, param: param] ->
                 "SELECT 1 FROM #{from} WHERE #{from}.#{param} = m0.id"
               end)
               |> Enum.join(" UNION ")
               |> (&"NOT EXISTS(#{&1})").()

  @spec find_media(Keyword.t()) :: list(Media.t())
  defp find_media(opts) do
    default_grace_period =
      Mobilizon.Config.get([:instance, :orphan_upload_grace_period_hours], 48)

    grace_period = Keyword.get(opts, :grace_period, default_grace_period)
    expiration_date = DateTime.add(DateTime.utc_now(), grace_period * -3600)

    query =
      from(m in Media,
        as: :media,
        distinct: true,
        join: a in Actor,
        on: a.id == m.actor_id,
        where: is_nil(a.domain),
        where: m.inserted_at < ^expiration_date,
        where: fragment(@union_query)
      )

    Repo.all(query)
  end
end
