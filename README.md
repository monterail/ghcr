# GitHub Code Review Extension

Currently available for [chrome](chrome/README.md) and [firefox](firefox/README.md)

## Commit auto accept

Simply add `accept shortSHA1 or longSHA1` in your commit message.
Auto accept commit message example:
```
My commit message
accepts: 3bef5dz, 146239f5f237c990d07023296d39b29cfb31806e
```

### Ignoring commits

Ignored commits are automatically accepted.
Just add `#noreview` or `skip code review` to commit message.
Also merge commits are ignored (containing word `merge` in commit message).
Ignored commits examples:
```
Completly pointless commit
#skipreview
```
```
assets precompiled
no code review
```
```
Merge branch awesome to develop
```

### Screenshots

![](http://dl.dropbox.com/u/70986/Screenshots/5t.png)
![](http://dl.dropbox.com/u/70986/Screenshots/5u.png)
![](http://dl.dropbox.com/u/70986/Screenshots/5v.png)

## Development

### Structure

`shared` folder contains all code, that is used by multiple extensions.
Folders for specific browser contains freely lying files for each
extension. Needed structure is created during build.

### Building

Firstly install all necessary dependencies.
```
brew install graphicsmagick # For icon resizing
gem install sass
npm install
npm install -g grunt-cli
```

Then there are several tasks.
```
grunt build   # build extensions along sourcemaps
grunt release # build zip (for chrome) and xpi (for firefox) archives of extensions
grunt watch   # continously build extensions
```

For browser specific details check [chrome readme](chrome/README.md)
and [firefox readme](firefox/README.md).
