# typed: false
# frozen_string_literal: true

class Aeneas < Formula
  desc "Python/C library and set of tools to synchronize audio and text"
  homepage "http://www.readbeyond.it/aeneas/"
  url "https://github.com/readbeyond/aeneas/archive/v1.7.3.tar.gz"
  sha256 "cd6453526a7a274df113d353a45ee270b6e912f91fc8b346e2d12847b5219f61"
  revision 6
  head "https://github.com/readbeyond/aeneas.git", branch: "master"

  bottle do
    root_url "https://github.com/danielbair/homebrew-tap/releases/download/bottles"
    rebuild 2
    sha256 cellar: :any, yosemite: "f8518d0b42936127b2d33fafe2373ad29b8292f2a1b01b395842b93f197ed638"
  end

  depends_on "danielbair/tap/bs4"
  depends_on "danielbair/tap/espeak-ng"
  depends_on "danielbair/tap/lxml"
  depends_on "ffmpeg"
  depends_on "numpy"
  depends_on "python@3.12"

  patch do
    url "https://github.com/readbeyond/aeneas/pull/204.patch?full_index=1"
    sha256 "ab25dd5f519bfca1fb5f9a865d5654178d14acf3f67e6b758e657de8d8521f82"
  end
  patch do
    url "https://github.com/readbeyond/aeneas/pull/258.patch?full_index=1"
    sha256 "ff8f4a740d6bac8260b1f771a6741637296d9f62cd39374b2d93f31bfac7d832"
  end

  def install
    rm_f "/usr/local/bin/aeneas_*"
    rm_f "aeneas/cew/speak_lib.h"
    ["python3"].each do |python|
      version = Language::Python.major_minor_version python
      dest_path = lib/"python#{version}/site-packages/aeneas"
      dest_path.mkpath
      ENV["AENEAS_USE_ESPEAKNG"] = "True"
      system python, *Language::Python.setup_install_args(prefix)
      ln "VERSION", dest_path
      ln "check_dependencies.py", dest_path
    end
  end

  test do
    system "#{bin}/aeneas_check_setup"
  end
end
