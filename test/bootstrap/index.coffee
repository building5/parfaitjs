# Copyright (c) 2014. David M. Lee, II <leedm777@yahoo.com>
'use strict'

if process.env.COVERAGE = 'true'
  console.error 'Enabling code coverage'
  require('blanket')()
