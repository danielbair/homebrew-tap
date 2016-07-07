class Aeneas < Formula
  desc "Python/C library and set of tools to synchronize audio and text"
  homepage "http://www.readbeyond.it/aeneas/"
  url "https://github.com/readbeyond/aeneas/archive/v1.5.0.3.tar.gz"
  sha256 "fa979e701f89440631afc474b2fb27f5fbf5702c582d424c8d9bb52dcec80fb4"
  head "https://github.com/readbeyond/aeneas.git"

  depends_on "ffmpeg"
  depends_on "espeak"
  depends_on "python"

  resource "beautifulsoup4" do
    url "https://pypi.python.org/packages/26/79/ef9a8bcbec5abc4c618a80737b44b56f1cb393b40238574078c5002b97ce/beautifulsoup4-4.4.1.tar.gz"
    sha256 "87d4013d0625d4789a4f56b8d79a04d5ce6db1152bb65f1d39744f7709a366b4"
  end

  resource "lxml" do
    url "https://pypi.python.org/packages/11/1b/fe6904151b37a0d6da6e60c13583945f8ce3eae8ebd0ec763ce546358947/lxml-3.6.0.tar.gz"
    sha256 "9c74ca28a7f0c30dca8872281b3c47705e21217c8bc63912d95c9e2a7cac6bdf"
  end

  resource "numpy" do
    url "https://pypi.python.org/packages/e0/4c/515d7c4ac424ff38cc919f7099bf293dd064ba9a600e1e3835b3edefdb18/numpy-1.11.1.tar.gz"
    sha256 "dc4082c43979cc856a2bf352a8297ea109ccb3244d783ae067eb2ee5b0d577cd"
  end

  def install
    ENV.prepend_create_path "PYTHONPATH", libexec/"vendor/lib/python2.7/site-packages"
    %w[beautifulsoup4 lxml numpy].each do |r|
      resource(r).stage do
        system "python", *Language::Python.setup_install_args(libexec/"vendor")
      end
    end

    ENV.prepend_create_path "PYTHONPATH", libexec/"lib/python2.7/site-packages"
    system "python", *Language::Python.setup_install_args(libexec)

    bin.install Dir["#{libexec}/bin/*"]
    bin.env_script_all_files(libexec/"bin", :PYTHONPATH => ENV["PYTHONPATH"])
  end

  test do
    (testpath/"CMakeLists.txt").write("find_package(Ruby)")
    system "#{bin}/python", "."
  end
end
