class ChunkwmBlur < Formula
  desc "Chunkwm plugin that blurs your wallpaper"
  homepage "https://github.com/splintah/blur"
  head "https://github.com/splintah/blur.git"

  depends_on :macos => :el_capitan
  depends_on "pkg-config" => :build
  depends_on "imagemagick" => :build
  depends_on "chunkwm" => :build

  def install
    system "make"
    (pkgshare/"plugins").install "#{buildpath}/bin/blur.so"
  end

  def caveats; <<~EOS
    The plugins install folder is #{opt_pkgshare}/plugins.

    Unfortunately since formulas are standalone in brew, we cannot just use chunkwm
    standard plugin dir.

    Because of this, the plugin needs to be symlinked to the chunkwm plugin folder:
      ln -sf #{opt_pkgshare}/plugins/blur.so /usr/local/opt/chunkwm/share/chunkwm/plugins/blur.so

    To activate the plugin, edit your ~/.chunkwmrc and add this load line:
      chunkc core::load blur.so

    Given the dependency on chunkwm headers to build this plugin, the formula is HEAD only.
    EOS
  end
end
