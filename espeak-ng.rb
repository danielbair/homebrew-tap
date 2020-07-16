class EspeakNg < Formula
  desc "eSpeak NG is a multi-lingual software speech synthesizer"
  homepage "https://github.com/espeak-ng/espeak-ng"
  url "https://github.com/espeak-ng/espeak-ng/archive/1.50.tar.gz"
  sha256 "5ce9f24ee662b5822a4acc45bed31425e70d7c50707b96b6c1603a335c7759fa"
  head "https://github.com/danielbair/espeak-ng.git"

  bottle do
    root_url "https://github.com/danielbair/homebrew-tap/releases/download/bottles"
    sha256 "f9635f7ec9f8de8db0d571a2e7f88a06c0eb103acbf98b9452c914f7a8cffd31" => :yosemite
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkg-config" => :build
  depends_on "kramdown" => :build
  depends_on "ronn" => :build
  depends_on "danielbair/tap/pcaudiolib"
  depends_on "danielbair/tap/sonic-speech"

  def install
    system "./autogen.sh"
    system "./configure", "--prefix=#{prefix}", "--with-extdict-ru", "--with-extdict-zh", "--with-extdict-zhy"
    system "make", "-j1", "src/espeak-ng", "src/speak-ng", "en"
    system "make", "-j1", "install"
  end

  test do
    system "espeak-ng", "Testing.", "-w", "test.wav"
  end
end
