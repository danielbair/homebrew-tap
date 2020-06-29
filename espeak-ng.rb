class EspeakNg < Formula
  desc "eSpeak NG is a multi-lingual software speech synthesizer"
  homepage "https://github.com/danielbair/espeak-ng"
  url "https://github.com/danielbair/espeak-ng/archive/1.50.tar.gz"
  sha256 "5ce9f24ee662b5822a4acc45bed31425e70d7c50707b96b6c1603a335c7759fa"
  head "https://github.com/danielbair/espeak-ng.git"


  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkg-config" => :build
  depends_on "pcaudiolib" => :build
  depends_on "sonic-speech" => :build
  depends_on "ronn-ng" => :build
  depends_on "kramdown" => :build

  def install
    system "./autogen.sh"
    system "./configure", "--prefix=#{prefix}", "--with-extdict-ru", "--with-extdict-zh", "--with-extdict-zhy"
    system "make", "src/espeak-ng", "src/speak-ng"
    system "make", "en"
    system "make", "-i", "-k", "docs"
    system "make", "-i", "-k", "install"
  end

  test do
    #nothing
  end
end
