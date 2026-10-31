# Backs the "Last updated" banner in the header (_includes/header.html)
# with the last actual GIT COMMIT's own info - hash, timestamp, branch -
# not just whenever `jekyll build`/`jekyll serve` happened to run
# (Jekyll's built-in site.time). A rebuild triggered with no real content
# change (re-running the deploy workflow by hand, a dependency-cache
# warm-up, etc.) would otherwise print a timestamp with nothing to do with
# when the site's actual content last changed.
#
# Works identically in local dev and in CI: actions/checkout@v4 (see
# .github/workflows/deploy.yml) defaults to a shallow, depth-1 clone,
# which is all `git log -1` ever needs anyway. Falls back to leaving
# site.last_commit_* unset (header.html then falls back further, see its
# own comment) if `git log`/`git rev-parse` fails for any reason - e.g.
# building from a source tarball with no .git directory at all - so a
# missing commit info never breaks the build.
#
# Branch: actions/checkout@v4 leaves the repo in a DETACHED HEAD state (it
# checks out a specific commit, not a branch), so `git rev-parse
# --abbrev-ref HEAD` would print "HEAD" there instead of the real branch
# name. GitHub Actions exposes the real one via the GITHUB_REF_NAME env
# var, so that's preferred when present; git rev-parse is the local-dev
# fallback, where you're actually on a real branch.
#
# Implemented as a Jekyll::Generator (same mechanism jekyll-feed uses)
# rather than a Jekyll::Hooks.register callback. On at least one local
# Windows dev setup (Jekyll 3.10, `bundle exec jekyll serve`/`build`),
# Jekyll::Hooks.register(:site, ...) blocks silently never fired under the
# real `jekyll` CLI commands - confirmed by direct A/B test: an identical
# Jekyll::Site.new call in a standalone script fired the hook fine, but
# `bundle exec jekyll build` never did, while jekyll-feed's Generator-based
# plugin worked correctly in that same `jekyll build` run. Generators are
# simpler and more fundamental (Jekyll::Site#generate just instantiates
# every loaded Jekyll::Generator subclass and calls #generate on it - no
# separate event-registration/trigger step to go missing), so this
# sidesteps whatever was wrong with Hooks there. Uses `priority :highest`
# so this runs before any other generator that might read these values.
#
# Belt and suspenders: on the specific machine where even this Generator
# form turned out not to help (root cause never fully pinned down),
# ref/start-jekyll.bat now writes the same git info straight to
# _data/last_commit.yml before every local `jekyll serve`, and
# _includes/header.html checks that data file first, this plugin's values
# second, and falls back to build time last. So this file is still what
# drives the banner in CI/production (see .github/workflows/deploy.yml -
# plain `bundle exec jekyll build` on ubuntu-latest, no known issue
# there), just no longer the only thing standing between local dev and a
# silent build-time fallback.
require 'open3'

module GearsDatabase
  class LastCommitGenerator < Jekyll::Generator
    priority :highest

    def generate(site)
      source = site.source

      time = git_output(source, 'log', '-1', '--format=%cI')
      site.config['last_commit_time'] = time if time

      hash = git_output(source, 'log', '-1', '--format=%h')
      site.config['last_commit_hash'] = hash if hash

      branch = ENV['GITHUB_REF_NAME'] || git_output(source, 'rev-parse', '--abbrev-ref', 'HEAD')
      site.config['last_commit_branch'] = branch if branch && branch != 'HEAD'

      # Host OS tag - inspired by AzerothCore's own revision line, which
      # ends with a platform tag ("Win64, RelWithDebInfo, Dynamic") sourced
      # from a compile-time macro, not git, so it still prints even in AC's
      # own non-git/source-tarball fallback (unknown hash, "Archived"
      # branch). Deliberately set OUTSIDE and independent of the
      # git_output calls above for the same reason - this should still
      # show up even when the site is built from a plain downloaded/
      # extracted copy with no .git directory at all, not just when hash/
      # branch above succeeded. Named "Windows"/"Mac"/"Unix" rather than
      # AC's own literal Win64/Win32/Unix - no 32-vs-64-bit distinction
      # (this isn't compiled software, so it isn't a meaningful build
      # detail here), and Mac gets its own label instead of folding into
      # "Unix" with Linux/BSD.
      site.config['host_os'] = host_os_tag

      # Built by GitHub Actions for GitHub Pages: the revision line moves from the header's top left corner to the
      # footer ("Hosted on GitHub Pages."), with the hash linking to the commit on GitHub. Local and self-hosted
      # builds (no GITHUB_ACTIONS) keep the top left corner. GITHUB_SHA / GITHUB_REPOSITORY / GITHUB_SERVER_URL are
      # set by Actions for every job.
      site.config['github_pages_build'] = ENV['GITHUB_ACTIONS'] == 'true'
      sha = ENV['GITHUB_SHA'] || git_output(source, 'log', '-1', '--format=%H')
      site.config['last_commit_sha'] = sha if sha
      if ENV['GITHUB_REPOSITORY']
        server = ENV['GITHUB_SERVER_URL'] || 'https://github.com'
        site.config['repository_url'] = "#{server}/#{ENV['GITHUB_REPOSITORY']}"
      end
    end

    private

    # Ruby's RbConfig::CONFIG['host_os'] is a free-form string from the
    # platform Ruby itself was built for (e.g. "mingw32", "x64-mingw-ucrt",
    # "linux-gnu", "darwin21") - collapsed down to a plain 3-way label.
    def host_os_tag
      os = RbConfig::CONFIG['host_os'].to_s.downcase

      if os.match?(/mingw|mswin|cygwin/)
        'Windows'
      elsif os.match?(/darwin|mac os/)
        'Mac'
      else
        'Unix'
      end
    end

    # Runs one git command, returns its trimmed stdout on success or nil on
    # any failure - logging exactly why once per distinct failure reason,
    # instead of silently leaving the header to fall further down its own
    # fallback chain with no trace of what went wrong.
    def git_output(source, *args)
      stdout, stderr, status = Open3.capture3('git', '-C', source, *args)

      if status.success? && !stdout.strip.empty?
        return stdout.strip
      end

      reason = stderr.strip
      reason = "git exited with status #{status.exitstatus}, no error output" if reason.empty?
      Jekyll.logger.warn 'last_commit.rb:', "`git #{args.join(' ')}` failed - " \
        "the header banner will fall back further instead. #{reason}"
      nil
    rescue Errno::ENOENT
      # git itself isn't on PATH for whatever process ran `jekyll serve`/`jekyll build`
      # (common on Windows when Jekyll is launched from a shell/IDE task that doesn't
      # inherit the PATH your normal terminal has Git for Windows on).
      Jekyll.logger.warn 'last_commit.rb:', '"git" was not found on PATH for this process, ' \
        'so the header banner will fall back further instead. Make sure git is on the PATH ' \
        'available to whatever launched Jekyll (not just your normal terminal).'
      nil
    rescue StandardError => e
      Jekyll.logger.warn 'last_commit.rb:', "`git #{args.join(' ')}` failed - " \
        "the header banner will fall back further instead. #{e.class}: #{e.message}"
      nil
    end
  end
end
