defmodule Litestream.Downloader do
  @moduledoc """
  This module is used to download the built Litestream binaries.
  """

  use OctoFetch,
    latest_version: "0.5.8",
    github_repo: "benbjohnson/litestream",
    download_versions: %{
      "0.5.9" => [
        {:darwin, :arm64, "1ccff96084d3e0faf4f8fabd22931fd774718f43b920480c48cbf366a558146d"},
        {:darwin, :x86_64, "61750da940ba00dce5a582fc549848754270acc6dca7643a8afea5cf32d45e9d"},
        {:linux, :arm64, "330e290f98ecf00ac3b8b2e2f038d81ada2712da86a9466d3187f02ded269821"},
        {:linux, :armv6, "580ea703e76f8db153e1f16a61dbf0acb44961afc6d48f64681dff53bbd96c97"},
        {:linux, :armv7, "f15d159cc8e6bd7bcb7143ef19afd87e70bb80aaf5f321374b89f6d08834250d"},
        {:linux, :x86_64, "e8612ef5424802723e8cfa2d07a182df60f9af71839b5ff5ef1e80dff38efbdd"}
      ]
    }

  @impl true
  def pre_download_hook(_file, output_dir) do
    output_binary = Path.join(output_dir, "litestream")

    if File.exists?(output_binary) do
      {:skip, output_binary}
    else
      :cont
    end
  end

  @impl true
  def post_write_hook(file) do
    if String.ends_with?(file, "litestream") do
      File.chmod!(file, 0o755)
    else
      File.rm!(file)
    end

    :ok
  end

  @impl true
  def download_name(version, os, "amd64"), do: "litestream-#{version}-#{os}-x84_64.tar.gz"
  def download_name(version, os, arch), do: "litestream-#{version}-#{os}-#{arch}.tar.gz"
end
