class Jw < Formula
  desc "Description for jw"
  homepage "https://github.com/baggiiiie/jw"
  version "0.0.1"
  license "MIT"

  on_macos do
    on_intel do
      url "https://github.com/baggiiiie/jw/releases/download/v0.0.1/jw-darwin-amd64"
      sha256 "13ed9f7c9a94e06f6cd52e57d8ebb86d9fa51395aeb2fb3dc90bcdc9cd864116"
    end
    on_arm do
      url "https://github.com/baggiiiie/jw/releases/download/v0.0.1/jw-darwin-arm64"
      sha256 "5076a5ea16ceb840cd517b90be7d1b022350eda0038ccfcacb4db5f2f3e135fd"
    end
  end

  def install
    binary_name = stable.url.split("/").last
    bin.install binary_name => "jw"
  end

  test do
    system "#{bin}/jw", "--version"
  end
end
