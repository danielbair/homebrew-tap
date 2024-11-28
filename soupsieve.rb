# typed: false
# frozen_string_literal: true

class Soupsieve < Formula
  desc "Provides selectors from the CSS level 1 specifications and up"
  homepage "https://github.com/facelessuser/soupsieve"
  url "https://files.pythonhosted.org/packages/3e/db/5ba900920642414333bdc3cb397075381d63eafc7e75c2373bbc560a9fa1/soupsieve-2.0.1.tar.gz"
  sha256 "a59dc181727e95d25f781f0eb4fd1825ff45590ec8ff49eadfd7f1a537cc0232"

  bottle do
    root_url "https://github.com/danielbair/homebrew-tap/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, yosemite: "c2c9532dd5dda63817706d85822e0c7f2a62d36457c037ae1a4c75fd38d72d44"
  end

  depends_on "danielbair/tap/backports"
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
