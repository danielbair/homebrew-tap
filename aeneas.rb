class Aeneas < Formula
  desc "Python/C library and set of tools to synchronize audio and text"
  homepage "http://www.readbeyond.it/aeneas/"
  url "https://github.com/readbeyond/aeneas/archive/v1.5.0.3.tar.gz"
  sha256 "fa979e701f89440631afc474b2fb27f5fbf5702c582d424c8d9bb52dcec80fb4"
  head "https://github.com/readbeyond/aeneas.git"

  depends_on "ffmpeg" => :recommended
  depends_on "espeak" => :recommended
  depends_on :python => :recommended
  depends_on :python3 => :optional

  depends_on "homebrew/python/numpy"

  resource "beautifulsoup4" do
    url "https://pypi.python.org/packages/26/79/ef9a8bcbec5abc4c618a80737b44b56f1cb393b40238574078c5002b97ce/beautifulsoup4-4.4.1.tar.gz"
    sha256 "87d4013d0625d4789a4f56b8d79a04d5ce6db1152bb65f1d39744f7709a366b4"
  end

  resource "lxml" do
    url "https://pypi.python.org/packages/11/1b/fe6904151b37a0d6da6e60c13583945f8ce3eae8ebd0ec763ce546358947/lxml-3.6.0.tar.gz"
    sha256 "9c74ca28a7f0c30dca8872281b3c47705e21217c8bc63912d95c9e2a7cac6bdf"
  end

  patch :DATA

  def install
    Language::Python.each_python(build) do |python, version|
      dest_path = lib/"python#{version}/site-packages"
      dest_path.mkpath
      vendor_path = libexec/"vendor/lib/python#{version}/site-packages"
      ENV.prepend_create_path "PYTHONPATH", libexec/"vendor/lib/python2.7/site-packages"
      resources.each do |r|
        r.stage do
          system python, *Language::Python.setup_install_args(libexec/"vendor")
        end
      end
      (dest_path/"homebrew-aeneas-vendor.pth").write "#{vendor_path}\n"

      aeneas_path = libexec/"lib/python#{version}/site-packages"
      ENV.prepend_create_path "PYTHONPATH", libexec/"lib/python2.7/site-packages"
      system python, *Language::Python.setup_install_args(libexec)
      (dest_path/"homebrew-aeneas.pth").write "#{aeneas_path}\n"

      bin.install Dir["#{libexec}/bin/*"]
      cp_r "aeneas", prefix
      cp "VERSION", prefix
      cp "check_dependencies.py", prefix
      # cp "VERSION", libexec/"lib/python2.7/site-packages"
      # cp "check_dependencies.py", libexec/"lib/python2.7/site-packages"
      # bin.env_script_all_files(libexec/"bin", :PYTHONPATH => ENV["PYTHONPATH"])
    end
  end

  def caveats
    if build.with?("python") && !Formula["python"].installed?
      homebrew_site_packages = Language::Python.homebrew_site_packages
      user_site_packages = Language::Python.user_site_packages "python"
      <<-EOS.undent
        If you use system python (that comes - depending on the OS X version -
        with older versions of numpy, scipy and matplotlib), you may need to
        ensure that the brewed packages come earlier in Python's sys.path with:
          mkdir -p #{user_site_packages}
          echo 'import sys; sys.path.insert(1, "#{homebrew_site_packages}")' >> #{user_site_packages}/homebrew.pth
      EOS
    end
  end

  test do
    ENV.prepend_create_path "PYTHONPATH", libexec/"vendor/lib/python2.7/site-packages"
    ENV.prepend_create_path "PYTHONPATH", libexec/"lib/python2.7/site-packages"
    result = `echo #{testpath}; export PATH=/usr/local/bin:/usr/local/sbin:$PATH; export PYTHONIOENCODING=UTF-8; export PYTHONPATH=#{ENV["PYTHONPATH"]}:$PYTHONPATH; python -m aeneas.diagnostics; python -m aeneas.tools.synthesize_text list "This is a test|with two lines" eng -v test.wav`
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
