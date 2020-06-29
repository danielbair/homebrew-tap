class Ronn < Formula
  desc "Ronn builds manuals. It converts simple, human readable textfiles to roff for terminal display, and also to HTML for the web."
  homepage "https://github.com/rtomayko/ronn"
  url "https://github.com/rtomayko/ronn/archive/0.7.3.tar.gz"
  sha256 ""

  def install
      system "make", "speak", "DATADIR=#{espeak_data}", "PREFIX=#{prefix}"
      bin.install "speak" => "espeak"
      system "make", "libespeak.a", "DATADIR=#{espeak_data}", "PREFIX=#{prefix}"
      lib.install "libespeak.a" => "libespeak.a"
      system "make", "libespeak.so", "DATADIR=#{espeak_data}", "PREFIX=#{prefix}"
      lib.install "libespeak.so.1.1.48" => "libespeak.dylib"
  end

  test do
    #nothing
  end
end
