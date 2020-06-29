class SonicSpeech < Formula
  desc "Simple library to speed up or slow down speech"
  homepage "ihttps://github.com/espeak-ng/sonic"
  url "https://github.com/espeak-ng/sonic/archive/release-0.2.0.tar.gz"
  sha256 "c7827ce576838467590ffa1f935fbe1049e896dfed6c515cf569ad3779c24085"

  depends_on "libtool" => :build
  depends_on "pkg-config" => :build

  def install
    system "make", "USE_SPECTROGRAM=0", "PREFIX=#{prefix}"
    system "make", "USE_SPECTROGRAM=0", "PREFIX=#{prefix}", "install"
  end

  test do
    #nothing
  end
end
