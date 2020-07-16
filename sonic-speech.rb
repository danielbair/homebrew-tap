class SonicSpeech < Formula
  desc "Simple library to speed up or slow down speech"
  homepage "https://github.com/espeak-ng/sonic"
  url "https://github.com/espeak-ng/sonic/archive/release-0.2.0.tar.gz"
  sha256 "c7827ce576838467590ffa1f935fbe1049e896dfed6c515cf569ad3779c24085"
  revision 1

  bottle do
    root_url "https://github.com/danielbair/homebrew-tap/releases/download/bottles"
    cellar :any
    #sha256 "4ae710f9c821f6144180960d030dae3e83f001b5d207c54f57d8db86007127af" => :yosemite
  end

  depends_on "libtool" => :build
  depends_on "pkg-config" => :build

  patch do
    url "https://raw.githubusercontent.com/danielbair/homebrew-tap/7a24591f07c07e87f490823f620f6f4175aefbb9/patches/patch-sonic-mac.diff"
    sha256 "d84f9e5be4c81fc7a5ebcc672d02b171b59ca4c17512d823b2deb4fe0e9ceed0"
  end

  def install
    system "make", "USE_SPECTROGRAM=0", "PREFIX=#{prefix}"
    system "make", "USE_SPECTROGRAM=0", "PREFIX=#{prefix}", "install"
  end

  test do
    #nothing
  end
end
