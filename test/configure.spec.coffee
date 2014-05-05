# Copyright (c) 2014. David M. Lee, II <leedm777@yahoo.com>
'use strict'

expect = (require 'chai').expect

parfait = require '../src'

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
    expected = environment: 'development', foo: bar: 'simple-json'
    actual = parfait.configure { directory: 'test/simple-json.config' }
    expect(actual).to.eventually.deep.equal expected

  it 'should parse YAML', ->
    expected = environment: 'development', foo: bar: 'simple-yaml'
    actual = parfait.configure { directory: 'test/simple-yaml.config' }
    expect(actual).to.eventually.deep.equal expected

  it 'should parse multi-file config', ->
    expected =
      environment: 'development'
      foo: test: 'foo'
      bar: test: 'bar'
    actual = parfait.configure { directory: 'test/multi-file.config' }
    expect(actual).to.eventually.deep.equal expected

  it 'should parse subdir config', ->
    expected =
      environment: 'development'
      foo: test: 'foo'
      bar: bam: test: 'bam'
    actual = parfait.configure { directory: 'test/subdir.config' }
    expect(actual).to.eventually.deep.equal expected

  it 'should parse site and user configs', ->
    expected =
      environment: 'development',
      foo:
        'set-by-base': 'base'
        'set-by-user': 'user'
        'set-by-site': 'site'
      appdirs:
        siteConfigDir: 'test/site-user.config/site',
        userConfigDir: 'test/site-user.config/user'
    actual = parfait.configure {
      directory: 'test/site-user.config/base',
      preConfig:
        appdirs:
          siteConfigDir: 'test/site-user.config/site',
          userConfigDir: 'test/site-user.config/user'
    }
    expect(actual).to.eventually.deep.equal expected

  it 'should parse environment configs', ->
    expected =
      environment: 'test',
      foo:
        'set-by-base': 'base'
        'set-by-base-env': 'base-env'
        'set-by-user': 'user'
        'set-by-user-env': 'user-env'
        'set-by-site': 'site'
        'set-by-site-env': 'site-env'
      appdirs:
        siteConfigDir: 'test/env.config/site',
        userConfigDir: 'test/env.config/user'

    actual = parfait.configure {
      directory: 'test/env.config/base',
      environment: 'test',
      preConfig:
        appdirs:
          siteConfigDir: 'test/env.config/site',
          userConfigDir: 'test/env.config/user'
    }
    expect(actual).to.eventually.deep.equal expected

  describe 'using AppDirs', ->
    appdirs = require 'appdirs'
    origAppDirs = null

    before ->
      origAppDirs = appdirs.AppDirs
      appdirs.AppDirs = class
        ctor: (appName, appAuthor) ->
          expect(appName).to.equal('app-name')
          expect(appAuthor).to.equal('app-author')

        siteConfigDir: -> 'site-config'
        siteDataDir: -> 'site-data'
        userCacheDir: -> 'user-cache'
        userConfigDir: -> 'user-config'
        userDataDir: -> 'user-data'
        userLogDir: -> 'user-log'

    after ->
      appdirs.AppDirs = origAppDirs

    it 'should load in AppDirs', ->
      expected =
        environment: 'development'
        appdirs:
          appName: 'app-name'
          appAuthor: 'app-author'
          siteConfigDir: 'site-config'
          siteDataDir: 'site-data'
          userCacheDir: 'user-cache'
          userConfigDir: 'user-config'
          userDataDir: 'user-data'
          userLogDir: 'user-log'

      actual = parfait.configure {
        preConfig:
          appdirs:
            appName: 'app-name'
            appAuthor: 'app-author'
      }
      expect(actual).to.eventually.deep.equal expected
