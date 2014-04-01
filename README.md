# Parfait.js

[![Build Status](https://travis-ci.org/building5/parfaitjs.svg)](https://travis-ci.org/building5/parfaitjs)

A sweet multi-layered configuration framework.

## Dealing with complex configurations

Configuration usually starts out fairly simple. Just a config file,
some JSON describing a handful of settings. As your application or
framework grows, the configuration grows.

Eventually you want to break the configuration up into multiple files.
And have configuration vary depending on your environment. Or the
current user. Or the local machine. And that new guy runs on Windows,
so the files need to be stored in a different directory.

What was simple is no longer. Parfait is here to help!

Parfait can parse both JSON and YAML configuration files. JSON files
are first minified, so that they can contain comments. Parfait can
also read configuration from the user config (`~/.config/${appName}`
on Unixes) and site config (`/etc/${appName}` on Unixes), and properly
merge these configurations with the default configuration specified in
the application itself.

## Installation

Parfait.js is [hosted on NPM][], so you can simply install it, and add
it to your `package.json` as a dependency.

    $ npm install --save parfait

## How it works

In your application, simply invoke `parfait.configure()`. Its default
conventions are fairly reasonable, but you can override them if you
need to.

```JavaScript
var parfait = require('parfait');

var config = parfait.configure({
    // environment can be provided here, or by NODE_ENV.
    //environment: process.env.NODE_ENV || 'development',

    // The configuration directory may also be specified
    //directory: 'config'

    // Optionally, a hard-coded base config can be provided as a
    // starting point.
    config: {
      parfait: {
        // If specified, user and site config can be processed on Unixes
        'appName': 'SuperApp',
        // If specified, user and site config can be processed on Windows
        'appAuthor': 'Acme'
      }
    },
  });
```

Parfait parses the configuration files in the specified directory, and
builds a POJO model that directly maps to the files and file
structure. For example, If the file `foo.json` contains `{ "bar":
"bang" }`, then the config object will look like:

```JavaScript
{
  foo: {
    bar: 'bang'
  }
}
```

Once one directory is scanned, Parfait will scan the next, overlaying
the new settings on top of the prior settings.

Configuration is processed starting with the most general configuration,
overlaying it with the more specific configurations.

0. The hard-coded config provided to `configure()`
1. ${config} directory
2. ${config}/${environment}.env directory

If appName (and appAuthor on Windows) is set:
3. ${siteConfig} directory
4. ${siteConfig}/${environment}.env directory
5. ${userConfig} directory
6. ${userConfig}/${environment}.env directory

## Examples

The tests in the test directory actually do a fairly good job showing
an example configuration, and what the expected output from that
configuration should be.

## TODO

 * Array append/prepend (either single item or another array)
```yaml
# Append 'bar' to the array 'foo'
"foo+": "bar"
# Append 'bar', 'bam', 'bang' to the array 'foo'
"foo+": [ "bar", "bam", "bang" ]
# Prepend 'bar' to the array 'foo'
"+foo": "bar"
```
 * Object replacement instead of merging
```yaml
# Discard 'foo' and replace with empty object
"foo=": {}
# Discard 'foo' and replace with given object
"foo=": { "bar": 3.14159 }
```
 * Individual key deleltion
```yaml
# Remove 'foo'
"foo-": null
```

 [hosted on NPM]: https://www.npmjs.org/package/parfait
