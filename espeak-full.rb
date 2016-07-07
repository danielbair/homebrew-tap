class Espeak1 < Formula
  desc "Text to speech, software speech synthesizer"
  homepage "http://espeak.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/espeak/espeak/espeak-1.48/espeak-1.48.04-source.zip"
  sha256 "bf9a17673adffcc28ff7ea18764f06136547e97bbd9edf2ec612f09b207f0659"

  conflicts_with "espeak",
                 :because => "both install the same binaries"
  conflicts_with "libespeak",
                 :because => "both install the same libraries"

  depends_on "portaudio"

  patch do
    url "https://github.com/danielbair/homebrew-tap/raw/master/libespeak/espeak-osx.patch"
    sha256 "58b769e7e7f6f3904e2eee221f733029681184b8da654eb211bf90120abcab6b"
  end

  def install
    share.install "espeak-data"
    share.install "docs"
    cd "src" do
      rm "portaudio.h"
      system "make", "speak", "DATADIR=#{share}/espeak-data", "PREFIX=#{prefix}"
      bin.install "speak" => "espeak"
      system "make", "libespeak.a", "DATADIR=#{share}/espeak-data", "PREFIX=#{prefix}"
      lib.install "libespeak.a" => "libespeak.a"
      system "make", "libespeak.so", "DATADIR=#{share}/espeak-data", "PREFIX=#{prefix}"
      lib.install "libespeak.so.1.1.48" => "libespeak.dylib"
      system "install_name_tool", "-id", "#{lib}/libespeak.dylib", "#{lib}/libespeak.dylib"
    end
  end

  test do
    system "#{bin}/espeak", "This is a test for Espeak.", "-w", "out.wav"
  end
end
