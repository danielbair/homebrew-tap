# typed: false
# frozen_string_literal: true

class Bs4 < Formula
  desc "Provides idioms for iterating, searching, and modifying the parse tree"
  homepage "https://www.crummy.com/software/BeautifulSoup/"
  url "https://files.pythonhosted.org/packages/75/f8/de84282681c5a8307f3fff67b64641627b2652752d49d9222b77400d02b8/beautifulsoup4-4.11.2.tar.gz"
  sha256 "bc4bdda6717de5a2987436fb8d72f45dc90dd856bdfd512a1314ce90349a0106"
  # url "https://files.pythonhosted.org/packages/c6/62/8a2bef01214eeaa5a4489eca7104e152968729512ee33cb5fbbc37a896b7/beautifulsoup4-4.9.1.tar.gz"
  # sha256 "73cc4d115b96f79c7d77c1c7f7a0a8d4c57860d1041df407dd1aae7f07a77fd7"

  bottle do
    root_url "https://github.com/danielbair/homebrew-tap/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, yosemite: "f4d537ddcc6aa95aff6549675381fd64dc2bf3f0e92650db20bca446147ddf8a"
  end

  depends_on "danielbair/tap/soupsieve"
  depends_on "python@3.12"

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
      homebrew_site_packages = Language::Python.homebrew_site_packages "python3.12"
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
