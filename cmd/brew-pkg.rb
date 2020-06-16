#: Usage: brew pkg [options] formula
#:
#: Build an OS X installer package from a formula. It must be already
#: installed; 'brew pkg' doesn't handle this for you automatically. The
#: '--identifier-prefix' option is strongly recommended in order to follow
#: the conventions of OS X installer packages (Default 'org.homebrew').
#:
#: Options:
#:  --identifier-prefix     set a custom identifier prefix to be prepended
#:                          to the built package's identifier, ie. 'org.nagios'
#:                          makes a package identifier called 'org.nagios.nrpe'
#:  --with-deps             include all the package's dependencies in the build
#:  --without-kegs          exclude contents at /usr/local/Cellar/packagename
#:  --without-opt           exclude the link in /usr/local/opt
#:  --install-location      custom install location for package
#:  --preinstall-script     custom preinstall script file
#:  --postinstall-script    custom postinstall script file
#:  --scripts               custom preinstall and postinstall scripts folder
#:  --pkgvers               set the version string in the resulting .pkg file
#:  --debug                 print extra debug information

require 'formula'
require 'formulary'
require 'dependencies'
require 'shellwords'
require 'set'
require 'cmd/deps'
require 'optparse'
require 'tmpdir'
require 'ostruct'
require "cli/parser"
require "cleanup"
require 'pp'

module Homebrew
  module_function

  extend self

  def pkg_args
    Homebrew::CLI::Parser.new do
      usage_banner <<~EOS
      `pkg` [<options>] <formula>

      Build an OS X installer package from a formula. It must be already
      installed; 'brew pkg' doesn't handle this for you automatically. The
      '--identifier-prefix' option is strongly recommended in order to follow
      the conventions of OS X installer packages (Default 'org.homebrew').
      EOS
      flag "--identifier-prefix=",
             description: "set a custom identifier prefix to be prepended"\
                          "to the built package's identifier, ie. 'org.nagios'"\
                          "makes a package identifier called 'org.nagios.nrpe'"
      switch "--with-deps",
             description: "include all the package's dependencies in the build"
      switch "--without-kegs",
             description: "exclude contents at /usr/local/Cellar/packagename"
      switch "--without-opt",
             description: "exclude the link in /usr/local/opt"
      flag "--install-location=",
             description: "custom install location for package"
      flag "--preinstall-script=",
             description: "custom preinstall script file"
      flag "--postinstall-script=",
             description: "custom postinstall script file"
      flag "--scripts=",
             description: "custom preinstall and postinstall scripts folder"
      flag "--pkgvers=",
             description: "set the version string in the resulting .pkg file"
      switch "--debug",
             description: "print extra debug information"
      formula_options
      min_named :formula
    end
  end

  def pkg
    pkg_args.parse

    printf "DEBUG: args...\n" if ARGV.include? '--debug'
    pp ARGV if ARGV.include? '--debug'

    identifier_prefix = 'org.homebrew'
    if (args.identifier_prefix != nil)
      printf "DEBUG: --identifier-prefix=#{args.identifier_prefix}\n" if ARGV.include? '--debug'
      identifier_prefix = args.identifier_prefix
    end

    printf "DEBUG: brew pkg #{ARGV.last}\n" if ARGV.include? '--debug'
    f = Formulary.factory ARGV.last
    # raise FormulaUnspecifiedError if formulae.empty?
    # formulae.each do |f|
    name = f.name
    identifier = identifier_prefix + ".#{name}"
    version = f.version.to_s
    version += "_#{f.revision}" if f.revision.to_s != '0'

    # Make sure it's installed first
    if not f.latest_version_installed?
      onoe "#{f.name} is not installed. First install it with 'brew install #{f.name}'."
      abort
    end

    # Setup staging dir
    pkg_root = Dir.mktmpdir 'brew-pkg'
    staging_root = pkg_root + HOMEBREW_PREFIX
    ohai "Creating package staging root using Homebrew prefix #{HOMEBREW_PREFIX}"
    FileUtils.mkdir_p staging_root


    pkgs = [ARGV.last] # was [f] but this didn't allow taps with conflicting formula names.

    # Add deps if we specified --with-deps
    pkgs += f.recursive_dependencies if args.with_deps?

    pkgs.each do |pkg|
      printf "DEBUG: packaging formula #{pkg}\n" if ARGV.include? '--debug'
      formula = Formulary.factory(pkg.to_s)
      dep_version = formula.version.to_s
      dep_version += "_#{formula.revision}" if formula.revision.to_s != '0'

      ohai "Staging formula #{formula.name}"
      # Get all directories for this keg, rsync to the staging root
      if File.exists?(File.join(HOMEBREW_CELLAR, formula.name, dep_version))
        # dirs = Pathname.new(File.join(HOMEBREW_CELLAR, formula.name, dep_version)).children.select { |c| c.directory? }.collect { |p| p.to_s }
        dirs = ["etc", "bin", "sbin", "include", "share", "lib", "Frameworks"]
        # dirs.each {|d| safe_system "rsync", "-a", "#{d}", "#{staging_root}/" }
        dirs.each do |d|
          sourcedir = Pathname.new(File.join(HOMEBREW_CELLAR, formula.name, dep_version, d))
          if File.exists?(sourcedir)
            ohai "rsyncing #{sourcedir} to #{staging_root}"
            safe_system "rsync", "-a", "#{sourcedir}", "#{staging_root}/"
          end
        end
        if File.exists?("#{HOMEBREW_CELLAR}/#{formula.name}/#{dep_version}") and not ARGV.include? '--without-kegs'
          ohai "Staging directory #{HOMEBREW_CELLAR}/#{formula.name}/#{dep_version}"
          safe_system "mkdir", "-p", "#{staging_root}/Cellar/#{formula.name}/"
          safe_system "rsync", "-a", "#{HOMEBREW_CELLAR}/#{formula.name}/#{dep_version}", "#{staging_root}/Cellar/#{formula.name}/"
        end
        if File.exists?("/usr/local/opt/#{formula.name}") and not ARGV.include? '--without-opt' and not ARGV.include? '--without-kegs'
          ohai "Staging link in #{staging_root}/opt"
          FileUtils.mkdir_p "#{staging_root}/opt"
          safe_system "rsync", "-a", "/usr/local/opt/#{formula.name}", "#{staging_root}/opt"
        end
      end

      # Write out a LaunchDaemon plist if we have one
      if formula.plist
        ohai "Plist found at #{formula.plist_name}, staging for /Library/LaunchDaemons/#{formula.plist_name}.plist"
        launch_daemon_dir = File.join staging_root, "Library", "LaunchDaemons"
        FileUtils.mkdir_p launch_daemon_dir
        fd = File.new(File.join(launch_daemon_dir, "#{formula.plist_name}.plist"), "w")
        fd.write formula.plist
        fd.close
      end
    end

    # Add scripts if we specified --scripts 
    found_scripts = false
    if (args.scripts != nil)
      printf "DEBUG: --scripts=#{args.scripts}\n" if ARGV.include? '--debug'
      scripts_path = args.scripts
      if File.directory?(scripts_path)
        pre = File.join(scripts_path,"preinstall")
        post = File.join(scripts_path,"postinstall")
        if File.exists?(pre)
          File.chmod(0755, pre)
          found_scripts = true
          ohai "Adding preinstall script"
        end
        if File.exists?(post)
          File.chmod(0755, post)
          found_scripts = true
          ohai "Adding postinstall script"
        end
      end
      if not found_scripts
        opoo "No scripts found in #{scripts_path}"
      end
    end

    # Add scripts if we specified 
    found_scripts = false
    if (args.preinstall_script != nil)
      printf "DEBUG: --preinstall-script=#{args.preinstall_script}\n" if ARGV.include? '--debug'
      preinstall_script = args.preinstall_script
      if File.exists?(preinstall_script)
        scripts_path = Dir.mktmpdir "#{name}-#{version}-scripts"
        pre = File.join(scripts_path,"preinstall")
        safe_system "cp", "-a", "#{preinstall_script}", "#{pre}"
        File.chmod(0755, pre)
        found_scripts = true
        ohai "Adding preinstall script"
      end
    end
    if (args.postinstall_script != nil)
      printf "DEBUG: --postinstall-script=#{args.postinstall_script}\n" if ARGV.include? '--debug'
      postinstall_script = args.postinstall_script
      if File.exists?(postinstall_script)
        if not found_scripts
          scripts_path = Dir.mktmpdir "#{name}-#{version}-scripts"
	end
        post = File.join(scripts_path,"postinstall")
        safe_system "cp", "-a", "#{postinstall_script}", "#{post}"
        File.chmod(0755, post)
        found_scripts = true
        ohai "Adding postinstall script"
      end
    end

    # Custom ownership
    found_ownership = false
    if (args.ownership != nil)
      printf "DEBUG: --=#{}\n" if ARGV.include? '--debug'
      custom_ownership = args.ownership
       if ['recommended', 'preserve', 'preserve-other'].include? custom_ownership
        found_ownership = true
        ohai "Setting pkgbuild option --ownership with value #{custom_ownership}"
       else
        opoo "#{custom_ownership} is not a valid value for pkgbuild --ownership option, ignoring"
       end
    end

    # Custom install location
    found_installdir = false
    if (args.install_location != nil)
      printf "DEBUG: --=#{}\n" if ARGV.include? '--debug'
      install_dir = args.install_location
      found_installdir = true
        ohai "Setting install directory option --install-location with value #{install_dir}"
    end

    found_pkgvers = false
    if (args.pkgvers != nil)
      printf "DEBUG: --=#{}\n" if ARGV.include? '--debug'
      version = args.pkgvers
      found_pkgvers = true
      ohai "Setting pkgbuild option --version with value #{version}"
    end

    # Build it
    pkgfile = "#{name}-#{version}.pkg"
    ohai "Building package #{pkgfile}"
    pargs = [
      "--quiet",
      "--root", "#{pkg_root}",
      "--identifier", identifier,
      "--version", version
    ]
    if found_scripts
      pargs << "--scripts"
      pargs << scripts_path 
    end
    if found_ownership
      pargs << "--ownership"
      pargs << custom_ownership 
    end
    if found_installdir
      pargs << "--install-location"
      pargs << install_dir 
    end

    pargs << "#{pkgfile}"
    safe_system "pkgbuild", *pargs

    #FileUtils.rm_rf pkg_root
  end
end

Homebrew.pkg
exit 0
