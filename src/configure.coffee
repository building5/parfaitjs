# Copyright (c) 2014. David M. Lee, II <leedm777@yahoo.com>
'use strict'

Promise = (require 'es6-promise').Promise
appdirs = require 'appdirs'
confmerge = require './confmerge'
jsyaml = require 'js-yaml'
path = require 'path'

{readFile, stat, readdir} = require './fs-promise'

###
  Process configuration files.

  @param {String} environment Environment to select.
  @param {String} directory Directory to process configuration files.
  @param {*} preConfig Base configuration to start with.
  @param {*} postConfig Config to merge on top of final result.
  @return {Promise<Object>} Consolidated configuration object.
###
configure = ({environment, directory, preConfig, postConfig}) ->
  environment ?= (process.env && process.env.NODE_ENV) || 'development'
  directory ?= 'config'
  preConfig ?= {}
  postConfig ?= {}

  envDirectory = (dir) ->
    if dir
      path.join dir, "#{environment}.env"

  # Apply the base config to the hard coded preConfig
  processDirectory directory, preConfig
    .then (baseConfig) ->
      # Now the environment specific base config
      processDirectory envDirectory(directory), baseConfig
    .then (baseEnvConfig) ->
      app = baseEnvConfig.appdirs || {}
      appName = app.appName
      appAuthor = app.appAuthor

      if appName
        a = new appdirs.AppDirs(appName, appAuthor)
        app.siteConfigDir ?= a.siteConfigDir()
        app.siteDataDir ?= a.siteDataDir()
        app.userCacheDir ?= a.userCacheDir()
        app.userConfigDir ?= a.userConfigDir()
        app.userDataDir ?= a.userDataDir()
        app.userLogDir ?= a.userLogDir()

      # Now the site config
      processDirectory app.siteConfigDir, baseEnvConfig
        .then (siteConfig) ->
          # Now the environment specific site config
          processDirectory envDirectory(app.siteConfigDir), siteConfig
        .then (siteEnvConfig) ->
          # Now the user config
          processDirectory app.userConfigDir, siteEnvConfig
        .then (userConfig) ->
          # Now the environment specific user config
          processDirectory envDirectory(app.userConfigDir), userConfig
        .then (userEnvConfig) ->
          confmerge userEnvConfig, postConfig

###
  Process a directory for configuration files, merging with baseConfig.

  Each file and subdirectory in `directory` is merged with the field in
  `baseConfig` of the corresponding name.

  @param {String} directory - Directory to parse configuration files from.
  @param {Object} baseConfig - Base configuration to merge into.
  @return {Promise<Object>} Resulting merged configuration.
  @private
###
processDirectory = (directory, baseConfig) ->
  if not directory
    Promise.resolve baseConfig
  else
    readdir directory
      .then (dir) ->
        Promise.all dir.map (file) -> process(directory, file)
      .then (res) ->
        res.reduce confmerge, baseConfig
      .catch (err) ->
        # Missing directories are fine; just return the base config
        if err.code != 'ENOENT'
          console.error "Error reading directory: #{err.message}"
          throw err
        Promise.resolve baseConfig


###
  Process a configuration file, or directory of files. A Promise of its
  corresponding configuration object is returned.

  @param basedir Directory `file` is in.
  @param file Name of the file to parse.
  @return {Promise<Object>} Resulting merged configuration.
  @private
###
process = (basedir, file) ->
  ext = path.extname file
  basename = path.basename file, ext
  file = path.join basedir, file
  if ext == '.json'
    readFile file
      .then (contents) ->
        res = {}
        res[basename] = JSON.parse(contents)
        res
  else if ext == '.yaml'
    readFile file
      .then (contents) ->
        res = {}
        res[basename] = jsyaml.safeLoad(contents)
        res
  else if ext == '.env'
    # Environment; skip
    Promise.resolve {}
  else
    stat file
      .then (stats) ->
        if stats.isDirectory()
          processDirectory file, {}
        else
          console.error "Unrecognized file type '#{file}'"
          {}
      .then (subConfig) ->
        res = {}
        res[basename] = subConfig
        res

module.exports = configure
