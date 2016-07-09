class Aeneas < Formula
  desc "Python/C library and set of tools to synchronize audio and text"
  homepage "http://www.readbeyond.it/aeneas/"
  url "https://github.com/readbeyond/aeneas/archive/v1.5.0.3.tar.gz"
  sha256 "fa979e701f89440631afc474b2fb27f5fbf5702c582d424c8d9bb52dcec80fb4"
  head "https://github.com/readbeyond/aeneas.git"

  depends_on "ffmpeg"
  depends_on "danielbair/tap/espeak"
  depends_on "python" => :recommended

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

  patch :DATA

  def install
    ENV.prepend_create_path "PYTHONPATH", libexec/"vendor/lib/python2.7/site-packages"
    resources.each do |r|
      r.stage do
        system "python", *Language::Python.setup_install_args(libexec/"vendor")
      end
    end

    ENV.prepend_create_path "PYTHONPATH", libexec/"lib/python2.7/site-packages"
    system "python", *Language::Python.setup_install_args(libexec)

    bin.install Dir["#{libexec}/bin/*"]
    cp "VERSION", libexec/"lib/python2.7/site-packages"
    cp "check_dependencies.py", libexec/"lib/python2.7/site-packages"
    bin.env_script_all_files(libexec/"bin", :PYTHONPATH => ENV["PYTHONPATH"])
    `grep "#{libexec}/lib/python2.7/site-packages" /Users/$(whoami)/.bash_profile > /dev/null || echo "export PYTHONPATH=#{ENV["PYTHONPATH"]}:$PYTHONPATH" >> /Users/$(whoami)/.bash_profile`
    `grep "/usr/local/bin:/usr/local/sbin" /Users/$(whoami)/.bash_profile > /dev/null || echo "export PATH=/usr/local/bin:/usr/local/sbin:$PATH" >> /Users/$(whoami)/.bash_profile`
  end

  def caveats
    result = `export PATH=/usr/local/bin:/usr/local/sbin:$PATH; export PYTHONIOENCODING=UTF-8; #{bin}/aeneas_check_setup`
    printf result
  end

  test do
    ENV.prepend_create_path "PYTHONPATH", libexec/"vendor/lib/python2.7/site-packages"
    ENV.prepend_create_path "PYTHONPATH", libexec/"lib/python2.7/site-packages"
    result = `echo #{testpath}; export PATH=/usr/local/bin:/usr/local/sbin:$PATH; export PYTHONIOENCODING=UTF-8; export PYTHONPATH=#{ENV["PYTHONPATH"]}:$PYTHONPATH; python -m aeneas.tools.synthesize_text list "This is a test|with two lines" eng -v test.wav`
    printf result
  end
end
__END__
--- aeneas-1.5.0.3/aeneas/diagnostics.py	2016-04-01 19:07:33.000000000 +0700
+++ aeneas-1.5.0.3-patched/aeneas/diagnostics.py	2016-07-02 20:24:06.000000000 +0700
@@ -232,11 +232,6 @@
 
         :rtype: bool
         """
-        if not gf.is_linux():
-            gf.print_warning(u"aeneas.cew     NOT AVAILABLE")
-            gf.print_info(u"  The Python C Extension cew is not available for your OS")
-            gf.print_info(u"  You can still run aeneas but it will be a bit slower (than Linux)")
-            return False
         if gf.can_run_c_extension("cew"):
             gf.print_success(u"aeneas.cew     COMPILED")
             return False
--- aeneas-1.5.0.3/setup.py	2016-04-23 16:27:49.000000000 +0700
+++ aeneas-1.5.0.3-patched/setup.py	2016-07-02 20:23:04.000000000 +0700
@@ -62,9 +62,8 @@
 #EXTENSIONS = [EXTENSION_CDTW, EXTENSION_CMFCC, EXTENSION_CWAVE]
 
 EXTENSIONS = [EXTENSION_CDTW, EXTENSION_CMFCC]
-if IS_LINUX:
-    # cew is available only for Linux at the moment
-    EXTENSIONS.append(EXTENSION_CEW)
+
+EXTENSIONS.append(EXTENSION_CEW)
 
 setup(
     name="aeneas",
