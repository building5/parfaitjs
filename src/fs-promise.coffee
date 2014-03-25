# Copyright (c) 2014. David M. Lee, II <leedm777@yahoo.com>
'use strict'

fs = require 'fs'
Q = require 'q'

###
  Read a UTF-8 text file, returning a promise with the file's contents.

  @param {String} path Path of the file to read.
  @return {Promise<String>} Contents of the file.
  @private
###
readFile = (path) ->
  Q.nfcall fs.readFile, path, 'utf-8'

###
  Promise returning version of `fs.stat`.

  @param {String} path Path of the file to stat.
  @return {Promise<fs.Stat>} File's stat structure.
  @private
###
stat = (path) ->
  Q.nfcall fs.stat, path

###
  Promise returning version of `fs.readdir`.

  @param {String} directory Directory to read.
  @return {Promise<Array<String>>} Filenames in the given directory.
  @private
###
readdir = (directory) ->
  Q.nfcall fs.readdir, directory

module.exports = {readFile, stat, readdir}
