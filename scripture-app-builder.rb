cask 'scripture-app-builder' do
  version '1.11.1'
  sha256 'd2abb7c221c99796f20b4b739c69eae6090987bb5fff80b0ed5877b0cc08c567'

  # software was verified as official when first introduced to the cask
  url 'http://software.sil.org/downloads/scriptureappbuilder/ScriptureAppBuilder-1.11.1.dmg'
  name 'Scripture App Builder'
  homepage 'http://software.sil.org/scriptureappbuilder/'
  license :apache

  depends_on cask: 'java'
  depends_on formula: 'aeneas'
  depends_on formula: 'android-sdk'

  app 'Scripture App Builder.app'

  # zap delete: [
  # "~/Library/Preferences/AndroidStudio#{version.major_minor}",
  # '~/Library/Preferences/com.google.android.studio.plist',
  # "~/Library/Application Support/AndroidStudio#{version.major_minor}",
  # "~/Library/Logs/AndroidStudio#{version.major_minor}",
  # "~/Library/Caches/AndroidStudio#{version.major_minor}",
  # ],

  uninstall rmdir:  '~/App Builder/Scripture Apps/'

  caveats do
    depends_on_java
  end
end
