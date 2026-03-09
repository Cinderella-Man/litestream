defmodule Litestream.Strategy.ObjectStorage do
  @moduledoc """
  Use this strategy for backing up your SQLite DB file to an object
  store like AWS S3, Digital Ocean Spaces, Tigris, Cloudflare R2, etc.

  When no `:endpoint` is set (standard AWS S3), replication uses the simple
  CLI shorthand (`litestream replicate DB_PATH s3://bucket/path`) with
  credentials passed via environment variables.

  When an `:endpoint` is set (S3-compatible providers), a temporary YAML
  config file is generated because the Litestream CLI does not expose
  options like `endpoint`, `force-path-style`, or `skip-verify` as flags.
  """

  alias __MODULE__
  alias Litestream.Replicator

  @type t :: %ObjectStorage{
          type: String.t(),
          access_key_id: String.t(),
          secret_access_key: String.t(),
          endpoint: String.t() | nil,
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
    def env_vars(%ObjectStorage{endpoint: nil} = config) do
      env = [
        {"LITESTREAM_ACCESS_KEY_ID", config.access_key_id},
        {"LITESTREAM_SECRET_ACCESS_KEY", config.secret_access_key}
      ]

      if config.region do
        [{"AWS_DEFAULT_REGION", config.region} | env]
      else
        env
      end
    end

    def env_vars(%ObjectStorage{}) do
      []
    end

    def cli_args(%ObjectStorage{endpoint: nil} = config, database) do
      [database, "s3://#{config.bucket}/#{config.path}"]
    end

    def cli_args(%ObjectStorage{}, _database) do
      []
    end

    def config_yaml(%ObjectStorage{endpoint: nil}, _database) do
      nil
    end

    def config_yaml(%ObjectStorage{} = config, database) do
      optional_fields =
        [
          {"region", config.region},
          {"force-path-style", config.force_path_style},
          {"skip-verify", config.skip_verify},
          {"concurrency", config.concurrency},
          {"part-size", config.part_size}
        ]
        |> Enum.reject(fn {_key, val} -> is_nil(val) end)
        |> Enum.map(fn {key, val} -> "            #{key}: #{val}" end)

      replica_lines =
        [
          "          - type: #{config.type}",
          "            bucket: #{config.bucket}",
          "            path: #{config.path}",
          "            endpoint: #{config.endpoint}",
          "            access-key-id: #{config.access_key_id}",
          "            secret-access-key: #{config.secret_access_key}"
        ] ++ optional_fields

      """
      dbs:
        - path: #{database}
          replicas:
      #{Enum.join(replica_lines, "\n")}
      """
    end
  end
end
