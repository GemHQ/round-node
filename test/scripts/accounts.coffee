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

        # payments.unsigned payees, (error, payment) ->
        #   expect(payment).to.be.an.instanceof(Payment)



        txb = new bitcoin.TransactionBuilder()
        paymentResource = JSON.parse fs.readFileSync(__dirname + '/transaction.json').toString()
        # paymentResource = payment.resource()

        # Add inputs to transaction
        paymentResource.inputs.forEach (input) ->
          prevTx = input.output.transaction_hash
          index = input.output.index
          nativeAddress = bitcoin.Address.fromBase58Check input.output.address
          prevOutScript = nativeAddress.toOutputScript()
          txb.addInput(prevTx, index, undefined, prevOutScript)

        # Add outputs to transaction
        paymentResource.outputs.forEach (output) ->
          address = output.address
          value = output.value
          # addOutput will convert address to scriptPubKey
          txb.addOutput(address, value)

        debugger


        getPathForInput = (index) ->
          path = paymentResource.inputs[index].output.metadata.wallet_path
        

        parsePath = (path) ->
          parts = path.split('/')
          # removes "m" from parts
          indices = parts.slice(1).map (index) ->
            # converts index to a number
            +index


        deriveNodeForIndices = (parent, indices) ->
          node = parent

          indices.forEach (index) ->
            node = node.derive(index)

          return node


        getPubKeysForPath = (path) ->
          indices = parsePath(path)
          trees = account.wallet._multiwallet.trees
          
          masterNodes = ['backup', 'cosigner', 'primary'].map (nodeName) ->
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

        
        hash = txb.sign(0, privKeys[0], redeemScript)
        # console.log hash
        sig = txb.signatures[0].signatures[0]
        # console.log pubKeys[2].verify(hash, sig)
        encoded_sig = bs58.encode sig.toDER().toString('hex')
        # hashType = txb.signatures[0].hashType
        # encoded_sig = bs58.encode sig.toScriptSignature(hashType)


        transactionContent = {
          transaction_hash: txb.tx.getHash(),
          inputs: [{primary: encoded_sig}]
        }

        # paymentResource.sign transactionContent, (error, data) ->
          # console.log(error, data)
        
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
