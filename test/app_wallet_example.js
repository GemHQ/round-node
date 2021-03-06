// npm install round-node --save
 
var Round = require('../lib');
var devCreds = require('./data/credentials').developer;
 
// Retrieve your credentials from the developer console: developers.gem.co
var creds = {
  api_token: devCreds.api_token,
  admin_token: devCreds.admin_token,
  totp_secret: devCreds.totp_secret
}
 
// Round.client()
// // Authenticate an application using the credentials
// // you received from the user console.
// .then(function (client) {
//   return client.authenticate_application(creds);
// })
// // Pull down the application's wallets. It should not contain
// // any wallets since you have not created any yet.
// .then(function (application) {
//   return application.wallets();
// })
// // Create a wallet for your application
// .then(function (wallets) {
//   var walletInfo = {
//     name: 'wallet' + Math.random(),
//     passphrase: 'SECURE_PASSPHRASE'
//   }
//   return wallets.create(walletInfo);
// })
// // wallets.create returns an object that has 'wallet' and 'backup_seed'
// // as its properties.
// // A wallet has different accounts. Accounts are objects within
// // your wallet that contain funds.
// .then(function (data) {
//   var wallet = data.wallet;
//   // save the backup seed in case you ever need to retrieve the wallet
//   var backup_seed = data.backup_seed;
//   return wallet.accounts({fetch: true});
// })
// // Gem creates a default account for you.
// // The network for this account is set to 'bitcoin' (not bitcoin_testnet)
// // Get the first account
// .then(function (accounts) {
//   return accounts.get('default');
// })
// // An account is where all your funds are stored, therefor
// // an account contains addresses.
// .then(function (account) {
//   return account.addresses();
// })
// // Create an address since you don't have one.
// .then(function (addresses) {
//   return addresses.create();
// })
// // Fund the address!
// .then(function (address) {
//   console.log(address.string)
// })
// .catch(function (error) {
//   throw new Error(error)
// })



// // Now let's pay out from the funded account
Round.client({url: 'http://localhost:8999'})
// Authenticate an application using the credentials
// you received from the user console.
.then(function (client) {
  return client.authenticate_application(creds);
})
// Pull down the applications wallets.
.then(function (application) {
  return application.wallets({fetch: true});
})
// Get your wallet that you funded by the name you gave it.
.then(function (wallets) {
  return wallets.get(devCreds.walletName);
  // You can also get the first wallet if that's the wallet
  // that contains the account that you funded.
  // wallet.get(0)
})
.then(function(wallet) {
  return wallet.unlock({passphrase: 'SECURE_PASSPHRASE'});
})
.then(function (wallet) {
  return wallet.accounts({fetch: true});
})
// Get the account that you funded by the name you gave it.
// Or if you used the default bitcoin account, get the first account.
.then(function (accounts) {
  return accounts.get('default');
})
.then(function (account) {
  // who do you want to pay to and how much (in satohies)?
  var payees = [{
    address: '18XcgfcK4F8d2VhwqFbCbgqrT44r2yHczr',
    amount: 50000
  }];
  console.log(account.balance);
  // make a payment!
  return account.pay({payees: payees});
})
.then(function (tx) {
  console.log(tx);
})
.catch(function (error) {
  throw new Error(error);
})