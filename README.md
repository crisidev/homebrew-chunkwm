# homebrew-chunkwm
Homebrew Tap for Chunkwm tiling window manage (https://github.com/koekeishiya/chunkwm)

**NOTE: plugins folder has been moved to /usr/local/opt/chunkwm/share/chunkwm/plugins**

## Table of contents
1. [Supported OSX versions](#supported-osx-versions)
2. [Brew Options](#brew-options)
2. [Caveats](#caveats)
3. [Usage examples](#usage-examples)


## Supported OSX versions
Chunkwm worsk with MacOSX >= 10.11

## Brew options
```
--with-logging
	Redirect stdout and stderr to log files
--with-transparency
	Build transparency plugin.
--without-border
	Do not build border plugin.
--without-ffm
	Do not build focus-follow-mouse plugin.
--without-tiling
	Do not build tiling plugin.
--HEAD
	Install HEAD version
```

## Caveats
Copy the example configuration into your home directory:

```
cp /usr/local/opt/chunkwm/share/chunkwm/examples/chunkwmrc ~/.chunkwmrc
```

Opening chunkwm will prompt for Accessibility API permissions. After access
has been granted, the application must be restarted:

```
brew services restart chunkwm
```

### Codesign chunkwm binary
Accessibility API must be granted after every update to chunkwm, unless you codesign the
binary with self-signed certificate before restarting

Create code signing certificate named "chunkwm-cert" using Keychain Access.app:

* Open Keychain Access.app
* From menu select ```Keychain Access -> Certificate Assistant -> Create a certificate```
* Fill the certificate form:
    * Name: chunkwm-cert
    * Identity Type: Self Signed Root
    * Certificate Type: Code Signing

Sign the binary:

```  
codesign -fs "chunkwm-cert" /usr/local/opt/chunkwm/bin/chunkwm
```

To have launchd start crisidev/chunkwm/chunkwm now and restart at login:

```
brew services start crisidev/chunkwm/chunkwm
```

Or, if you don't want/need a background service you can just run:

```  
chunkwm
```

### Logging
If the formula has been built with ```--with-logging```, logs will be found in

```
/usr/local/var/log/chunwm/chunkwm.[out|err].log
```

## Usage examples
### Clone tap
```
brew tap crisidev/homebrew-chunkwm
```

### Install latest stable version
```
brew install chunkwm
```

### Install from git repo
```
brew install --HEAD chunkwm
```

### Do not install border, tiling, and ffm plugins
```
brew install --without-border --without-tiling --without-ffm chunkwm
```
