class Espeak148 < Formula
  desc "Text to speech, software speech synthesizer"
  homepage "http://espeak.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/espeak/espeak/espeak-1.48/espeak-1.48.04-source.zip"
  sha256 "bf9a17673adffcc28ff7ea18764f06136547e97bbd9edf2ec612f09b207f0659"
  revision 1

  conflicts_with "libespeak",
                 :because => "both install the same libraries"

  depends_on "portaudio"

  def install
    share.install "espeak-data"
    share.install "docs"
    cd "src" do
      rm "portaudio.h"
      inreplace "Makefile", "SONAME_OPT=-Wl,-soname,", "SONAME_OPT=-Wl,-install_name,"
      # OS X does not use -soname so replacing with -install_name to compile for OS X.
      # See http://stackoverflow.com/questions/4580789/ld-unknown-option-soname-on-os-x/32280483#32280483
      inreplace "speech.h", "#define USE_ASYNC", "//#define USE_ASYNC"
      # OS X does not provide sem_timedwait() so disabling #define USE_ASYNC to compile for OS X.
      # See https://sourceforge.net/p/espeak/discussion/538922/thread/0d957467/#407d
      system "make", "speak", "DATADIR=#{share}/espeak-data", "PREFIX=#{prefix}"
      bin.install "speak" => "espeak"
      system "make", "libespeak.a", "DATADIR=#{share}/espeak-data", "PREFIX=#{prefix}"
      lib.install "libespeak.a" => "libespeak.a"
      system "make", "libespeak.so", "DATADIR=#{share}/espeak-data", "PREFIX=#{prefix}"
      lib.install "libespeak.so.1.1.48" => "libespeak.dylib"
      system "install_name_tool", "-id", "#{lib}/libespeak.dylib", "#{lib}/libespeak.dylib"
      # OS X does not use the convention libraryname.so.X.Y.Z. OS X uses the convention libraryname.X.dylib
      # See http://stackoverflow.com/questions/4580789/ld-unknown-option-soname-on-os-x/32280483#32280483
    end
  end

  test do
    system "#{bin}/espeak", "This is a test for Espeak.", "-w", "out.wav"
  end
end
