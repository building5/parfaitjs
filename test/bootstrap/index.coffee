
if process.env.COVERAGE = 'true'
  console.error 'Enabling code coverage'
  require('blanket')()
