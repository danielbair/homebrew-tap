class Numpy < Formula
  desc "Package for scientific computing with Python"
  homepage "http://www.numpy.org"
  url "https://files.pythonhosted.org/packages/16/f5/b432f028134dd30cfbf6f21b8264a9938e5e0f75204e72453af08d67eb0b/numpy-1.11.2.tar.gz"
  sha256 "04db2fbd64e2e7c68e740b14402b25af51418fc43a59d9e54172b38b906b0f69"
  head "https://github.com/numpy/numpy.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "653564e102fc276673a648db00a8409de58c2d405e3f009fe2fca48341dc546b" => :sierra
    sha256 "adcc6904722700f4540e6d3346d06ad183dbb44103840cbf0ba2907e331878e2" => :el_capitan
    sha256 "5f4a1549cf8d89437dabce3bcc7f2f7e2ea7ab22a328824d0c9efe4427a52c31" => :yosemite
  end

  head do
    url "https://github.com/numpy/numpy.git"

    resource "Cython" do
      url "https://pypi.python.org/packages/c6/fe/97319581905de40f1be7015a0ea1bd336a756f6249914b148a17eefa75dc/Cython-0.24.1.tar.gz"
      sha256 "84808fda00508757928e1feadcf41c9f78e9a9b7167b6649ab0933b76f75e7b9"
    end
  end

  option "without-python", "Build without python2 support"

  depends_on :python => :recommended if MacOS.version <= :snow_leopard
  depends_on :python3 => :optional
  depends_on :fortran => :build

  option "without-check", "Don't run tests during installation"
  option "with-openblas", "Use openBLAS instead of Apple's Accelerate Framework"
  depends_on "homebrew/science/openblas" => (OS.mac? ? :optional : :recommended)

  resource "nose" do
    url "https://pypi.python.org/packages/source/n/nose/nose-1.3.7.tar.gz"
    sha256 "f1bffef9cbc82628f6e7d7b40d7e255aefaa1adb6a1b1d26c69a8b79e6208a98"
  end

  def install
    # https://github.com/numpy/numpy/issues/4203
    # https://github.com/Homebrew/homebrew-python/issues/209
    if OS.linux?
      ENV.append "LDFLAGS", "-shared"
      ENV.append "FFLAGS", "-fPIC"
    end

    if build.with? "openblas"
      openblas_dir = Formula["openblas"].opt_prefix
      # Setting ATLAS to None is important to prevent numpy from always
      # linking against Accelerate.framework.
      ENV["ATLAS"] = "None"
      ENV["BLAS"] = ENV["LAPACK"] = "#{openblas_dir}/lib/libopenblas.dylib"

      config = <<-EOS.undent
        [openblas]
        libraries = openblas
        library_dirs = #{openblas_dir}/lib
        include_dirs = #{openblas_dir}/include
      EOS
      (buildpath/"site.cfg").write config
    end

    Language::Python.each_python(build) do |python, version|
      dest_path = lib/"python#{version}/site-packages"
      dest_path.mkpath

      nose_path = libexec/"nose/lib/python#{version}/site-packages"
      resource("nose").stage do
        system python, *Language::Python.setup_install_args(libexec/"nose")
        (dest_path/"homebrew-numpy-nose.pth").write "#{nose_path}\n"
      end

      if build.head?
        ENV.prepend_create_path "PYTHONPATH", buildpath/"tools/lib/python#{version}/site-packages"
        resource("Cython").stage do
          system python, *Language::Python.setup_install_args(buildpath/"tools")
        end
      end

      system python, "setup.py",
        "build", "--fcompiler=gnu95", "--parallel=#{ENV.make_jobs}",
        "install", "--prefix=#{prefix}",
        "--single-version-externally-managed", "--record=installed.txt"

      if build.with? "check"
        cd HOMEBREW_TEMP do
          with_environment({
            "PYTHONPATH" => "#{dest_path}:#{nose_path}",
            "PATH" => "#{bin}:#{ENV["PATH"]}"}) do
              system python, "-c", "import numpy; assert numpy.test().wasSuccessful()"
            end
        end
      end
    end
  end

  def with_environment(h)
    old = Hash[h.keys.map { |k| [k, ENV[k]] }]
    ENV.update h
    begin
      yield
    ensure
      ENV.update old
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
    system "python", "-c", <<-EOS.undent
      import numpy as np
      t = np.ones((3,3), int)
      assert t.sum() == 9
      assert np.dot(t, t).sum() == 27
    EOS
  end
end
