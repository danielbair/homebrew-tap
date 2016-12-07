class Aeneas < Formula
  desc "Python/C library and set of tools to synchronize audio and text"
  homepage "http://www.readbeyond.it/aeneas/"
  url "https://github.com/readbeyond/aeneas/archive/v1.7.0.tar.gz"
  sha256 "7f3f689c4053692018f6977c8310e4d6321b6268355947bb7ecaa8968c0486c8"
  head "https://github.com/readbeyond/aeneas.git", :branch => "master"
  devel do
    url "https://github.com/readbeyond/aeneas.git", :branch => "devel"
    version "devel1"
  end

  depends_on "danielbair/tap/espeak"
  depends_on "danielbair/tap/ffmpeg"
  depends_on :python => :recommended
  depends_on :python3 => :optional

  depends_on "danielbair/tap/numpy"
  depends_on "danielbair/tap/lxml"
  depends_on "danielbair/tap/bs4"

  def install
    Language::Python.each_python(build) do |python, version|
      dest_path = lib/"python#{version}/site-packages"
      dest_path.mkpath
      system python, *Language::Python.setup_install_args(prefix)
      ln "VERSION", dest_path
      ln "check_dependencies.py", dest_path
    end
  end

  def caveats
    if build.with?("python") && !Formula["python"].installed?
      homebrew_site_packages = Language::Python.homebrew_site_packages
      user_site_packages = Language::Python.user_site_packages "python"
      <<-EOS.undent
        If you use system python (that comes - depending on the OS X version -
        with older versions of numpy, scipy and matplotlib), you may need to
        ensure that the brewed packages come earlier in Python's sys.path with:
          mkdir -p #{user_site_packages}
          echo 'import sys; sys.path.insert(1, "#{homebrew_site_packages}")' >> #{user_site_packages}/homebrew.pth
      EOS
    end
  end

  test do
    result = `echo #{testpath}; export PATH=/usr/local/bin:/usr/local/sbin:$PATH; export PYTHONIOENCODING=UTF-8; export PYTHONPATH=#{ENV["PYTHONPATH"]}:$PYTHONPATH; python -m aeneas.diagnostics; python -m aeneas.tools.synthesize_text list "This is a test|with two lines" eng -v test.wav`
    printf result
  end
end
