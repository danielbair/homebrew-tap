class RonnNg < Formula
  desc "Build man pages from Markdown"
  homepage "https://github.com/apjanke/ronn-ng"
  url "https://github.com/apjanke/ronn-ng/archive/v0.8.0.tar.gz"
  sha256 "c3f064fca2e8e9f8636cc3a43481851fd4a16bcf0a7d9f93761e6a49f663b03b"
  head "https://github.com/apjanke/ronn-ng.git"

  # Nokogiri 1.9 requires a newer Ruby
  depends_on "ruby"

  resource "mustache" do
    url "https://rubygems.org/gems/mustache-0.7.0.gem"
    sha256 "d9a6188661ada14629ab33b168d41e3311adcd2005ea02d155c27f68779a4d80"
  end

  resource "mini_portile2" do
    url "https://rubygems.org/gems/mini_portile2-2.4.0.gem"
    sha256 "7e178a397ad62bb8a96977986130dc81f1b13201c6dd95a48bd8cec1dda5f797"
  end

  resource "nokogiri" do
    url "https://rubygems.org/gems/nokogiri-1.9.0.gem"
    sha256 "e0dc98da58f955789c6fe6273c9eebf93568b38e93feafa7356cb79a71b4b62d"
  end

  resource "rdiscount" do
    url "https://rubygems.org/gems/rdiscount-2.0.7.gem"
    sha256 "417fa105b9c282b430a60f7c450e8cb50bd3a28d36b4fd377d4ae29e8a6d49b2"
  end

  def install
    ENV["GEM_HOME"] = libexec

    (lib/"ronn-ng/vendor").mkpath
    resources.each do |r|
      r.verify_download_integrity(r.fetch)
      system("gem", "install", r.cached_download, "--no-document", "--ignore-dependencies",
             "--install-dir", libexec)
    end

    if build.head?
      d = Dir['ronn-ng-*.gem']
      gem_file = d[0]
    else
      gem_file = "ronn-ng-#{version}.gem"
    end
    system "gem", "build", "ronn-ng.gemspec"
    system "gem", "install", "--ignore-dependencies", gem_file

    bin.install libexec/"bin/ronn"
    bin.env_script_all_files(libexec/"bin", :GEM_HOME => ENV["GEM_HOME"])

    bash_completion.install "completion/bash/ronn"
    zsh_completion.install "completion/zsh/_ronn"
    man1.install Dir["man/*.1"]
    man7.install Dir["man/*.7"]
  end

  test do
    (testpath/"test.ronn").write <<~EOS
    helloworld
    ==========

    Hello, world!
    EOS

    assert_match /^Hello, world/, shell_output("#{bin}/ronn --roff --pipe test.ronn")
  end
end
