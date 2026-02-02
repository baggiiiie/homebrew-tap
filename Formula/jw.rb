class Jw < Formula
  desc "Description for jw"
  homepage "https://github.com/baggiiiie/jw"
  version "0.0.3"
  license "MIT"

  depends_on "terminal-notifier"

  on_macos do
    on_intel do
      url "https://github.com/baggiiiie/jw/releases/download/v0.0.3/jw-darwin-amd64"
      sha256 "3db026c1ab220241e2a4bc1bcda44d730526605a6db16f4e30cd69bb2ed2ebf3"
    end
    on_arm do
      url "https://github.com/baggiiiie/jw/releases/download/v0.0.3/jw-darwin-arm64"
      sha256 "e496205768eee92cf5eaae04b169ce57f8883e05a7abeeb4e2228a97d7d10a91"
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
