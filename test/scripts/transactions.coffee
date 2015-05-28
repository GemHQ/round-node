Round = require('../../src')
Account = require('../../src/resources/account')
Transaction = require('../../src/resources/transaction')
Transactions = require('../../src/resources/transactions')
expect = require('chai').expect
credentials = require('../data/credentials')
devCreds = credentials.developer
url = credentials.url


describe 'Transactions Resource', ->
  accounts = null
  before (done) ->
    Round.client {url}, (error, cli) ->
      {api_token, admin_token, totp_secret} = devCreds
      cli.authenticate_application {api_token, admin_token, totp_secret}, (error, app) ->
        app.wallets (error, wallts) ->
          wallet = wallts.get(0)
          wallet.accounts (error, accnts) ->
            accounts = accnts
            done(error)


  describe 'Transaction', ->
    transactions = null
    before (done) ->
      accounts.get('dogecoin').transactions (error, txs) ->
        transactions = txs
        done(error)
    
    describe 'transaction.cancel', ->
      it 'should cancel the transaction', (done) ->
        transactions.get(0).cancel (error, tx) ->
          expect(tx).to.be.an.instanceof(Transaction)
          expect(tx.status).to.equal('canceled')
          done(error)


  describe 'Cancel Txs', ->
    transactions = null
    before (done) ->
      accounts.get('dogecoin').transactions (error, txs) ->
        transactions = txs
        done(error)

    describe.only 'cancel all unsigned transactions', ->
      it 'should cancel all unsigned txs', (done) ->
        
        cancelAllTxs = (transactions, i, canceledTxs, cb) ->
          len = transactions.length
          if i >= len
            return cb(null, canceledTxs)
          else
            tx = transactions[i]
            if tx.status == 'unsigned'
              tx.cancel (error, tx) ->
                return cb(error) if error
                canceledTxs.push(tx)
                cancelAllTxs(transactions, i+1, canceledTxs, cb)
            else
              cancelAllTxs(transactions, i+1, canceledTxs, cb)
        
        console.log transactions.get()
        cancelAllTxs transactions.get(), 0, [], (error, canceledTxs) ->
          console.log canceledTxs
          console.log canceledTxs.length
          canceledTxs.forEach (tx) ->
            console.log tx.status
            expect(tx.status).to.equal('canceled')
          done(error)

          


