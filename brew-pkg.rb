class BrewPkg < Formula
  desc "Homebrew command for building OS X packages from installed formulae."
  homepage "https://github.com/danielbair/brew-pkg"
  url "https://github.com/danielbair/brew-pkg.git",
      :tag => "v0.1.6",
      :revision => "081679b9be8399bfb44f8aa7b1f0f349b4fab688"

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
