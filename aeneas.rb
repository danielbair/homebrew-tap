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

  depends_on "danielbair/tap/numpy"
  depends_on "danielbair/tap/lxml"
  depends_on "danielbair/tap/bs4"

  patch :DATA

  def install
    Language::Python.each_python(build) do |python, version|
      dest_path = lib/"python#{version}/site-packages"
      dest_path.mkpath
      system python, *Language::Python.setup_install_args(prefix)
      ln "VERSION", dest_path
      ln "check_dependencies.py", dest_path
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
