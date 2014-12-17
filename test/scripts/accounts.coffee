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


          txb = new bitcoin.TransactionBuilder()
          paymentResource = payment.resource()

          # Add inputs to transaction
          paymentResource.inputs.forEach (input) ->
            prevTx = input.output.transaction_hash
            index = input.output.index
            txb.addInput(prevTx, index)

          # Add outputs to transaction
          paymentResource.outputs.forEach (output) ->
            address = output.address
            value = output.value
            txb.addOutput(address, value)


          # Generate a redeem script
          # backup cosigner and primary is the oder of pubkeys
          getPathForInput = (index) ->
            path = paymentResource.inputs[index].output.metadata.wallet_path
          

          parsePath = (path) ->
            parts = path.split('/')
            indices = parts.filter (part) ->
              part != 'm' and part != '0'


          deriveNodeForIndices = (parent, indices) ->
            node = parent

            indices.forEach (index) ->
              node = node.derive(index)

            return node


          getPubKeysForPath = (path) ->
            indices = parsePath(path)
            trees = account.wallet._multiwallet.trees
            
            masterNodes = ['cosigner', 'backup', 'primary'].map (nodeName) ->
              masterNode = trees[nodeName]
              deriveNodeForIndices(masterNode, indices)

            pubKeys = masterNodes.map (node) ->
              node.pubKey


          getPrivKeysForPath = (path) ->
            indices = parsePath(path)
            privateTrees = account.wallet._multiwallet.privateTrees
            privateTreeNames = Object.keys privateTrees

            privKeys = privateTreeNames.map (name) ->
              masterNode = privateTrees[name]
              derivedNode = deriveNodeForIndices(masterNode, indices)
              derivedNode.privKey


          createRedeemScript = (pubKeys, numberOfSigs=2) ->
            bitcoin.scripts.multisigOutput(numberOfSigs, pubKeys)


          path = getPathForInput(0)
          pubKeys = getPubKeysForPath(path)
          privKeys = getPrivKeysForPath(path)
          redeemScript = createRedeemScript(pubKeys)

          txb.sign(0, privKeys[0], redeemScript)

          sig = txb.signatures[0].signatures[0]
          hashType = txb.signatures[0].hashType
          encoded_sig = bs58check.encode sig.toScriptSignature(hashType)

          transactionContent = {
            transaction_hash: paymentResource.hash,
            inputs: [{primary: encoded_sig}]
          }

          paymentResource.sign transactionContent, (error, data) ->
            # console.log(error, data)
          
            done(error)















          # privateTrees = account.wallet._multiwallet.privateTrees
          # privateTreeNames = Object.keys privateTrees
          # # Returns an array of objects
          # # Each object contains the signatures for a input
          # # The key of the object is the name of the privKey
          # signatures = txb.tx.ins.map (input, index) ->
          #   signaturesForInput = {}

          #   # Signs input with every private key
          #   privateTreeNames.forEach (name) ->
          #     node = privateTrees[name]
          #     txb.sign(index, node.privKey, redeemScript)
          #     # txb.sign does not return the signature
          #     # therefor I have to grab it from its signatures array
          #     nativeSigsForInput = txb.signatures[index].signatures
          #     nativeSig = nativeSigsForInput[nativeSigsForInput.length - 1]

          #     signaturesForInput[name] = nativeSig

          #   return signaturesForInput


          # transactionContent = {
          #   inputs: signatures
          # }


          # primary_priv_key = account.wallet._multiwallet.privateTrees.primary.privKey
          # primary_pub_key = account.wallet._multiwallet.privateTrees.primary.pubKey
          # txb.sign(0, primary_priv_key, redeemScript)
          # nativeSig = txb.signatures[0].signatures[0]
          # final_tx = txb.build()
          # console.log final_tx
          # console.log paymentResource.inputs[0].output.metadata.wallet_path

          # tx_hash = final_tx.getHash()
          # console.log primary_pub_key.verify(tx_hash, nativeSig)





          # hashFromPayment = paymentResource.hash
          # tx_hash = txb.build().getHash()
          
          # signature_for_api = signatures[0].primary 
          # native_signature = txb.signatures[0].signatures[0]
          # signature_for_api == native_signature

          # pub_key_from_native = txb.signatures[0].pubKeys[0]
          # primary_pubkey = privateTrees.primary.pubKey
          # pub_key_from_native == primary_pubkey

          # console.log txb.tx.ins
          # console.log pub_key_from_native.verify(tx_hash, signature_for_api)
          # console.log node.pubKey.verify(paymentResource.hash, nativeSig)
        
          debugger
          # paymentResource.sign transactionContent, (error, data) ->
          #   console.log(error, data)
          
          # done(error)

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
