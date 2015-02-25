Round = require '../../src'
Developer = require '../../src/resources/developer'
Applications = require '../../src/resources/applications'
Application = require '../../src/resources/application'

expect = require('chai').expect
fs = require "fs"
yaml = require "js-yaml"
string = fs.readFileSync "./test/data/wallet.yaml"
data = yaml.safeLoad(string)
credentials = require '../data/credentials'
{pubkey, privkey, newDevCreds} = credentials

url = 'http://localhost:8999'

describe.skip 'Transactions Resource', ->

  describe 'transaction.cancel', ->
    it 'should cancel the transaction'
