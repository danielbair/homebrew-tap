class Soupsieve < Formula
  desc "provides selectors from the CSS level 1 specifications up through the latest CSS level 4 drafts and beyond"
  homepage "https://github.com/facelessuser/soupsieve"
  url "https://files.pythonhosted.org/packages/3e/db/5ba900920642414333bdc3cb397075381d63eafc7e75c2373bbc560a9fa1/soupsieve-2.0.1.tar.gz"
  sha256 "a59dc181727e95d25f781f0eb4fd1825ff45590ec8ff49eadfd7f1a537cc0232"

  bottle do
    root_url "https://github.com/danielbair/homebrew-tap/releases/download/bottles"
    cellar :any_skip_relocation
    sha256 "c2c9532dd5dda63817706d85822e0c7f2a62d36457c037ae1a4c75fd38d72d44" => :yosemite
  end

  depends_on "python@3.8"

  depends_on "danielbair/tap/backports"

  def install
    ["python3"].each do |python|
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
