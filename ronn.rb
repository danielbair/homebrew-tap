# typed: false
# frozen_string_literal: true

class Ronn < Formula
  desc "It converts simple, human readable textfiles to roff, and also to HTML"
  homepage "https://github.com/rtomayko/ronn"
  url "https://rubygems.org/gems/ronn-0.7.3.gem"
  sha256 "82df6fd4a3aa91734866710d2811a6387e50a7513fc528ce6c7d95ee7ad7f41e"

  bottle do
    root_url "https://github.com/danielbair/homebrew-tap/releases/download/bottles"
    sha256 cellar: :any, yosemite: "42e02a274fb2bd0fab38f778d1dd95d3b929c0375d9e6974adbdf7499a18b4f7"
  end

  depends_on "ruby"

  resource "mustache" do
    url "https://rubygems.org/gems/mustache-0.7.0.gem"
    sha256 "d9a6188661ada14629ab33b168d41e3311adcd2005ea02d155c27f68779a4d80"
  end

  resource "hpricot" do
    url "https://rubygems.org/gems/hpricot-0.8.6.gem"
    sha256 "dfe8f4b3414ba8377d7626030f3aa605caadee9de87cffbeadf8a50359eac8ca"
  end

  resource "rdiscount" do
    url "https://rubygems.org/gems/rdiscount-2.0.7.gem"
    sha256 "417fa105b9c282b430a60f7c450e8cb50bd3a28d36b4fd377d4ae29e8a6d49b2"
  end

  def install
    ENV["GEM_HOME"] = libexec

    (lib/"ronn/vendor").mkpath
    resources.each do |r|
      r.verify_download_integrity(r.fetch)
      system("gem", "install", r.cached_download, "--no-document", "--ignore-dependencies",
             "--install-dir", libexec)
    end

    if build.head?
      d = Dir["ronn-*.gem"]
      gem_file = d[0]
    else
      gem_file = "ronn-#{version}.gem"
    end
    system "gem", "install", "--ignore-dependencies", gem_file

    bin.install libexec/"bin/ronn"
    bin.env_script_all_files(libexec/"bin", GEM_HOME: ENV["GEM_HOME"])

    # man1.install Dir["man/*.1"]
    # man7.install Dir["man/*.7"]
  end

  test do
    (testpath/"test.ronn").write <<~EOS
      helloworld
      ==========

      Hello, world!
    EOS

    assert_match(/^Hello, world/, shell_output("#{bin}/ronn --roff --pipe test.ronn"))
  end
end
