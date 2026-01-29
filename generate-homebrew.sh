#!/bin/bash
set -e

# ============================================================================
# Homebrew Tap Generator
# ============================================================================
#
# BEFORE RUNNING THIS SCRIPT:
#
# 1. Create a GitHub release with binaries attached:
#    gh release create v0.0.1 --generate-notes --title "v0.0.1"
#    (GitHub Actions will build and attach binaries automatically)
#
# 2. Wait for GitHub Actions to complete and verify all 4 binaries exist:
#    - darwin-arm64
#    - darwin-amd64
#    - linux-arm64
#    - linux-amd64
#
# 3. Create a new GitHub repo named "homebrew-tap" under your account:
#    gh repo create baggiiiie/homebrew-tap --public --clone
#
# 4. Run this script from within homebrew-tap directory:
#    cd homebrew-tap
#    ./generate-homebrew.sh <repo-name> <version>
#
# 5. After running, commit and push:
#    git add -A && git commit -m "Add formula v0.0.1" && git push
#
# 6. Users can then install with:
#    brew tap baggiiiie/tap
#    brew install tool
#
# ============================================================================

REPO_NAME="$1"
VERSION="${2:-0.0.1}"
GITHUB_USER="baggiiiie"
TAP_DIR="."
BASE_URL="https://github.com/${GITHUB_USER}/${REPO_NAME}/releases/download/v${VERSION}"
if [[ -z $REPO_NAME ]]; then
    echo "repo name is not set!"
    exit
fi

echo "Homebrew Tap Generator"
echo "===================================="
echo "Repository: ${REPO_NAME}"
echo "Version: ${VERSION}"
echo "GitHub User: ${GITHUB_USER}"
echo ""

# Check if release exists
echo "Checking if release v${VERSION} exists..."
RELEASE_CHECK_URL="https://github.com/${GITHUB_USER}/${REPO_NAME}/releases/tag/v${VERSION}"
RELEASE_HTTP_CODE=$(curl -sL -o /dev/null -w "%{http_code}" "${RELEASE_CHECK_URL}")

if [ "${RELEASE_HTTP_CODE}" != "200" ]; then
    echo ""
    echo "Error: Release v${VERSION} not found at ${REPO_NAME}"
    echo "HTTP Status: ${RELEASE_HTTP_CODE}"
    echo ""
    echo "Please create the release first:"
    echo "  cd /path/to/${REPO_NAME}"
    echo "  gh release create v${VERSION} --generate-notes --title \"v${VERSION}\""
    echo ""
    echo "Then wait for GitHub Actions to build and attach the binaries:"
    echo "  - ${REPO_NAME}-darwin-arm64"
    echo "  - ${REPO_NAME}-darwin-amd64"
    echo "  - ${REPO_NAME}-linux-arm64"
    echo "  - ${REPO_NAME}-linux-amd64"
    echo ""
    exit 1
fi

echo "Release found!"
echo ""
echo "Fetching SHA256 checksums..."
echo ""

fetch_sha() {
    local binary="$1"
    local url="${BASE_URL}/${binary}"

    HTTP_CODE=$(curl -sL -o /dev/null -w "%{http_code}" "${url}")
    if [ "${HTTP_CODE}" != "200" ]; then
        echo "NOT FOUND (HTTP ${HTTP_CODE})"
        echo ""
        echo "Error: Binary not found at ${url}"
        echo "Make sure the release exists and has all binaries attached."
        exit 1
    fi

    curl -sL "${url}" | shasum -a 256 | awk '{print $1}'
}

echo -n "  darwin-arm64: "
SHA_DARWIN_ARM64=$(fetch_sha "${REPO_NAME}-darwin-arm64")
echo "${SHA_DARWIN_ARM64}"

echo -n "  darwin-amd64: "
SHA_DARWIN_AMD64=$(fetch_sha "${REPO_NAME}-darwin-amd64")
echo "${SHA_DARWIN_AMD64}"

echo -n "  linux-arm64: "
SHA_LINUX_ARM64=$(fetch_sha "${REPO_NAME}-linux-arm64")
echo "${SHA_LINUX_ARM64}"

echo -n "  linux-amd64: "
SHA_LINUX_AMD64=$(fetch_sha "${REPO_NAME}-linux-amd64")
echo "${SHA_LINUX_AMD64}"

echo ""
echo "Generating Formula/$REPO_NAME.rb..."

cat >"${TAP_DIR}/Formula/$REPO_NAME.rb" <<EOF
class ${REPO_NAME} < Formula
  desc "Lock ${REPO_NAME} files during work hours using system-level immutable flags"
  homepage "https://github.com/${GITHUB_USER}/${REPO_NAME}"
  version "${VERSION}"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/${GITHUB_USER}/${REPO_NAME}/releases/download/v#{version}/${REPO_NAME}-darwin-arm64"
      sha256 "${SHA_DARWIN_ARM64}"
    end
    on_intel do
      url "https://github.com/${GITHUB_USER}/${REPO_NAME}/releases/download/v#{version}/${REPO_NAME}-darwin-amd64"
      sha256 "${SHA_DARWIN_AMD64}"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/${GITHUB_USER}/${REPO_NAME}/releases/download/v#{version}/${REPO_NAME}-linux-arm64"
      sha256 "${SHA_LINUX_ARM64}"
    end
    on_intel do
      url "https://github.com/${GITHUB_USER}/${REPO_NAME}/releases/download/v#{version}/${REPO_NAME}-linux-amd64"
      sha256 "${SHA_LINUX_AMD64}"
    end
  end

  def install
    binary_name = stable.url.split("/").last
    bin.install binary_name => "${REPO_NAME}"
  end

  test do
    system "#{bin}/${REPO_NAME}", "--version"
  end
end
EOF

echo "Formula created at ${TAP_DIR}/Formula/$REPO_NAME.rb"
echo ""
echo "Next steps:"
echo ""
echo "  git add -A"
echo "  git commit -m \"Add $REPO_NAME formula v${VERSION}\""
echo "  git push"
echo ""
echo "Then users can install with:"
echo ""
echo "  brew tap ${GITHUB_USER}/tap"
echo "  brew install ${REPO_NAME}"
echo ""
