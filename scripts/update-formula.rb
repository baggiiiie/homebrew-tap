#!/usr/bin/env ruby
require 'json'
require 'net/http'
require 'uri'
require 'digest'

# Parse arguments
formula_name = ARGV[0]
version = ARGV[1]
repo = ARGV[2]

if formula_name.nil? || version.nil? || repo.nil?
  puts "Usage: #{$0} <formula-name> <version> <repo>"
  puts "Example: #{$0} configlock 0.0.2 baggiiiie/configlock"
  exit 1
end

# Map platform-arch to Homebrew conditions
PLATFORM_MAP = {
  'darwin-arm64' => { os: 'macos', arch: 'arm' },
  'darwin-amd64' => { os: 'macos', arch: 'intel' },
  'linux-arm64' => { os: 'linux', arch: 'arm' },
  'linux-amd64' => { os: 'linux', arch: 'intel' }
}

def fetch_release_assets(repo, version)
  url = URI("https://api.github.com/repos/#{repo}/releases/tags/v#{version}")
  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true

  request = Net::HTTP::Get.new(url)
  request['Accept'] = 'application/vnd.github.v3+json'
  request['User-Agent'] = 'Homebrew-Formula-Generator'

  # Use GitHub token if available
  if ENV['GITHUB_TOKEN']
    request['Authorization'] = "token #{ENV['GITHUB_TOKEN']}"
  end

  response = http.request(request)

  unless response.is_a?(Net::HTTPSuccess)
    puts "Error fetching release: #{response.code} #{response.message}"
    exit 1
  end

  JSON.parse(response.body)['assets']
end

def calculate_sha256(url, redirect_limit = 10)
  raise "Too many redirects" if redirect_limit == 0

  uri = URI(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  request = Net::HTTP::Get.new(uri)
  request['User-Agent'] = 'Homebrew-Formula-Generator'

  response = http.request(request)

  case response
  when Net::HTTPSuccess
    Digest::SHA256.hexdigest(response.body)
  when Net::HTTPRedirection
    calculate_sha256(response['location'], redirect_limit - 1)
  else
    puts "Error downloading #{url}: #{response.code}"
    nil
  end
end

def read_formula_metadata(formula_path)
  return nil unless File.exist?(formula_path)

  content = File.read(formula_path)
  metadata = {}

  metadata[:desc] = content[/desc\s+"([^"]+)"/, 1]
  metadata[:homepage] = content[/homepage\s+"([^"]+)"/, 1]
  metadata[:license] = content[/license\s+"([^"]+)"/, 1]

  metadata
end

def generate_formula(formula_name, version, repo, binaries, metadata)
  class_name = formula_name.split('-').map(&:capitalize).join

  formula = <<~RUBY
    class #{class_name} < Formula
      desc "#{metadata[:desc] || "Description for #{formula_name}"}"
      homepage "#{metadata[:homepage] || "https://github.com/#{repo}"}"
      version "#{version}"
      license "#{metadata[:license] || "MIT"}"
  RUBY

  # Group binaries by OS
  os_groups = binaries.group_by { |b| PLATFORM_MAP[b[:platform]][:os] }

  os_groups.each do |os, os_binaries|
    formula << "\n  on_#{os} do\n"

    os_binaries.each do |binary|
      arch = PLATFORM_MAP[binary[:platform]][:arch]
      formula << "    on_#{arch} do\n"
      formula << "      url \"#{binary[:url]}\"\n"
      formula << "      sha256 \"#{binary[:sha256]}\"\n"
      formula << "    end\n"
    end

    formula << "  end\n"
  end

  formula << <<~RUBY

      def install
        binary_name = stable.url.split("/").last
        bin.install binary_name => "#{formula_name}"
      end

      test do
        system "\#{bin}/#{formula_name}", "--version"
      end
    end
  RUBY

  formula
end

# Main execution
puts "Fetching release assets for #{repo} v#{version}..."
assets = fetch_release_assets(repo, version)

# Filter assets matching formula name pattern
formula_assets = assets.select { |asset|
  asset['name'].start_with?("#{formula_name}-") &&
  PLATFORM_MAP.keys.any? { |platform| asset['name'].end_with?(platform) }
}

if formula_assets.empty?
  puts "Error: No matching binaries found for #{formula_name}"
  puts "Available assets: #{assets.map { |a| a['name'] }.join(', ')}"
  exit 1
end

puts "Found #{formula_assets.length} binaries:"
formula_assets.each { |a| puts "  - #{a['name']}" }

# Calculate SHA256 for each binary
binaries = []
formula_assets.each do |asset|
  platform = PLATFORM_MAP.keys.find { |p| asset['name'].end_with?(p) }

  puts "Calculating SHA256 for #{asset['name']}..."
  sha256 = calculate_sha256(asset['browser_download_url'])

  if sha256.nil?
    puts "Error: Failed to calculate SHA256 for #{asset['name']}"
    exit 1
  end

  binaries << {
    platform: platform,
    url: "https://github.com/#{repo}/releases/download/v#{version}/#{asset['name']}",
    sha256: sha256
  }

  puts "  ✓ #{sha256}"
end

# Read existing metadata if formula exists
formula_path = File.join(__dir__, '..', 'Formula', "#{formula_name}.rb")
metadata = read_formula_metadata(formula_path) || {}

# Generate formula
puts "\nGenerating formula..."
formula_content = generate_formula(formula_name, version, repo, binaries, metadata)

# Write formula file
File.write(formula_path, formula_content)
puts "✓ Formula written to #{formula_path}"

puts "\nFormula update complete!"
