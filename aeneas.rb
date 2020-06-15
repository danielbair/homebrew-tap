class Aeneas < Formula
  desc "Python/C library and set of tools to synchronize audio and text"
  homepage "http://www.readbeyond.it/aeneas/"
  url "https://github.com/readbeyond/aeneas/archive/v1.7.3.tar.gz"
  sha256 "cd6453526a7a274df113d353a45ee270b6e912f91fc8b346e2d12847b5219f61"
  revision 3
  head "https://github.com/readbeyond/aeneas.git", :branch => "master"

  bottle do
    root_url "https://github.com/danielbair/homebrew-tap/releases/download/bottles"
    cellar :any
    sha256 "c399a48a9ab9040780163d8c53ef835bd9a0dcf6f5e6308547c0307c77ac6093" => :yosemite
  end

  depends_on "danielbair/tap/bs4"
  depends_on "danielbair/tap/espeak"
  depends_on "danielbair/tap/lxml"
#  depends_on "ffmpeg"
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
    result = `export PYTHONIOENCODING=UTF-8; export PYTHONPATH=#{ENV["PYTHONPATH"]}:$PYTHONPATH; /usr/local/opt/python\@3.8/bin/python3 -m aeneas.diagnostics; /usr/local/opt/python\@3.8/bin/python3 -m aeneas.tools.synthesize_text list "This is a test|with two lines" eng -v test.wav; rm -f test.wav`
    printf result
  end
end
