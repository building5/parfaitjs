# Copyright (c) 2014. David M. Lee, II <leedm777@yahoo.com>
'use strict'

_ = require('lodash')

###
  Determines whether an object is a plain old JavaScript object (meaning not an
  array, function, etc.)

  @param {*} obj - Object to test.
  @return {Boolean} - True if obj is a POJO.
  @private
###
isPojo = (obj) ->
  _.isObject(obj) and not (
    _.isArray(obj) or
    _.isFunction(obj) or
    _.isRegExp(obj) or
    _.isNumber(obj) or
    _.isString(obj)
  )

###
  Merge a source object into the target object.

  Only POJO's can be merged. If either object is a non-POJO, then the value of
  source is simply returned.

  @param {*} target - Destination object to merge into.
  @param {*} source - Source object to merge from.
  @return {*} - Newly merged value for target.
###
confmerge = (target, source) ->
  if isPojo(target) and isPojo(source)
    # Both objects are POJOs; merge them!
    for key, value of source
      target[key] = confmerge target[key], value
    target
  else
    # One or both objects are not a POJO; they can't possibly be merged.
    # Replace target with source instead.
    source

module.exports = confmerge
