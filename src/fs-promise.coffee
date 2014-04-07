# Copyright (c) 2014. David M. Lee, II <leedm777@yahoo.com>
'use strict'

Promise = (require 'es6-promise').Promise
fs = require 'fs'

###
  Read a UTF-8 text file, returning a promise with the file's contents.

  @param {String} path Path of the file to read.
  @return {Promise<String>} Contents of the file.
  @private
###
readFile = (path) ->
  new Promise (resolve, reject) ->
    fs.readFile path, 'utf-8', (err, contents) ->
      if (err)
        reject err
      else
        resolve contents

###
  Promise returning version of `fs.stat`.

  @param {String} path Path of the file to stat.
  @return {Promise<fs.Stat>} File's stat structure.
  @private
###
stat = (path) ->
  new Promise (resolve, reject) ->
    fs.stat path, (err, stat) ->
      if (err)
        reject err
      else
        resolve stat

###
  Promise returning version of `fs.readdir`.

  @param {String} directory Directory to read.
  @return {Promise<Array<String>>} Filenames in the given directory.
  @private
###
readdir = (directory) ->
  new Promise (resolve, reject) ->
    fs.readdir directory, (err, dir) ->
      if (err)
        reject err
      else
        resolve dir

module.exports = {readFile, stat, readdir}
