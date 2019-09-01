class Backports < Formula
  desc "Backport of functools.lru_cache from Python 3.3 as published at ActiveState."
  homepage "https://github.com/jaraco/backports.functools_lru_cache"
  url "https://files.pythonhosted.org/packages/57/d4/156eb5fbb08d2e85ab0a632e2bebdad355798dece07d4752f66a8d02d1ea/backports.functools_lru_cache-1.5.tar.gz"
  sha256 "9d98697f088eb1b0fa451391f91afb5e3ebde16bbdb272819fd091151fda4f1a"

  #bottle do
  #  root_url "https://github.com/danielbair/homebrew-tap/releases/download/bottles/"
  #  cellar :any_skip_relocation
  #  sha256 "74269451608ed19de14928c5ee8b973730355a717d60523833ca62b8710c7a43" => :yosemite
  #end

  depends_on "python"
  depends_on "python@2"

  def install
    ["python", "python2"].each do |python|
      version = Language::Python.major_minor_version python
      dest_path = lib/"python#{version}/site-packages"
      dest_path.mkpath
      system python, *Language::Python.setup_install_args(prefix)
    end
  end

  def caveats
    if build.with?("python") && !Formula["python"].installed?
      homebrew_site_packages = Language::Python.homebrew_site_packages "python2.7"
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
    # printf result
  end
end
