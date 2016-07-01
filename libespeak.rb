class Libespeak < Formula
  desc "Static library for the eSpeak text to speech, software speech synthesizer"
  homepage "http://espeak.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/espeak/espeak/espeak-1.48/espeak-1.48.04-source.zip"

  depends_on "portaudio"

  patch do
    cd "src" do
      url "https://github.com/danielbair/homebrew-tap/raw/master/libespeak/Makefile.patch"
      url "https://github.com/danielbair/homebrew-tap/raw/master/libespeak/fifo.cpp.patch"
      url "https://github.com/danielbair/homebrew-tap/raw/master/libespeak/event.cpp.patch"
    end
  end

  def install
    share.install "espeak-data"
    cd "src" do
      rm "portaudio.h"
      system "make", "libespeak.a", "DATADIR=#{share}/espeak-data", "PREFIX=#{prefix}"
    end
  end

end
