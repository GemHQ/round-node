Round = require('../../src')
Account = require('../../src/resources/account')
Transaction = require('../../src/resources/transaction')
Transactions = require('../../src/resources/transactions')
expect = require('chai').expect
credentials = require('../data/credentials')
devCreds = credentials.developer
url = credentials.url
Promise = require('bluebird')


describe 'Transactions Resource', ->
  accounts = null
  before (done) ->
    Round.client {url}
    .then (client) ->
      {api_token, admin_token, totp_secret} = devCreds
      client.authenticate_application {api_token, admin_token, totp_secret}
    .then (app) -> app.wallets()
    .then (wallts) ->
      wallet = wallts.get(0)
      wallet.accounts()
    .then (accnts) -> 
      accounts = accnts
      done()
    .catch (error) -> done(error)


  # describe 'Transaction', ->
  #   transactions = null
  #   before (done) ->
  #     accounts.get('bitcoin').transactions()
  #     .then (txs) -> transactions = txs; done()
  #     .catch (error) -> done(error)
    
  #   describe.only 'transaction.cancel', ->
  #     it 'should cancel the transaction', (done) ->
  #       transactions.get(0).cancel()
  #       .then (tx) -> 
  #         expect(tx).to.be.an.instanceof(Transaction)
  #         expect(tx.status).to.equal('canceled')
  #         done()
  #       .catch (error) -> done(error)


  # describe 'Cancel Txs', ->
  #   transactions = account= null
  #   before (done) ->
  #     account = accounts.get('bitcoin')
  #     account.transactions {status: 'unsigned'}
  #     .then (txs) -> transactions = txs; done()
  #     .catch (error) -> done(error)

  #   describe.only 'cancel all unsigned transactions', ->
  #     it 'should cancel all unsigned txs', (done) ->
        
  #       cancelAllTxs = (transactions, i, canceledTxs) ->
  #         len = transactions.length
  #         if i >= len
  #           Promise.resolve(canceledTxs)
  #         else
  #           tx = transactions[i]
  #           if tx.status == 'unsigned'
  #             tx.cancel()
  #             .then (tx) ->
  #               canceledTxs.push(tx)
  #               cancelAllTxs(transactions, i+1, canceledTxs)
  #             .catch (error) -> error
  #           else
  #             cancelAllTxs(transactions, i+1, canceledTxs)
        
  #       # console.log transactions.get()
  #       cancelAllTxs(transactions.get(), 0, [])
  #       .then (canceledTxs) ->
  #         # console.log canceledTxs
  #         canceledTxs.forEach (tx) ->
  #           console.log tx.status
  #           expect(tx.status).to.equal('canceled')
  #         done()
  #       .catch (error) -> done(error)

          

  describe 'Cancel Txs', ->
    transactions = account= null
    before (done) ->
      account = accounts.get('bitcoin')
      account.transactions {status: 'unsigned'}
      .then (txs) -> transactions = txs; done()
      .catch (error) -> done(error)

    describe.only 'cancel all unsigned transactions', ->
      it 'should cancel all unsigned txs', (done) ->
        
        cancelAllTxs = (transactions) ->
          Promise.all transactions.map((tx) -> tx.cancel())
        
        # console.log transactions.get()
        cancelAllTxs(transactions.get())
        .then (canceledTxs) ->
          # console.log canceledTxs
          canceledTxs.forEach (tx) ->
            console.log tx.status
            expect(tx.status).to.equal('canceled')
          done()
        .catch (error) -> done(error)

          



