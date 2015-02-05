
Round = require '../../src'
Account = require '../../src/resources/account'
Addresses = require '../../src/resources/addresses'
Transactions = require '../../src/resources/transactions'
PaymentGenerator = require '../../src/resources/payment_generator'

paymentResource = require '../data/transaction.json'

expect = require('chai').expect
fs = require "fs"
yaml = require "js-yaml"
string = fs.readFileSync "./test/data/wallet.yaml"
data = yaml.safeLoad(string)
credentials = require '../data/credentials'
{pubkey, privkey, newDevCreds, newUserContent, existingDevCreds, authenticateDeviceCreds} = credentials


describe.skip 'Payments', ->
  client = developer = user = applications = accounts = account = wallet = ''

  before (done) ->
    Round.client {url: 'http://localhost:8999'}, (error, cli) ->
      cli.authenticateDeveloper existingDevCreds, (error, dev) ->
        dev.applications (error, apps) ->
          client = cli; developer = dev; applications = apps;

          client.authenticateDevice authenticateDeviceCreds(applications), (error, usr) ->
            user = usr
            user.wallets (error, wallets) ->
              wallet = wallets.collection.default
              wallet.accounts (error, accnts) ->
                accounts = accnts
                account = accounts.collection.default
                done(error)


  describe 'Payment Generator', ->
    
    describe 'paymentGenerator.outputsFromPayees', ->
    
      it "should return an array of {} with 'amount' and 'payee' keys", ->
        amount1 = 100; address1 = 'somerandomeaddress'
        amount2 = 200; address2 = 'someotherrandomeaddress'

        payments = new PaymentGenerator(account.resource().payments)
        payees = [{amount: amount1, address: address1},
                  {amount: amount2, address: address2}]
        
        outputs = payments.outputsFromPayees(payees)
        expectedResult = {outputs: [
          {amount: amount1, payee: {address: address1}},
          {amount: amount2, payee: {address: address2}}
          ]}
        expect(outputs).to.deep.equal(expectedResult)

