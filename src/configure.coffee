Q = require 'q'
path = require 'path'
jsyaml = require 'js-yaml'
appdirsDefault = require 'appdirs'
confmerge = require './confmerge'

{readFile, stat, readdir} = require './fs-promise'

###
  Process configuration files.

  @param {String} environment Environment to select.
  @param {String} directory Directory to process configuration files.
  @param {*} config Base configuration to start with.
  @param {appdirs} appdirs Methods `siteDataDir` and `userDataDir` for locating site and user data directories, respectively.
  @return {Promise<Object>} Consolidated configuration object.
###
configure = ({environment, directory, preConfig, appdirs}) ->
  environment ?= (process.env && process.env.NODE_ENV) || 'development'
  directory ?= 'config'
  preConfig ?= {}
  appdirs ?= appdirsDefault

  envDirectory = (dir) ->
    if dir
      path.join dir, "#{environment}.env"

  # Apply the base config to the hard coded preConfig
  processDirectory directory, preConfig
    .then (baseConfig) ->
      # Now the environment specific base config
      processDirectory envDirectory(directory), baseConfig
    .then (baseEnvConfig) ->
      parfait = baseEnvConfig.parfait || {}

      if parfait.appName
        siteDir = appdirs.siteDataDir(parfait.appName, parfait.appAuthor)
        userDir = appdirs.userDataDir(parfait.appName, parfait.appAuthor)

      # Now the site config
      processDirectory siteDir, baseEnvConfig
        .then (siteConfig) ->
          # Now the environment specific site config
          processDirectory envDirectory(siteDir), siteConfig
        .then (siteEnvConfig) ->
          # Now the user config
          processDirectory userDir, siteEnvConfig
        .then (userConfig) ->
          # Now the environment specific user config
          processDirectory envDirectory(userDir), userConfig

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
    Q.fulfill baseConfig
  else
    readdir directory
      .then (dir) ->
        Q.all dir.map (file) -> process(directory, file)
      .then (res) ->
        res.reduce confmerge, baseConfig
      .fail (err) ->
        # Missing directories are fine; just return the base config
        if err.code != 'ENOENT'
          console.error "Error reading directory: #{err.message}"
          throw err
        Q.fulfill baseConfig


###
  Process a configuration file, or directory of files. A Promise of its
  corresponding configuration object is returned.

  @param basedir Directory `file` is in.
  @param file Name of the file to parse.
  @return {Promise<Object?} Resulting merged configuration.
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
    Q.resolve {}
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
