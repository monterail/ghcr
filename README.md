## GitHub Code Review Extension

Currently available for [chrome](source/chrome/README.md)

### Requirements
  - Chrome browser
  - [GHCR API endpoint](https://github.com/monterail/ghcr-api)

### Commit auto accept

Simply add `accept shortSHA1 or longSHA1` in your commit message.
Auto accept commit message example:
```
My commit message
accepts: 3bef5dz, 146239f5f237c990d07023296d39b29cfb31806e
```

### Ignoring commits

Ignored commits are automatically accepted.
Just add `[no review]` or `[skip review]` at the beginning of commit message.
Also merge commits are ignored (containing word `merge` in commit message).
Ignored commits examples:
```
[no review] Completly pointless commit
```
```
[skip review] assets precompiled
```
```
Merge branch awesome to develop
```

## Development

### Structure

`shared` folder contains all code, that is used by multiple extensions.
Folders for specific browser contains freely lying files for each
extension. Needed structure is created during build.

### Building

Firstly install all necessary dependencies.
```
bin/setup
```

Then there are several tasks.
```
grunt build   # build extensions along sourcemaps
grunt release # build zip for chrome extensions
grunt watch   # continously build extensions
```

For browser specific details check [chrome readme](source/chrome/README.md)
