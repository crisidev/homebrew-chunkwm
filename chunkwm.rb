class Chunkwm < Formula
  desc "Tiling window manager for MacOS based on plugin architecture"
  homepage "https://github.com/koekeishiya/chunkwm"
  url "https://github.com/koekeishiya/chunkwm/archive/v0.2.10.tar.gz"
  sha256 "ac12e977368873de6f2533648bc0c5e4da09adcc2d3fa8fe67178bb2bf4a796a"

  head do
    url "https://github.com/koekeishiya/chunkwm.git"
  end

  option "with-ffm", "Build focus-follow-mouse plugin."
  option "with-template", "Build template plugin."
  option "with-transparency", "Build transparency plugin."

  depends_on :xcode => ["8", :build]

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
    Dir.chdir("#{buildpath}/src/plugins/tiling")
    system "make", "install"
    (share/"chunkwm_plugins").install "#{buildpath}/plugins/tiling.so"
    (share/"examples").install "#{buildpath}/src/plugins/tiling/examples/khdrc"

    # install border plugin
    Dir.chdir("#{buildpath}/src/plugins/border")
    system "make", "install"
    (share/"chunkwm_plugins").install "#{buildpath}/plugins/border.so"

    # install ffm plugin
    Dir.chdir("#{buildpath}/src/plugins/ffm") if build.with? "ffm"
    system "make", "install" if build.with? "ffm"
    (share/"chunkwm_plugins").install "#{buildpath}/plugins/ffm.so" if build.with? "ffm"

    # install template plugin
    Dir.chdir("#{buildpath}/src/plugins/template") if build.with? "template"
    system "make", "install" if build.with? "template"
    (share/"chunkwm_plugins").install "#{buildpath}/plugins/template.so" if build.with? "template"

    # install transparency plugin
    Dir.chdir("#{buildpath}/src/plugins/transparency") if build.with? "transparency"
    system "make", "install" if build.with? "transparency"
    (share/"chunkwm_plugins").install "#{buildpath}/plugins/transparency.so" if build.with? "transparency"
  end

  def caveats; <<-EOS.undent
    Copy the example configs from #{share}/examples into your home directory:
      cp #{share}/examples/chunkwmrc ~/.chunkwmrc

    Plugins are installed into #{share}/chunkwm_plusing folder.
    To allow plugins to load properly you have two possibilites:
      * Edit ~/.chunkwmrc and change line
          chunkc plugin_dir ~/.chunkwm_plugins
        into
          chunkc plugin_dir #{share}/chunkwm_plugins
      * Link plugins into your home directory
          ln -sf #{share}/chunkwm_plugins ~/.chunkwm_plugins

    The first time chunkwm-core is ran, it will request access to the accessibility API.
    After access has been granted, the application must be restarted.

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
            <string>#{prefix}/bin/chunkwm</string>
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
