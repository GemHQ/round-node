Round = require '../../src'
Account = require '../../src/resources/account'
Addresses = require '../../src/resources/addresses'
Transactions = require '../../src/resources/transactions'
Wallet = require '../../src/resources/wallet'
Payment = require '../../src/resources/payment'
PaymentGenerator = require '../../src/resources/payment_generator'
bitcoin = require 'bitcoinjs-lib'
bs58check = require 'bs58check'
bs58 = require 'bs58'

paymentResource = require('../data/transaction.json').payment

expect = require('chai').expect
fs = require "fs"
yaml = require "js-yaml"
string = fs.readFileSync "./test/data/wallet.yaml"
data = yaml.safeLoad(string)
credentials = require '../data/credentials'
{pubkey, privkey, newDevCreds, newUserContent, existingDevCreds, authenticateDeviceCreds} = credentials


describe 'Accounts Resource', ->
  client = developer = user = applications = accounts = account = wallet = ''

  before (done) ->
    Round.client 'http://localhost:8999','testnet3', (error, cli) ->
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


  describe 'account.payments', ->
    payments = null
    
    before ->
      payments = account.payments()

    it 'should return an instance of PaymentGenerator ', ->
      expect(payments).to.be.an.instanceof(PaymentGenerator)

    it 'should memoize the instance on @_payments', ->
      expect(account._payments).to.deep.equal(payments)

  describe.only 'account.pay', ->
    it 'should do stuff', (done) ->
      payees = [{amount: 2000, address: 'mrsjJDuBzhjPeHpdo6ivcbACCBQFcoWXmq'}]
      account.wallet.unlock("foo bar baz")
      payments = account.payments()
      account.addresses (error, addrs) ->

        payments.unsigned payees, (error, payment) ->
          expect(payment).to.be.an.instanceof(Payment)


          txb = new bitcoin.TransactionBuilder()
          paymentResource = payment.resource()
          {inputs, outputs} = paymentResource
          multiwallet = account.wallet._multiwallet

          # add inputs and outputs
          multiwallet.addInputs(inputs, txb)
          multiwallet.addOutputs(outputs, txb)

          path = multiwallet.getPathForInput(paymentResource ,0)
          pubKeys = multiwallet.getPubKeysForPath(path)
          privKey = multiwallet.getPrivKeyForPath(path)
          # utility
          redeemScript = multiwallet.createRedeemScript(pubKeys)

          hash = txb.sign(0, privKey, redeemScript)
          sig = txb.signatures[0].signatures[0]

          # encoded_sig = bs58.encode sig.toDER().toString('hex')
          hashType = txb.signatures[0].hashType
          encoded_sig = bs58.encode sig.toScriptSignature(hashType)


          transactionContent = {
            transaction_hash: txb.tx.getHash(),
            inputs: [{primary: encoded_sig}]
          }

          paymentResource.sign transactionContent, (error, data) ->
            console.log(error, data)
          
            done(error)





  describe 'account.wallet', ->
    it 'should reference the wallet it belongs to', ->
      expect(account.wallet).to.be.instanceof(Wallet)

  # Note: We may be removing client.account
  describe 'client.account', ->
    `var account`
    it 'should return an Account object', ->
      accountUrl = wallet.resource().accounts.url
      account = client.account accountUrl
      expect(account).to.be.an.instanceof(Account)

  # skipping because it creates a wallet for the same
  # user and therefor makes other calls really slow
  describe.skip 'accounts.create', ->
    `var account, name`

    before (done) ->
      name = "newAccount#{Date.now()}"
      accounts.create {name}, (error, accnt) ->
        account = accnt
        done(error)
  
    it 'should create a new Account object', () ->
      expect(account).to.be.an.instanceof(Account)

    it 'should memoize the new account', () ->
      wallet.accounts (error, accounts) ->
        expect(wallet._accounts.collection).to.have.a.property(name)


  # currently receiving a 401, not sure why
  describe.skip 'account.update', ->
    it 'should update the account resource', (done) ->
      name = "newname#{Date.now()}"
      account.resource().update {name}, (error, accountResource) ->
        console.log error, accountResource
        done()


  describe 'account.addresses', ->
    addresses = ''

    before (done) ->
      account.addresses (error, addrs) ->
        addresses = addrs
        done(error)

    it 'should return an Addresses object', ->
      expect(addresses).to.be.an.instanceof(Addresses)

    it 'should have a collection property', ->
      expect(addresses).to.have.a.property('collection')


  # account.resource().transactions returns a function
  # not a resource. Could be a bug in Patchboard
  describe 'account.transactions', ->
    it 'should return a transactions object', (done) ->
      account.resource().get (err, res) ->
        console.log res.trans
        done()
