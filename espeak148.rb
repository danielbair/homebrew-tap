class Espeak148 < Formula
  desc "Text to speech, software speech synthesizer"
  homepage "http://espeak.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/espeak/espeak/espeak-1.48/espeak-1.48.04-source.zip"
  sha256 "bf9a17673adffcc28ff7ea18764f06136547e97bbd9edf2ec612f09b207f0659"
  revision 1

  conflicts_with "libespeak",
                 :because => "both install the same libraries"

  depends_on "portaudio"

  patch :DATA

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
__END__
diff -N -r -u old/src/Makefile new/src/Makefile
--- old/src/Makefile	2014-02-02 17:58:11.000000000 +0700
+++ new/src/Makefile	2016-07-10 18:32:43.000000000 +0700
@@ -16,7 +16,7 @@
 LIBTAG = $(LIB_VERSION).$(RELEASE)
 
 # Use SONAME_OPT=-Wl,h, on Solaris
-SONAME_OPT=-Wl,-soname,
+SONAME_OPT=-Wl,-install_name,
 
 # Use EXTRA_LIBS=-lm on Solaris
 EXTRA_LIBS =
diff -N -r -u old/src/speech.h new/src/speech.h
--- old/src/speech.h	2014-03-04 23:47:15.000000000 +0700
+++ new/src/speech.h	2016-07-10 18:34:17.000000000 +0700
@@ -46,9 +46,9 @@
 #define __cdecl
 //#define ESPEAK_API  extern "C"
 
-#ifdef LIBRARY
-#define USE_ASYNC
-#endif
+//#ifdef LIBRARY
+//#define USE_ASYNC
+//#endif
 
 #ifdef _ESPEAKEDIT
 #define USE_PORTAUDIO
