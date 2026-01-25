class Configlock < Formula
  desc "Lock config files during work hours using system-level immutable flags"
  homepage "https://github.com/baggiiiie/configlock"
  version "0.0.2"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/baggiiiie/configlock/releases/download/v#{version}/configlock-darwin-arm64"
      sha256 "2b8506ba3898b86f63736ad40e92df45f8eca24e9b47218edd395ed21266e8d6"
    end
    on_intel do
      url "https://github.com/baggiiiie/configlock/releases/download/v#{version}/configlock-darwin-amd64"
      sha256 "2e53858ce582d0552714cfc9712316bce8b07d646a744557f83ffd57066b54f9"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/baggiiiie/configlock/releases/download/v#{version}/configlock-linux-arm64"
      sha256 "775f9b7c02694cb62d8c937c6c434afd2b87f96fc0832188a6d914781f28dbd9"
    end
    on_intel do
      url "https://github.com/baggiiiie/configlock/releases/download/v#{version}/configlock-linux-amd64"
      sha256 "392df8f982cda4c5020379d172fa10c4c86bf2d486f541256f1e6af3e2c0d184"
    end
  end

  def install
    binary_name = stable.url.split("/").last
    bin.install binary_name => "configlock"
  end

  test do
    system "#{bin}/configlock", "--version"
  end
end
