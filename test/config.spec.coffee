# Copyright (c) 2014. David M. Lee, II <leedm777@yahoo.com>
'use strict'

expect = (require 'chai').expect

parfait = require '..'

class MockAppDirs
  constructor: (@basedir) ->

  siteDataDir: (appName, appAuthor) ->
    expect(appName).to.equal('someApp')
    expect(appAuthor).to.equal('someAuthor')
    "#{@basedir}/site"

  userDataDir: (appName, appAuthor) ->
    expect(appName).to.equal('someApp')
    expect(appAuthor).to.equal('someAuthor')
    "#{@basedir}/user"


describe 'For sample configs', ->
  it 'should parse JSON', ->
    expected = foo: bar: 'simple-json'
    actual = parfait.configure { directory: 'test/simple-json.config' }
    expect(actual).to.eventually.deep.equal expected

  it 'should parse YAML', ->
    expected = foo: bar: 'simple-yaml'
    actual = parfait.configure { directory: 'test/simple-yaml.config' }
    expect(actual).to.eventually.deep.equal expected

  it 'should parse multi-file config', ->
    expected =
      foo: test: 'foo'
      bar: test: 'bar'
    actual = parfait.configure { directory: 'test/multi-file.config' }
    expect(actual).to.eventually.deep.equal expected

  it 'should parse subdir config', ->
    expected =
      foo: test: 'foo'
      bar: bam: test: 'bam'
    actual = parfait.configure { directory: 'test/subdir.config' }
    expect(actual).to.eventually.deep.equal expected

  it 'should parse site and user configs', ->
    expected =
      foo:
        'set-by-base': 'base'
        'set-by-user': 'user'
        'set-by-site': 'site'
      parfait:
        appName: 'someApp',
        appAuthor: 'someAuthor'
    actual = parfait.configure {
      directory: 'test/site-user.config/base',
      preConfig:
        parfait:
          appName: 'someApp',
          appAuthor: 'someAuthor'
      appdirs: new MockAppDirs('test/site-user.config')
    }
    expect(actual).to.eventually.deep.equal expected

  it 'should parse environment configs', ->
    expected =
      foo:
        'set-by-base': 'base'
        'set-by-base-env': 'base-env'
        'set-by-user': 'user'
        'set-by-user-env': 'user-env'
        'set-by-site': 'site'
        'set-by-site-env': 'site-env'
      parfait:
        appName: 'someApp',
        appAuthor: 'someAuthor'

    actual = parfait.configure {
      directory: 'test/env.config/base',
      environment: 'test',
      preConfig:
        parfait:
          appName: 'someApp',
          appAuthor: 'someAuthor'
      appdirs: new MockAppDirs('test/env.config')
    }
    expect(actual).to.eventually.deep.equal expected
