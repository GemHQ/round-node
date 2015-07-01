// npm install round-node --save
 
var Round = require('../lib');
var devCreds = require('./data/credentials').developer;
 
// Retrieve your credentials from the developer console: developers.gem.co
var creds = {
  api_token: devCreds.api_token,
  admin_token: devCreds.admin_token,
  totp_secret: devCreds.totp_secret
}
 
Round.client({url: 'http://localhost:8999'})
// Authenticate an application using the credentials
// you received from the user console.
.then(function (client) {
  return client.authenticate_application(creds);
})
// Pull down the applications wallets. It should not contain
// any wallets since you have not created any yet.
.then(function (application) {
  return application.wallets();
})
// Create a wallet for your application
.then(function (wallets) {
  walletInfo = {
    name: 'wallet' + Math.random(),
    passphrase: 'SECURE_PASSPHRASE'
  }
  return wallets.create(walletInfo);
})
// A wallet has different accounts. Accounts are objects within
// your wallet that contain funds.
.then(function (data) {
  var wallet = data.wallet;
  // save the backup seed in case you ever need to retrieve the wallet
  var backup_seed
  return wallet.accounts();
})
// Gem creates a default account for you.
// The network for this account is set to 'bitcoin' (not bitcoin_testnet)
// Get the first account
.then(function (accounts) {
  var account = accounts.get(0)
  // An account is where all your funds are stored, therefor
  // an account contains addresses.
  return account.addresses()
})
// Create an address since you don't have one.
.then(function (addresses) {
  return addresses.create()
})
// Fund the address!
.then(function (address) {
  console.log(address.string)
})
.catch(function (error) {
  throw new Error(error)
})



// Now let's pay out from the funded account
Round.client({url: 'http://localhost:8999'})
// Authenticate an application using the credentials
// you received from the user console.
.then(function (client) {
  return client.authenticate_application(creds);
})
// Pull down the applications wallets.
.then(function (application) {
  return application.wallets();
})
// Get your wallet that you funded by the name you gave it.
.then(function (wallets) {
  var wallet = wallets.get('YOUR_WALLET_NAME')
  wallet = wallet.unlock({passphrase: 'SECURE_PASSPHRASE'})
  // You can also get the first wallet if that's the wallet
  // that contains the account that you funded.
  // wallet.get(0)
  return wallet.accounts()
})
// Get the account that you funded by the name you gave it.
// Or if you used the default bitcoin account, get the first account.
.then(function (accounts) {
  var account = accounts.get(0)
  // who do you want to pay to and how much?
  var payees = [{
    address: '18XcgfcK4F8d2VhwqFbCbgqrT44r2yHczr',
    amount: 50000
  }]
  // make a payment!
  return account.pay({payees: payees})
})
.then(function (tx) {
  console.log(tx)
})
.catch(function (error) {
  throw new Error(error)
})
  