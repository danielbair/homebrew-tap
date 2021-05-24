# typed: false
# frozen_string_literal: true

class Kramdown < Formula
  desc "Fast, pure Ruby Markdown superset converter"
  homepage "https://github.com/gettalong/kramdown"
  url "https://github.com/gettalong/kramdown/archive/REL_2_3_0.tar.gz"
  sha256 "3023ad3be1ad07c3fbf1677732ba66942674cc8f2beee866b54fa932cce0910c"
  head "https://github.com/gettalong/kramdown"

  bottle do
    root_url "https://github.com/danielbair/homebrew-tap/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, yosemite: "d89a055bf354c0f43a62d80b1b943fbf543c796fc440007cd58efd4193f6cc71"
  end

  patch do
    url "https://patch-diff.githubusercontent.com/raw/gettalong/kramdown/pull/673.diff"
    sha256 "ef872ddf0551559f60bf21ed55aaa18fdec10571a50e7028439f67930b801183"
  end

  def install
    system "ruby", "setup.rb", "config", "--prefix=/"
    system "ruby", "setup.rb", "setup"
    system "ruby", "setup.rb", "install", "--prefix=#{prefix}"
  end

  test do
    # nothing
  end
end
