class Bs4 < Formula
  desc "provides idioms for iterating, searching, and modifying the parse tree"
  homepage "https://www.crummy.com/software/BeautifulSoup/"
  url "https://files.pythonhosted.org/packages/23/7b/37a477bc668068c23cb83e84191ee03709f1fa24d957b7d95083f10dda14/beautifulsoup4-4.8.0.tar.gz"
  #sha256 "3c9474036afda9136aac6463def733f81017bf9ef3510d25634f335b0c87f5e1"

  #bottle do
  #  root_url "https://github.com/danielbair/homebrew-tap/releases/download/bottles/"
  #  cellar :any_skip_relocation
  #  rebuild 1
  #  sha256 "e61398a853973e937330cee86e48500389bd5fce534980f52a1c18835e9727a9" => :high_sierra
  #end

  depends_on "python"
  depends_on "python2" => :optional

  #depends_on "soupsieve"
  
  resource "soupsieve" do
    url "https://files.pythonhosted.org/packages/6b/77/b7801323fd321021d92efb11154b7b85410318b8a2e9757c410afb6d976f/soupsieve-1.9.3.tar.gz"
    #sha256 "3c9474036afda9136aac6463def733f81017bf9ef3510d25634f335b0c87f5e1"
  end

  def install
    Language::Python.each_python(build) do |python, version|
      dest_path = lib/"python#{version}/site-packages"
      dest_path.mkpath
      resource("soupsieve").stage do
        system python, *Language::Python.setup_install_args(prefix)
      end
      system python, *Language::Python.setup_install_args(prefix)
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
    # printf result
  end
end
