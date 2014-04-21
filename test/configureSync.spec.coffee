# Copyright (c) 2014. David M. Lee, II <leedm777@yahoo.com>
'use strict'

expect = (require 'chai').expect
sinon = require 'sinon'
Promise = (require 'es6-promise').Promise

parfait = require '..'

###
  The configureSync function doesn't work yet, but I'll keep dreaming for the
  impossible.

  Is there any way to do this without reimplementing using fs.*Sync methods?
###
describe.skip 'The configureSync function', ->
  mock = null
  beforeEach ->
    mock = sinon.mock(parfait)

  afterEach ->
    mock.verify()


  it 'should return plain objects', ->
    expected = someConfig: 'data'
    mock.expects('configure')
      .once()
      .returns(Promise.resolve(expected))
    actual = parfait.configureSync { directory: 'some-config-directory' }
    expect(actual).to.deep.equal expected

  it 'should throw exceptions as needed', ->
    mock.expects('configure')
      .once()
      .returns(Promise.reject new Error 'Some Error')
    expect(-> parfait.configureSync { directory: 'some-config-directory' })
      .to.throw(Error, /^Some Error$/)
