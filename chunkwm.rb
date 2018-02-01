class Chunkwm < Formula
  desc "Tiling window manager for macOS based on plugin architecture"
  homepage "https://github.com/koekeishiya/chunkwm"
  url "https://github.com/koekeishiya/chunkwm/archive/v0.3.2.tar.gz"
  sha256 "6c56e6c8cf29113b517c9601bd0328f9d65dd68b9d313ce94dfba1ac2c24f581"
  head "https://github.com/koekeishiya/chunkwm.git"

  option "without-tiling", "Do not build tiling plugin."
  option "without-ffm", "Do not build focus-follow-mouse plugin."
  option "without-border", "Do not build border plugin."
  option "with-purify", "Build purify plugin."
  option "with-logging", "Redirect stdout and stderr to log files to standard brew path"
  option "with-tmp-logging", "Redirect stdout and stderr to /tmp"

  depends_on :macos => :el_capitan

  def install
    (var/"log/chunkwm").mkpath
    system "make", "install"
    inreplace "#{buildpath}/examples/chunkwmrc", "~/.chunkwm_plugins", "#{opt_pkgshare}/plugins"
    bin.install "#{buildpath}/bin/chunkwm"
    (pkgshare/"examples").install "#{buildpath}/examples/chunkwmrc"

    system "make", "--directory", "src/chunkc"
    bin.install "#{buildpath}/src/chunkc/bin/chunkc"

    if build.with? "tiling"
      system "make", "install", "--directory", "src/plugins/tiling"
      (pkgshare/"plugins").install "#{buildpath}/plugins/tiling.so"
      (pkgshare/"examples").install "#{buildpath}/src/plugins/tiling/examples/khdrc"
    end

    if build.with? "ffm"
      system "make", "install", "--directory", "src/plugins/ffm"
      (pkgshare/"plugins").install "#{buildpath}/plugins/ffm.so"
    end

    if build.with? "border"
      system "make", "install", "--directory", "src/plugins/border"
      (pkgshare/"plugins").install "#{buildpath}/plugins/border.so"
    end

    if build.with? "purify"
      system "make", "install", "--directory", "src/plugins/purify"
      (pkgshare/"plugins").install "#{buildpath}/plugins/purify.so"
    end
  end

  def caveats; <<~EOS
    Copy the example configuration into your home directory:
      cp #{opt_pkgshare}/examples/chunkwmrc ~/.chunkwmrc

    Opening chunkwm will prompt for Accessibility API permissions. After access
    has been granted, the application must be restarted.
      brew services restart chunkwm

    This has to be done after every update to chunkwm, unless you codesign the
    binary with self-signed certificate before restarting
      Create code signing certificate named "chunkwm-cert" using Keychain Access.app
      codesign -fs "chunkwm-cert" #{opt_bin}/chunkwm

    If the formula has been built with --with-logging, logs will be found in
      #{var}/log/chunkwm/chunkwm.[out|err].log
  
    If the formula has been built with --with-tmp-logging, logs will be found in
      /tmp/chunkwm.[out|err].log

    NOTE: plugins folder has been moved to #{opt_pkgshare}/plugins
    EOS
  end

  plist_options :manual => "chunkwm"

  if build.with? "logging"
    def plist; <<~EOS
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_bin}/chunkwm</string>
        </array>
        <key>EnvironmentVariables</key>
        <dict>
          <key>PATH</key>
          <string>#{HOMEBREW_PREFIX}/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
        </dict>
        <key>RunAtLoad</key>
        <true/>
        <key>KeepAlive</key>
        <true/>
        <key>StandardOutPath</key>
        <string>#{var}/log/chunkwm/chunkwm.out.log</string>
        <key>StandardErrorPath</key>
        <string>#{var}/log/chunkwm/chunkwm.err.log</string>
      </dict>
      </plist>
      EOS
    end
  elsif build.with? "tmp-logging"
    def plist; <<~EOS
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_bin}/chunkwm</string>
        </array>
        <key>EnvironmentVariables</key>
        <dict>
          <key>PATH</key>
          <string>#{HOMEBREW_PREFIX}/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
        </dict>
        <key>RunAtLoad</key>
        <true/>
        <key>KeepAlive</key>
        <true/>
        <key>StandardOutPath</key>
        <string>/tmp/chunkwm.out.log</string>
        <key>StandardErrorPath</key>
        <string>/tmp/chunkwm.err.log</string>
      </dict>
      </plist>
      EOS
    end
  else
    def plist; <<~EOS
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_bin}/chunkwm</string>
        </array>
        <key>EnvironmentVariables</key>
        <dict>
          <key>PATH</key>
          <string>#{HOMEBREW_PREFIX}/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
        </dict>
        <key>RunAtLoad</key>
        <true/>
        <key>KeepAlive</key>
        <true/>
      </dict>
      </plist>
      EOS
    end
  end

  test do
    assert_match "chunkwm #{version}", shell_output("#{bin}/chunkwm --version")
  end
end
