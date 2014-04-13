# Copyright (c) 2014. David M. Lee, II <leedm777@yahoo.com>
'use strict'

chai = require 'chai'
chaiAsPromised = require 'chai-as-promised'

chai.config.includeStack = true
chai.use chaiAsPromised

if process.env.COVERAGE == 'true'
  console.log 'Enabling code coverage'
  require('blanket')()
