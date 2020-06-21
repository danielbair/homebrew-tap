class BrewPkg < Formula
  desc "Homebrew command for building OS X packages from installed formulae."
  homepage "https://github.com/danielbair/homebrew-pkg"
  url "https://github.com/danielbair/homebrew-pkg.git", :tag => "v1.0.2" 

  head "https://github.com/danielbair/homebrew-pkg.git"

  # This is an .rb that must be executable in order for Homebrew to
  # find it with the 'which' method, so we skip_clean
  #skip_clean "bin"

  def install
    bin.install "cmd/brew-pkg.rb"
  end

    def caveats
        <<~EOS
          You can uninstall this formula, as `brew tap danielbair/pkg` is all that's
          needed to install brew-pkg and keep it up to date.
        EOS
    end

  test do
    system "brew", "pkg", "--help"
  end
end
