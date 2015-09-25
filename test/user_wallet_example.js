var Round = require('../lib');
var devCreds = require('./data/credentials').developer;
var userCreds = require('./data/credentials').user;
 
// Retrieve your credentials from the developer console: developers.gem.co

var newUserCreds = {
  first_name: 'bez',
  last_name: 'reyhan',
  email: 'bez+' + Date.now() + '@gem.co',
  device_name: 'devy',
  passphrase: 'secure_password'
}

/*
 * RUN THE FOLLOWING THREE SCIPTS SEPERATELY
*/

 // ----------------------- 1) USER CREATION -----------------------
Round.client({url: 'http://localhost:8999'})
.then(function(client) {
  // Authenticate with your api_token
  client.authenticate_identify({api_token: devCreds.api_token})
  newUserCreds.redirect_uri = 'http://www.google.com';
  console.log(newUserCreds)
  console.log('-------------------------')
  return client.users.create(newUserCreds)
})
.then(function(device_token) {
  // Save the device_token in your database
  // The device_token is needed to authenticate a user
  console.log(device_token)
})
.catch(function(error) {
  throw new Error(error);
})


 // ------------------ 2) USER TRANSACTION ------------------

// Round.client({url: 'http://localhost:8999'})
// .then(function(client) {
//   return client.authenticate_device({
//     api_token: devCreds.api_token,
//     device_token: userCreds.device_token,
//     email: userCreds.email
//   });
// })
// .then(function(user) {
//   return user.wallet()
// })
// .then(function(wallet) {
//   return wallet.unlock({passphrase: userCreds.passphrase})
// })
// .then(function(wallet) {
//   return wallet.accounts()
// })
// .then(function(accounts) {
//   // Gem creates a default_account for every user.
//   // Accounts are scoped to a currency (bitcoin, litecoin, dogecoin)
//   // The default_account is scoped to bitcoin
//   defaultAccount = accounts.get(0)
//   // You can also get an account by name or get all
//   // accounts by running accounts.get()
//   return defaultAccount.addresses()
// })
// // create an address so you can fund it
// .then(function(addresses) {
//   return addresses.create();
// })
// // get the bitcoin address from the address object
// .then(function(address) {
//   console.log(address.string)
// })
// .catch(function(error) {
//   throw new Error(error);
// })


// ------------------ USER WALLET TRANSACTION ------------------
//  Round.client({url: 'http://localhost:8999'})
// .then(function(client) {
//   return client.authenticate_device({
//     api_token: devCreds.api_token,
//     device_token: userCreds.device_token,
//     email: userCreds.email
//   });
// })
// .then(function(user) {
//   return user.wallet()
// })
// .then(function(wallet) {
//   return wallet.unlock({passphrase: userCreds.passphrase})
// })
// .then(function(wallet) {
//   return wallet.accounts()
// })
// .then(function(accounts) {
//   var defaultAccount = accounts.get(0)
//   var payees = [{address: '18XcgfcK4F8d2VhwqFbCbgqrT44r2yHczr', amount: 20000}]
//   return defaultAccount.pay({payees: payees, confirmations: 1})
// })
// .then(function(tx) {
//   console.log(tx);
//   console.log(tx.mfa_uri)
// })
// .catch(function(error) {
//   throw new Error(error);
// })

