class Configlock < Formula
  desc "Lock config files during work hours using system-level immutable flags"
  homepage "https://github.com/baggiiiie/configlock"
  version "0.0.1"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/baggiiiie/configlock/releases/download/v#{version}/configlock-darwin-arm64"
      sha256 "54008efce3dcc89a181535da6ab96cefa8141db2eca09755905defed9843af73"
    end
    on_intel do
      url "https://github.com/baggiiiie/configlock/releases/download/v#{version}/configlock-darwin-amd64"
      sha256 "cff0c36b2aa6849f54b8666202daa0ed75917650651fd71799a44cadb74cb0ac"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/baggiiiie/configlock/releases/download/v#{version}/configlock-linux-arm64"
      sha256 "86f3523ac898b798ef5c2e24229cde9d6770cd16ab0b1b95b8215fa043201479"
    end
    on_intel do
      url "https://github.com/baggiiiie/configlock/releases/download/v#{version}/configlock-linux-amd64"
      sha256 "f61260e07c377601e86e1a9e827761a063b27528e751b20af3a24e6d92e30aa4"
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
