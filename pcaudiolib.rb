class Pcaudiolib < Formula
  desc "iPortable C Audio Library"
  homepage "https://github.com/espeak-ng/pcaudiolib"
  url "https://github.com/espeak-ng/pcaudiolib/archive/1.1.tar.gz"
  sha256 "699a5a347b1e12dc5b122e192e19f4db01621826bf41b9ebefb1cbc63ae2180b"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkg-config" => :build

  def install
    system "./autogen.sh"
    system "./configure", "--prefix=#{prefix}"
    system "make", "PREFIX=#{prefix}"
    system "make", "PREFIX=#{prefix}", "install"
  end

  test do
    #nothing
  end
end
