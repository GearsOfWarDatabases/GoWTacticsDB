source "https://rubygems.org"

gem "github-pages", group: :jekyll_plugins

group :jekyll_plugins do
  gem "jekyll-feed", "~> 0.17"
  # Silences "To use retry middleware with Faraday v2.0+, install
  # `faraday-retry` gem" on every `jekyll serve`/`jekyll build` - jekyll-
  # github-metadata (pulled in by the github-pages gem above) talks to the
  # GitHub API via Octokit, which uses Faraday 2.x; Faraday split its retry
  # middleware into this separate gem starting at 2.0, and nothing in the
  # github-pages bundle pulls it in on its own. Purely additive - doesn't
  # change any existing gem's resolved version.
  gem "faraday-retry"
end

platforms :windows, :jruby do
  gem "tzinfo", ">= 1.2", "< 3"
  gem "tzinfo-data"
end

gem "wdm", "~> 0.2.0", platforms: [:windows]
gem "webrick", "~> 1.8"
