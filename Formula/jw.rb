class Jw < Formula
  desc "Description for jw"
  homepage "https://github.com/baggiiiie/jw"
  version "0.0.2"
  license "MIT"

  depends_on "terminal-notifier"

  on_macos do
    on_intel do
      url "https://github.com/baggiiiie/jw/releases/download/v0.0.2/jw-darwin-amd64"
      sha256 "be149209dcd6ca0f37fba3fa839e105d42016089b690942f1f70337e0917bcd3"
    end
    on_arm do
      url "https://github.com/baggiiiie/jw/releases/download/v0.0.2/jw-darwin-arm64"
      sha256 "76bd539affc8f82c4189e35df6a60a04a1943dcb4ce07c2b275b74ae2146ae71"
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
