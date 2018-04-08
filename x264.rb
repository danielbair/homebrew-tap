class X264 < Formula
  desc "H.264/AVC encoder"
  homepage "https://www.videolan.org/developers/x264.html"
  # the latest commit on the stable branch
  # url "https://git.videolan.org/git/x264.git", :revision => "fd2c324731c2199e502ded9eff723d29c6eafe0b"
  # version "r2668"
  url "ftp://ftp.videolan.org/pub/x264/snapshots/x264-snapshot-20160725-2245-stable.tar.bz2"
  version "r2705"

  head "https://git.videolan.org/git/x264.git"

  bottle do
    root_url "https://github.com/danielbair/homebrew-tap/releases/download/bottles/"
  end

  devel do
    # the latest commit on the master branch
    url "https://git.videolan.org/git/x264.git", :revision => "3b70645597bea052d2398005bc723212aeea6875"
    version "r2694"
  end

  option "with-10-bit", "Build a 10-bit x264 (default: 8-bit)"
  option "with-mp4=", "Select mp4 output: none (default), l-smash or gpac"

  depends_on "yasm" => :build

  deprecated_option "10-bit" => "with-10-bit"

  case ARGV.value "with-mp4"
  when "l-smash" then depends_on "l-smash"
  when "gpac" then depends_on "gpac"
  end

  def install
    args = %W[
      --prefix=#{prefix}
      --enable-shared
      --enable-static
      --enable-strip
    ]
    if Formula["l-smash"].installed?
      args << "--disable-gpac"
    elsif Formula["gpac"].installed?
      args << "--disable-lsmash"
    end
    args << "--bit-depth=10" if build.with? "10-bit"

    system "./configure", *args
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <stdint.h>
      #include <x264.h>

      int main()
      {
          x264_picture_t pic;
          x264_picture_init(&pic);
          x264_picture_alloc(&pic, 1, 1, 1);
          x264_picture_clean(&pic);
          return 0;
      }
    EOS
    system ENV.cc, "-lx264", "test.c", "-o", "test"
    system "./test"
  end
end
