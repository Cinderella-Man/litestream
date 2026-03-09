defmodule Litestream.Strategy.ObjectStorage do
  @moduledoc """
  Use this strategy for backing up your SQLite DB file to an object
  store like AWS S3, Digital Ocean Spaces, Tigris, etc.
  """

  alias __MODULE__
  alias Litestream.Replicator

  @type t :: %ObjectStorage{
          type: String.t(),
          access_key_id: String.t(),
          secret_access_key: String.t(),
          endpoint: String.t(),
          bucket: String.t(),
          path: String.t(),
          region: String.t() | nil,
          force_path_style: boolean() | nil,
          skip_verify: boolean() | nil,
          concurrency: pos_integer() | nil,
          part_size: String.t() | nil
        }

  defstruct [
    :access_key_id,
    :secret_access_key,
    :endpoint,
    :bucket,
    :path,
    :region,
    :force_path_style,
    :skip_verify,
    :concurrency,
    :part_size,
    type: "s3"
  ]

  defimpl Replicator do
    def env_vars(%ObjectStorage{access_key_id: access_key_id, secret_access_key: secret_access_key}) do
      [
        {"LITESTREAM_ACCESS_KEY_ID", access_key_id},
        {"LITESTREAM_SECRET_ACCESS_KEY", secret_access_key}
      ]
    end

    def cli_args(%ObjectStorage{} = config, database) do
      args = [
        "-type", "s3",
        "-bucket", config.bucket,
        "-path", config.path,
        "-endpoint", config.endpoint
      ]

      args = if config.region, do: args ++ ["-region", config.region], else: args
      args = if config.force_path_style, do: args ++ ["-force-path-style"], else: args
      args = if config.skip_verify, do: args ++ ["-skip-verify"], else: args
      args = if config.concurrency, do: args ++ ["-concurrency", to_string(config.concurrency)], else: args
      args = if config.part_size, do: args ++ ["-part-size", config.part_size], else: args

      [database | args]
    end
  end
end
