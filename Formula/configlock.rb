class Configlock < Formula
  desc "Lock config files during work hours using system-level immutable flags"
  homepage "https://github.com/baggiiiie/configlock"
  version "0.0.3"
  license "MIT"

  on_macos do
    on_intel do
      url "https://github.com/baggiiiie/configlock/releases/download/v0.0.3/configlock-darwin-amd64"
      sha256 "fb0ac2e1553f9ae5e3ced705504787f4f54dfe74bfc461ba426500a51263012a"
    end
    on_arm do
      url "https://github.com/baggiiiie/configlock/releases/download/v0.0.3/configlock-darwin-arm64"
      sha256 "0eafc42f66434801212f283b11df141a79e7f3360fb368ad2b9426528d1af770"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/baggiiiie/configlock/releases/download/v0.0.3/configlock-linux-amd64"
      sha256 "8e0a1ab2e1deab409cf0fb1ea9fc5a11dffff26c83560632a646e92b24837f56"
    end
    on_arm do
      url "https://github.com/baggiiiie/configlock/releases/download/v0.0.3/configlock-linux-arm64"
      sha256 "15c70322b795de9b35a2bafd2b6d98532961cba3325bc7fc7dc012c83ddd642a"
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
