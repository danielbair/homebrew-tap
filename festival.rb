class Festival < Formula
  desc "C++ speech software library from the University of Edinburgh"
  homepage "http://festvox.org/docs/manual-2.4.0/"
  url "http://festvox.org/packed/festival/2.5/festival-2.5.0-release.tar.gz"
  sha256 "4c9007426b125290599d931df410e2def51e68a8aeebd89b4a61c7c96c09a4b4"

  bottle do
    root_url "https://github.com/danielbair/homebrew-tap/releases/download/bottles/"
    rebuild 1
    sha256 "da9b44c783372e16e5664a9f1d1b30d107bf884a12b78a4d5db01d2760c63477" => :high_sierra
  end

  depends_on "speech-tools"

  resource "speech-tools" do
    url "http://festvox.org/packed/festival/2.5/speech_tools-2.5.0-release.tar.gz"
    sha256 "e4fd97ed78f14464358d09f36dfe91bc1721b7c0fa6503e04364fb5847805dcc"
  end

  resource "festvox" do
    url "http://festvox.org/festvox-2.7/festvox-2.7.0-release.tar.gz"
    sha256 "a3f610c6c9a86acffc90979d9e77e8096b1039480900f6dc4c0313836bf46ec6"
  end

  resource "festvox-english" do
    url "http://festvox.org/packed/festival/2.5/voices/festvox_kallpc16k.tar.gz"
    sha256 "7a357c34086fbba8b813f9750f6b5ba13e2a00478a0a2e78a97981cb76395578"
  end

  resource "festvox-cmu" do
    url "http://festvox.org/packed/festival/2.5/festlex_CMU.tar.gz"
    sha256 "c19430919bca45d5368cd4c82af6153fbcc96a487ebd30b78b5f3c08718b7c07"
  end

  resource "festvox-oald" do
    url "http://festvox.org/packed/festival/2.5/festlex_OALD.tar.gz"
    sha256 "e33a345390d4c76f8b987b06a5332bcdd0b168cf67c95ddc3270f9163cbe61f8"
  end

  resource "festvox-poslex" do
    url "http://festvox.org/packed/festival/2.5/festlex_POSLEX.tar.gz"
    sha256 "e7c6e3642dbd5b0d64942bc015a986fdd6244a79e51ec2e8309e63d569e49ea3"
  end

  def install
    ENV.deparallelize
    (buildpath/"extras/festvox").install resource("festvox")
    (buildpath/"extras/speech_tools").install resource("speech-tools")
    cd buildpath/"extras/speech_tools"
    system "./configure"
    system "make"
    rm_rf "bin"
    ln_s "/usr/local/opt/speech-tools/bin", "bin"
    cd buildpath
    inreplace "config/config.in", /\/..\/speech_tools/, "/extras/speech_tools"
    system "./configure"
    system "make"
    system "make", "install"
    cd buildpath/"extras/festvox"
    system "./configure"
    system "make"
    cd buildpath
    (buildpath/"extras/voices").install resource("festvox-english")
    mv buildpath/"extras/voices/lib/voices", "lib/voices"
    (buildpath/"extras/cmu").install resource("festvox-cmu")
    (buildpath/"extras/oald").install resource("festvox-oald")
    (buildpath/"extras/poslex").install resource("festvox-poslex")
    mv buildpath/"extras/poslex/lib/dicts", "lib/dicts"
    mv buildpath/"extras/cmu/lib/dicts/cmu", "lib/dicts/cmu"
    mv buildpath/"extras/oald/lib/dicts/oald", "lib/dicts/oald"
    man1.install "doc/festival_client.1"
    man1.install "doc/festival.1"
    share.install Dir["extras/*"]
    lib.install Dir["lib/*"]
    rm "bin/festival"
    rm "bin/festival_client"
    bin.install Dir["src/main/*"].select { |f| File.file?(f) && File.executable?(f) }
    bin.install Dir["bin/*"].select { |f| File.file?(f) && File.executable?(f) }
    prefix.install Dir["*"]
  end

  def caveats
      <<~EOS
        Add the following to your ~/.bash_profile:
	  export FESTIVALDIR=/usr/local/opt/festival/
	  export FESTLIBDIR=/usr/local/opt/festival/lib/
	  export FESTVOXDIR=/usr/local/opt/festival/share/festvox/
	  export ESTDIR=/usr/local/opt/festival/share/speech_tools/
      EOS
  end

  test do
    rate_hz = 16000
    frequency_hz = 100
    duration_secs = 5
    basename = "sine"
    txtfile = "#{basename}.txt"
    wavfile = "#{basename}.wav"
    ptcfile = "#{basename}.ptc"

    File.open(txtfile, "w") do |f|
      scale = 2 ** 15 - 1
      f.puts Array.new(duration_secs * rate_hz) { |i| (scale * Math.sin(frequency_hz * 2 * Math::PI * i / rate_hz)).to_i }
    end

    # convert to wav format using ch_wave
    system bin/"ch_wave", txtfile,
      "-itype", "raw",
      "-istype", "ascii",
      "-f", rate_hz.to_s,
      "-o", wavfile,
      "-otype", "riff"

    # pitch tracking to est format using pda
    system bin/"pda", wavfile,
      "-shift", (1 / frequency_hz.to_f).to_s,
      "-o", ptcfile,
      "-otype", "est"

    # extract one frame from the middle using ch_track, capturing stdout
    pitch = shell_output("#{bin}/ch_track #{ptcfile} -from #{frequency_hz * duration_secs / 2} -to #{frequency_hz * duration_secs / 2}")

    # should be 100 (Hz)
    assert_equal frequency_hz, pitch.to_i
  end
end
