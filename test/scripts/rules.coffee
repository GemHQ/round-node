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


describe 'Rules Resource', ->

  describe.skip 'rule.set', ->
    it 'should set a rule', ->

  describe.skip 'rule.delet', ->
    it 'should delete a rule'