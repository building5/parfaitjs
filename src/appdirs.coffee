path = require 'path'

###
  Given an application and author name, locate the site configuration
  directory. (e.g., `/etc/#{appName}`).

  If the site configuration directory cannot be determined, `undefined` is
  returned.

  @param {String} appName - Application name.
  @param {String} appAuthor - Application author's name.
###
siteDataDir = (appName, appAuthor) ->
  if (appName)
    path.join('/etc', appName)

###
  Given an application and author name, locate the user configuration
  directory. (e.g., `~/.config/#{appName}`)

  If the user configuration directory cannot be determined, `undefined` is
  returned.

  @param {String} appName - Application name.
  @param {String} appAuthor - Application author's name.
###
userDataDir = (appName, appAuthor) ->
  if (appName)
    path.join(process.env.HOME, '.config', appName)

module.exports = {siteDataDir, userDataDir}
