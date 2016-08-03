class BrewPkg < Formula
  desc "Homebrew command for building OS X packages from installed formulae."
  homepage "https://github.com/danielbair/brew-pkg"
  url "https://github.com/danielbair/brew-pkg.git",
      :tag => "v0.1.8",
      :revision => "9c7b5e17379f8c2c6c0b92e270dc4316500b0458"

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
