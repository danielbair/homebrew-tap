class Mpv < Formula
  desc "Media player based on MPlayer and mplayer2"
  homepage "https://mpv.io"
  revision 4
  head "https://github.com/mpv-player/mpv.git", :branch => "master"

  stable do
    # url "https://github.com/mpv-player/mpv/archive/6e6ec331685c78584a818f524286670911e8b4af.tar.gz"
    # version "0.29.1~6e6ec33"
    # sha256 "fbb5ebc72c55af6e62cb3835b87b0fd26160533350f17e73712791870bdbe017"
    url "https://github.com/mpv-player/mpv/archive/v0.29.1.tar.gz"
    sha256 "f9f9d461d1990f9728660b4ccb0e8cb5dce29ccaa6af567bec481b79291ca623"

    # Note, non-head version is completly implemented in this lengthy patch
    patch do
      url "https://raw.githubusercontent.com/danielbair/homebrew-tap/master/mpv-player/mpv-fix.patch"
      sha256 "22a71d457b84df5ffc95ab35671ff88f498e0040785c8d6213ebe54eb008d9e2"
    end
  end

  bottle do
    root_url "https://github.com/danielbair/homebrew-tap/releases/download/bottles"
    # sha256 "a91d2f0d616a23d37308c5a0c1f4902b07eec44f2eb6619c285044d3e4bb0124" => :mojave
  end

  depends_on "docutils" => :build
  depends_on "pkg-config" => :build
  depends_on "python" => :build

  depends_on "ffmpeg"
  depends_on "jpeg"
  depends_on "libarchive"
  depends_on "libass"
  depends_on "little-cms2"
  depends_on "lua@5.1"

  depends_on "mujs"
  depends_on "uchardet"
  depends_on "vapoursynth"
  depends_on "youtube-dl"

  def install
    # LANG is unset by default on macOS and causes issues when calling getlocale
    # or getdefaultlocale in docutils. Force the default c/posix locale since
    # that's good enough for building the manpage.
    ENV["LC_ALL"] = "C"

    args = %W[
      --prefix=#{prefix}
      --enable-html-build
      --enable-javascript
      --enable-libmpv-shared
      --enable-lua
      --enable-libarchive
      --enable-uchardet
      --confdir=#{etc}/mpv
      --datadir=#{pkgshare}
      --mandir=#{man}
      --docdir=#{doc}
      --enable-zsh-comp
      --zshdir=#{zsh_completion}
    ]

    system "./bootstrap.py"
    system "python3", "waf", "configure", *args
    system "python3", "waf", "install"

    system "python3", "TOOLS/osxbundle.py", "build/mpv"
    prefix.install "build/mpv.app"
  end

  test do
    system bin/"mpv", "--ao=null", test_fixtures("test.wav")
  end
end
