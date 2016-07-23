class BrewPkg < Formula
  desc "Homebrew command for building OS X packages from installed formulae."
  homepage "https://github.com/danielbair/brew-pkg"
  url "https://github.com/danielbair/brew-pkg.git",
      :tag => "v0.1.7",
      :revision => "b7e5228497542c3b6799e36b4341dc708b07ed1d"

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
