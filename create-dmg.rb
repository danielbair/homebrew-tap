# typed: false
# frozen_string_literal: true

class CreateDmg < Formula
  desc "Shell script to build fancy DMGs"
  homepage "https://github.com/danielbair/create-dmg"
  url "https://github.com/danielbair/create-dmg.git"
  version "1.0.0.4"

  def install
    cp_r ".", prefix
    create_dmg_wrapper = <<-EOS.undent
    #!/bin/bash
    # A wrapper for create-dmg to call it with it's support folders and files
    IFS=$'\n'
    #{prefix}/create-dmg "$@"
    EOS
    (buildpath/"create-dmg-wrapper").write create_dmg_wrapper
    bin.install "create-dmg-wrapper" => "create-dmg"
  end

  test do
    # printf result
  end
end
