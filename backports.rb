# typed: false
# frozen_string_literal: true

class Backports < Formula
  desc "Backport of functools.lru_cache from Python 3.3 as published at ActiveState"
  homepage "https://github.com/jaraco/backports.functools_lru_cache"
  url "https://files.pythonhosted.org/packages/ad/2e/aa84668861c3de458c5bcbfb9813f0e26434e2232d3e294469e96efac884/backports.functools_lru_cache-1.6.1.tar.gz"
  sha256 "8fde5f188da2d593bd5bc0be98d9abc46c95bb8a9dde93429570192ee6cc2d4a"

  bottle do
    root_url "https://github.com/danielbair/homebrew-tap/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, yosemite: "0341c9dcdb4668900c867be683884a508e6fb417ae8d4a8483cd91799144d5d5"
  end

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
      homebrew_site_packages = Language::Python.homebrew_site_packages "python3.8"
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
