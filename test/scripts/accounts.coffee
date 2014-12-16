Round = require '../../src'
Account = require '../../src/resources/account'
Addresses = require '../../src/resources/addresses'
Transactions = require '../../src/resources/transactions'
Wallet = require '../../src/resources/wallet'
Payment = require '../../src/resources/payment'
PaymentGenerator = require '../../src/resources/payment_generator'
bitcoin = require 'bitcoinjs-lib'
bs58check = require 'bs58check'

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
      payees = [{amount: 100, address: 'mrsjJDuBzhjPeHpdo6ivcbACCBQFcoWXmq'}]
      account.wallet.unlock("foo bar baz")
      payments = account.payments()
      account.addresses (error, addrs) ->
        # console.log addrs
        # console.log "Addresses----------------------------"
        payments.unsigned payees, (error, payment) ->
          expect(payment).to.be.an.instanceof(Payment)
          # console.log payment.resource()
          # console.log "Payment resource----------------------------"
          # console.log payment.resource().inputs[0].output
          # console.log "Input's Output----------------------------"
          # console.log "wallet----------------------------"
          # console.log payment.resource()
          # console.log "payment resource----------------------------"
          # console.log payment.resource().outputs[1].metadata.path
          # console.log "path----------------------------"
          # console.log account.wallet._multiwallet
          # console.log "path----------------------------"


          tx = new bitcoin.Transaction()
          paymentResource = payment.resource()

          # Add inputs to transaction
          paymentResource.inputs.forEach (input) ->
            prevTx = input.output.transaction_hash
            index = input.output.index
            tx.addInput(prevTx, index)

          # Add outputs to transaction
          paymentResource.outputs.forEach (output) ->
            address = output.address
            value = output.value
            tx.addOutput(address, value)

          # Create a bitcoinjs TransactionBuilder
          primaryPrivKey = account.wallet._multiwallet.privateTrees.primary.privKey
          txb = bitcoin.TransactionBuilder.fromTransaction(tx)

          # Generate a redeem script
          trees = account.wallet._multiwallet.trees
          treeNames = Object.keys trees
          pubKeys = treeNames.map (name) ->
            node = trees[name]
            node.pubKey
          numberOfSignaturesRequired = 2
          redeemScript = bitcoin.scripts.multisigOutput(numberOfSignaturesRequired, pubKeys)

          
          privateTrees = account.wallet._multiwallet.privateTrees
          privateTreeNames = Object.keys privateTrees
          # Returns an array of objects
          # Each object contains the signatures for a input
          # The key of the object is the name of the privKey
          signatures = txb.tx.ins.map (input, index) ->
            signaturesForInput = {}

            # Signs input with every private key
            privateTreeNames.forEach (name) ->
              node = privateTrees[name]
              txb.sign(index, node.privKey, redeemScript)
              # txb.sign does not return the signature
              # therefor I have to grab it from its signatures array
              nativeSigsForInput = txb.signatures[index].signatures
              indexOfLastSignature = nativeSigsForInput.length - 1
              nativeSig = nativeSigsForInput[indexOfLastSignature]
              r = bs58check.encode nativeSig.r.toBuffer()
              s = r = bs58check.encode nativeSig.s.toBuffer()
              sig = r + s
              signaturesForInput[name] = sig

            return signaturesForInput

          transactionContent = {
            transaction_hash: txb.tx.getHash().toString('hex'),
            inputs: signatures
          }
          console.log transactionContent.inputs

          # console.log bs58check(signatures[0].primary.toCompact())
          debugger
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
