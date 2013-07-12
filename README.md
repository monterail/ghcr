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

## Development

### Structure

`shared` folder contains all code, that is used by multiple extensions.
Folders for specific browser contains freely lying files for each
extension. Needed structure is created during build.

### Building

To build any of the addon simply run `cake build:chrome` or `cake build:firefox`.
Folder with compiled js will appear in `builds` folder and can be used
to test on particular browser. For details check specific browser README.

You can use `cake watch` to continously build for chrome and firefox

## Monterail API URL

```
http://monterail:Wy4L6s8T@webhooker.mh2.monterail.eu/ghcr
```
