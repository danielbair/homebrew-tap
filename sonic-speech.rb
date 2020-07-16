class SonicSpeech < Formula
  desc "Simple library to speed up or slow down speech"
  homepage "https://github.com/espeak-ng/sonic"
  url "https://github.com/espeak-ng/sonic/archive/release-0.2.0.tar.gz"
  sha256 "c7827ce576838467590ffa1f935fbe1049e896dfed6c515cf569ad3779c24085"

  bottle do
    root_url "https://github.com/danielbair/homebrew-tap/releases/download/bottles"
    cellar :any
    sha256 "4ae710f9c821f6144180960d030dae3e83f001b5d207c54f57d8db86007127af" => :yosemite
  end

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
