class Lxml < Formula
  desc "mature binding for libxml2 and libxslt libraries using the ElementTree API"
  homepage "http://lxml.de/"
  url "https://files.pythonhosted.org/packages/c4/43/3f1e7d742e2a7925be180b6af5e0f67d38de2f37560365ac1a0b9a04c015/lxml-4.4.1.tar.gz"
  sha256 "c81cb40bff373ab7a7446d6bbca0190bccc5be3448b47b51d729e37799bb5692"

#  bottle do
#    root_url "https://github.com/danielbair/homebrew-tap/releases/download/bottles"
#    cellar :any_skip_relocation
#    sha256 "b6ad3fceece66fb070b068b95d1f52695606adf1381776500b9e2a93bb3b6078" => :yosemite
#  end

  depends_on "python"

  def install
    ["python", "python3"].each do |python|
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
