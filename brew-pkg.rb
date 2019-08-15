class BrewPkg < Formula
  desc "Homebrew command for building OS X packages from installed formulae."
  homepage "https://github.com/danielbair/brew-pkg"
  head "https://github.com/danielbair/brew-pkg.git"
  url "https://github.com/danielbair/brew-pkg/archive/v0.1.11.tar.gz"

  # This is an .rb that must be executable in order for Homebrew to
  # find it with the 'which' method, so we skip_clean
  skip_clean "bin"

  def install
    bin.install "brew-pkg.rb"
  end

  test do
    # printf result
  end
end
