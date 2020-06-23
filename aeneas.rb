class Aeneas < Formula
  desc "Python/C library and set of tools to synchronize audio and text"
  homepage "http://www.readbeyond.it/aeneas/"
  url "https://github.com/readbeyond/aeneas/archive/v1.7.3.tar.gz"
  sha256 "cd6453526a7a274df113d353a45ee270b6e912f91fc8b346e2d12847b5219f61"
  revision 4
  head "https://github.com/readbeyond/aeneas.git", :branch => "master"

  bottle do
    root_url "https://github.com/danielbair/homebrew-tap/releases/download/bottles"
    cellar :any
    sha256 "71777daa18aaf30945674b8c5f81276a5d2e2530829bc78f9af38bec52880d0c" => :yosemite
  end

  depends_on "danielbair/tap/bs4"
  depends_on "danielbair/tap/espeak"
  depends_on "danielbair/tap/lxml"
  depends_on "ffmpeg"
  depends_on "numpy"
  depends_on "python@3.8"

  patch do
    url "https://github.com/readbeyond/aeneas/pull/204.patch?full_index=1"
    sha256 "ab25dd5f519bfca1fb5f9a865d5654178d14acf3f67e6b758e657de8d8521f82"
  end
  patch do
    url "https://github.com/readbeyond/aeneas/pull/255.patch?full_index=1"
    sha256 "1ae53d539f4f8118f9b8be99549fe8b4aeb19bcb2488894b30fac15abd12154b"
  end

  def install
    rm_f "/usr/local/bin/aeneas_*"
    ["python3"].each do |python|
      version = Language::Python.major_minor_version python
      dest_path = lib/"python#{version}/site-packages/aeneas"
      dest_path.mkpath
      system python, *Language::Python.setup_install_args(prefix)
      ln "VERSION", dest_path
      ln "check_dependencies.py", dest_path
    end
  end

  test do
    system "/usr/local/bin/aeneas_check_setup"
  end
end
