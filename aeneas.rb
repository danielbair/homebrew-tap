class Aeneas < Formula
  desc "Python/C library and set of tools to synchronize audio and text"
  homepage "http://www.readbeyond.it/aeneas/"
  url "https://github.com/readbeyond/aeneas/archive/v1.7.3.tar.gz"
  sha256 "cd6453526a7a274df113d353a45ee270b6e912f91fc8b346e2d12847b5219f61"
  head "https://github.com/readbeyond/aeneas.git", :branch => "master"
  devel do
    url "https://github.com/readbeyond/aeneas.git", :branch => "devel"
    version "1.7.4"
  end

  bottle do
    root_url "https://github.com/danielbair/homebrew-tap/releases/download/bottles/"
    cellar :any
    sha256 "9e85e8aaf451bf32ea4a8f4fbab52f3165e16e20b3d82dc5706077dbdb5fce56" => :yosemite
  end

  depends_on "danielbair/tap/espeak"
  depends_on "ffmpeg"
  depends_on "python"
  depends_on "python@2"

  depends_on "numpy"
  depends_on "danielbair/tap/lxml"
  depends_on "danielbair/tap/bs4"

  patch do
    url "https://github.com/readbeyond/aeneas/pull/204.patch?full_index=1"
    sha256 "ab25dd5f519bfca1fb5f9a865d5654178d14acf3f67e6b758e657de8d8521f82"
  end

  def install
    ["python2", "python3"].each do |python|
      version = Language::Python.major_minor_version python
      dest_path = lib/"python#{version}/site-packages/aeneas"
      dest_path.mkpath
      system python, *Language::Python.setup_install_args(prefix)
      ln "VERSION", dest_path
      ln "check_dependencies.py", dest_path
    end
  end

  def caveats
      homebrew_site_packages = Language::Python.homebrew_site_packages "python2.7"
      user_site_packages = Language::Python.user_site_packages "python"
      <<~EOS
        If you use system python (that comes - depending on the OS X version -
        with older versions of numpy, scipy and matplotlib), you may need to
        ensure that the brewed packages come earlier in Python's sys.path with:
          mkdir -p #{user_site_packages}
          echo 'import sys; sys.path.insert(1, "#{homebrew_site_packages}")' >> #{user_site_packages}/homebrew.pth
      EOS
  end

  test do
    result = `echo #{testpath}; export PATH=/usr/local/bin:/usr/local/sbin:$PATH; export PYTHONIOENCODING=UTF-8; export PYTHONPATH=#{ENV["PYTHONPATH"]}:$PYTHONPATH; python -m aeneas.diagnostics; python -m aeneas.tools.synthesize_text list "This is a test|with two lines" eng -v test.wav`
    printf result
  end
end
