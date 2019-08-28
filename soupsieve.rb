class Soupsieve < Formula
  desc "provides selectors from the CSS level 1 specifications up through the latest CSS level 4 drafts and beyond"
  homepage "https://github.com/facelessuser/soupsieve"
  url "https://files.pythonhosted.org/packages/6b/77/b7801323fd321021d92efb11154b7b85410318b8a2e9757c410afb6d976f/soupsieve-1.9.3.tar.gz"
  sha256 "8662843366b8d8779dec4e2f921bebec9afd856a5ff2e82cd419acc5054a1a92"

  bottle do
    root_url "https://github.com/danielbair/homebrew-tap/releases/download/bottles/"
    cellar :any_skip_relocation
    sha256 "74269451608ed19de14928c5ee8b973730355a717d60523833ca62b8710c7a43" => :yosemite
  end

  depends_on "python"
  depends_on "python@2"

  def install
    ["python2", "python3"].each do |python|
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
