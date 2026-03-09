defprotocol Litestream.Replicator do
  @moduledoc """
  This protocol defines what functions a strategy struct must
  implement.
  """

  @doc """
  This function should return a list of tuples where the first element in the
  tuple is the environment variable that will be passed to the Litestream process
  and the second element in the tuple is the value for the environment variable.
  """
  @spec env_vars(struct :: t()) :: list({env_var :: String.t(), value :: String.t()})
  def env_vars(struct)

  @doc """
  This function should create a list of CLI arguments that are passed to the
  Litestream binary. Only used when `config_yaml/2` returns `nil`.
  """
  @spec cli_args(struct :: t(), database :: String.t()) :: list(args :: String.t())
  def cli_args(struct, database)

  @doc """
  This function should return a YAML config string for strategies that require
  a config file (e.g. S3-compatible endpoints with options not available on the
  CLI), or `nil` if the strategy can be fully expressed via CLI arguments.
  """
  @spec config_yaml(struct :: t(), database :: String.t()) :: String.t() | nil
  def config_yaml(struct, database)
end
