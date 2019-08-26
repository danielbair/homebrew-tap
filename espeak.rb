class Espeak < Formula
  desc "Text to speech, software speech synthesizer"
  homepage "https://espeak.sourceforge.io/"
  url "https://downloads.sourceforge.net/project/espeak/espeak/espeak-1.48/espeak-1.48.04-source.zip"
  sha256 "bf9a17673adffcc28ff7ea18764f06136547e97bbd9edf2ec612f09b207f0659"
  revision 2

  #bottle do
  #  root_url "https://github.com/danielbair/homebrew-tap/releases/download/bottles/"
  #  rebuild 2
  #  sha256 "1f8c6c6d31fbb34fe7d52df13da5ec595c918a2d38ac06543846c7f12f2e724d" => :high_sierra
  #end

  depends_on "portaudio"

  def install
    share.install "espeak-data"
    share.install "docs"
    espeak_data = "/usr/local/share/espeak-data"
    cd "src" do
      rm "portaudio.h"
      inreplace "Makefile", "SONAME_OPT=-Wl,-soname,", "SONAME_OPT=-Wl,-install_name,"
      # OS X does not use -soname so replacing with -install_name to compile for OS X.
      # See http://stackoverflow.com/questions/4580789/ld-unknown-option-soname-on-os-x/32280483#32280483
      inreplace "speech.h", "#define USE_ASYNC", "//#define USE_ASYNC"
      # OS X does not provide sem_timedwait() so disabling #define USE_ASYNC to compile for OS X.
      # See https://sourceforge.net/p/espeak/discussion/538922/thread/0d957467/#407d
      inreplace "synthdata.cpp", "1.48.03  04.Mar.14", "1.48.04  06.04.2014"
      system "make", "speak", "DATADIR=#{espeak_data}", "PREFIX=#{prefix}"
      bin.install "speak" => "espeak"
      system "make", "libespeak.a", "DATADIR=#{espeak_data}", "PREFIX=#{prefix}"
      lib.install "libespeak.a" => "libespeak.a"
      system "make", "libespeak.so", "DATADIR=#{espeak_data}", "PREFIX=#{prefix}"
      lib.install "libespeak.so.1.1.48" => "libespeak.dylib"
      MachO::Tools.change_dylib_id("#{lib}/libespeak.dylib", "#{lib}/libespeak.dylib")
      #system "install_name_tool", "-id", "#{lib}/libespeak.dylib", "#{lib}/libespeak.dylib"
      # OS X does not use the convention libraryname.so.X.Y.Z. OS X uses the convention libraryname.X.dylib
      # See http://stackoverflow.com/questions/4580789/ld-unknown-option-soname-on-os-x/32280483#32280483
    end
  end

  test do
    system "#{bin}/espeak", "This is a test for Espeak.", "-w", "out.wav"
  end
end
