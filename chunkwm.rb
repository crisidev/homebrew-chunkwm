class Chunkwm < Formula
  desc "Tiling window manager for MacOS based on plugin architecture"
  homepage "https://github.com/koekeishiya/chunkwm"
  url "https://github.com/koekeishiya/chunkwm/archive/v0.2.25.tar.gz"
  sha256 "ee2b6b90a5c53dc5812a1d3cc94b61594ec53a4b3462412426e5744599afcfa3"

  head do
    url "https://github.com/koekeishiya/chunkwm.git"
  end

  option "with-ffm", "Build focus-follow-mouse plugin."
  option "with-transparency", "Build transparency plugin."
  option "without-border", "Do not build border plugin."
  option "without-tiling", "Do not build tiling plugin."

  def install
    # create plugins and example directories
    (share/"chunkwm_plugins").mkpath
    (share/"examples").mkpath

    # install chunkwm
    system "make", "install"
    bin.install "#{buildpath}/bin/chunkwm"
    (share/"examples").install "#{buildpath}/examples/chunkwmrc"

    # install chunkc
    Dir.chdir("#{buildpath}/src/chunkc")
    system "make"
    bin.install "#{buildpath}/src/chunkc/bin/chunkc"

    # install tiling plugin
    if build.with? "tiling"
      Dir.chdir("#{buildpath}/src/plugins/tiling")
      system "make", "install"
      (share/"chunkwm_plugins").install "#{buildpath}/plugins/tiling.so"
      (share/"examples").install "#{buildpath}/src/plugins/tiling/examples/khdrc"
    end

    # install border plugin
    if build.with? "border"
      Dir.chdir("#{buildpath}/src/plugins/border")
      system "make", "install"
      (share/"chunkwm_plugins").install "#{buildpath}/plugins/border.so"
    end

    # install ffm plugin
    if build.with? "ffm"
      Dir.chdir("#{buildpath}/src/plugins/ffm")
      system "make", "install"
      (share/"chunkwm_plugins").install "#{buildpath}/plugins/ffm.so"
    end

    # install transparency plugin
    if build.with? "transparency"
      Dir.chdir("#{buildpath}/src/plugins/transparency")
      system "make", "install"
      (share/"chunkwm_plugins").install "#{buildpath}/plugins/transparency.so"
    end
  end

  def caveats; <<-EOS.undent
    # Chunkwm build with:
      * tiling: #{build.with? "tiling"}
      * border: #{build.with? "border"}
      * ffm: #{build.with? "ffm"}
      * transparency: #{build.with? "transparency"}

    # Installation Instructions:
      Copy the example configs from #{share}/examples into your home directory:
        cp #{share}/examples/chunkwmrc ~/.chunkwmrc

      Plugins are installed into #{share}/chunkwm_plugins folder.
      To allow plugins to load properly you have two possibilites:
        * Edit ~/.chunkwmrc and change line
            chunkc core::plugin_dir ~/.chunkwm_plugins
          into
            chunkc core::plugin_dir #{share}/chunkwm_plugins
        * Link plugins into your home directory
            ln -sf #{share}/chunkwm_plugins ~/.chunkwm_plugins

      The first time chunkwm-core is ran, it will request access to the accessibility API.
      After access has been granted, the application must be restarted.
      NOTE: accessibility API needs to be granted every time you upgrade chunkwm core.

      The chunkwm-tiling plugin requires 'displays have separate spaces' to be enabled.

      For keybindings install and configure https://github.com/koekeishiya/khd.
      Brew formula is available: brew install koekeishiya/formulae/khd

      Copy the khd example config from #{prefix}/khdrc into your home directory:
        cp #{share}/examples/khdrc ~/.khdrc
      EOS
  end

  plist_options :startup => false

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>com.koekeishiya.chunkwm</string>
      <key>ProgramArguments</key>
      <array>
            <string>#{bin}/chunkwm</string>
      </array>
        <key>EnvironmentVariables</key>
        <dict>
        <key>PATH</key>
        <string>/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
        </dict>
      <key>RunAtLoad</key>
      <true/>
      <key>KeepAlive</key>
      <true/>
        <key>StandardOutPath</key>
        <string>/tmp/chunkwm.out</string>
        <key>StandardErrorPath</key>
        <string>/tmp/chunkwm.err</string>
    </dict>
    </plist>
    EOS
  end

  test do
    system "#{prefix}/chunkwm", "--version"
  end
end
