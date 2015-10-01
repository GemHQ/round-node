# round-node: A Node.js client for the Gem API
The round client is designed to interact with Gem's API to make building blockchain apps drop dead simple.  All the complexity of altcoin protocols and cryptography has been abstracted away so you can focus on building your product.  Here are a few of the many great things the API and clients provide:

* Multi-signature wallets with Gem as a cosigner
* Bitcoin, Testnet, Litecoin, and Dogecoin support (multisig for all!)
* Webhook notifications automatically subscribed for you
* Integrated 2FA solution with arbitrary endpoints to build into your app
* Simplified balance inqueries
* Easy address management
* Hardware Security Modules for co-signing key
* Rules engine for transactions
* SDKs for many popular languages

## Support information
* __Support email__: [support@gem.co](mailto:support@gem.co)
* __Issues__:  Use github issues
* __Support Slack room__:  [![](https://chat.gem.co/badge.svg)](https://chat.gem.co)
* __Detailed API Docs__:  [Gem API Docs](http://guide.gem.co)

## Installing round-node:
    
   ```bash
   $ npm install round-node --save
   ```
      
## Getting Started Tutorial
#### Table of Contents
* [Introduction](README.md#Introduction)
* [1. Run the client](README.md#1-run-the-client)
* [2. Configure your application and API token](README.md#2-configure-your-application-and-api-token)
* [3. Create your User and Wallet](README.md#3-create-your-user-and-wallet)
* [4. Authenticate your User](README.md#4-authenticate-your-user)
* [5. Access the wallet and Default Account](README.md#5-access-the-wallet-and-default-account)
* [6. Generate an Address and Add Funds](README.md#6-generate-an-address-and-add-funds)
* [7. Make a Payment](README.md#7-make-a-payment)
* [Advanced Topics](docs/advanced.md)
    * [More about Wallets and Accounts](docs/advanced.md#wallets-and-accounts)
    * [More about Transactions](docs/advanced.md#transactions-and-payments)
    * [Subscriptions](docs/advanced.md#subscriptions)
    * [Integrated 2FA](docs/advanced.md#integrated-2fa)
    * [Operational/Custodail wallet models](docs/advanced.md#operationalcustodial-wallets)
    * [Operational/Custodial payments](docs/advanced.md#payments)

### Introduction
This tutorial will run you through the process of setting up an application with Gem, creating a wallet, funding an address and creating a transaction.

This tutorial assumes that you have completed the developer signup and that you have successfully installed the client

### 1. Get Your Credentials

1. Get your credentials by going to the [Gem Developer Console](https://developers.gem.co). You will need to grab an api_token, an admin_token, and your totp_secret. When you  sign up/in you will see a default application that Gem has created for you. You will also see the api_token for that application as well. After you click on the application you will be directed to a page where you can view your totp_secret as well as create an admin_token. (Learn more about admin_tokens [here](http://guide.gem.co/#admin-tokens)).


[[top]](README.md#getting-started-tutorial)

### 2. Authenticate as an application
In this step you will authenticate as one of your Gem applications.

  ```JavaScript
   var creds = {
    api_token: API_TOKEN,
    admin_token: ADMIN_TOKEN,
    totp_secret: TOTP_SECRET
   }
  
   Round.client()
   .then(function (client) {
     return client.authenticate_application(creds);
   })
   .then(function (application) {
     ...
   })
  ```

[[top]](README.md#getting-started-tutorial)

### 3. Create a Wallet
In this step you will create a Gem wallet, which is a 2-of-3 multisig bitcoin wallet.

1. Create a wallet:

  ```JavaScript
    // application.wallets() returns a 'wallets' resource which
    // will allow you to create a wallet.
    application.wallets()
    .then(function (wallets) {
      return wallets.create({
        name: WALLET_NAME,
        passphrase: SECURE_PASSPHRASE
      }); 
    })
    .then(function (data) {
      var wallet = data.wallet;
      var backup_seed = data.backup_seed
    });
  ```
**IMPORTANT: Save the backup_seed somewhere safe, ideally on a piece of papper. You will need your backup_seed in case you forget your wallet's password. Gem wallets are multi-sig wallets and we only keep an encrypted copy of your primary pivate seed (which is decrypted client-side usig your wallet's passphrase). Therefor, if you forget your wallet's passphrase there is no way for us to recover a wallet without a backup_seed.**

  
[[top]](README.md#getting-started-tutorial)

### 4. Access the wallet and Default Account
[Wallets and Accounts](docs/advanced.md#wallets-and-accounts)
Gem wallets have accounts that are scoped to a network (i.e. bitcoin, testnet, litecoin, dogecoin). A wallet comes with a default account named 'default'. The default account is a bitcoin account (not testnet).

1. Access the default account

  ```JavaSctipt
    wallet.accounts()
    .then(function (accounts) {
      // get the default account
      return accounts.get('default');
    })
    .then(function (account) {
     ...
    })
  ```
  
2. Or, create a new account

  ```JavaSctipt
    wallet.accounts()
    .then(function (accounts) {
      return accounts.create({
        name: ACCOUNT_NAME,
        network: NETWORK_OF_YOUR_CHOICE
      });
    })
    .then(function (account) {
     ...
    })
  ```
  

[[top]](README.md#getting-started-tutorial)

### 5. Create and fund an address

  ```JavaSctipt
  account.addresses()
  .then(function (addresses) {
    return addresses.create();
  })
  .then(function (address) {
  // fund this address
   console.log(address.string)
  })
  ```
  
Payments have to be confirmed by the network and on Testnet that can be slow.  To monitor for confirmations: input the address into the following url `https://live.blockcypher.com/btc-testnet/address/<YOUR ADDRESS>`.  The current standard number of confirmations for a transaction to be considered safe is 6.

You will be able to make a payment with only one confirmation, however.  While you wait for that to happen, feel free to read more details about:
[Wallets and Accounts](docs/advanced.md#wallets-and-accounts)


[[top]](README.md#getting-started-tutorial)


### 6. Make a Payment
In this section you’ll learn how to create a payment using your wallet. Once your address gets one confirmation we’ll be able to send a payment out of the wallet. To make a payment, you'll unlock a wallet, generate a list of payees and then call the pay method.

    ```Javascript
    var payees = [{
      address: '18XcgfcK4F8d2VhwqFbCbgqrT44r2yHczr',
      amount: 50000
    }]
    return account.pay({payees: payees});
    })
    .then(function (tx) {
      console.log(tx)
    })
    ```

The pay call takes a list of payee objects.  A payee is a dict of `{'address':ADDRESS, 'amount':amount}` where address is the bitcoin address and amount is the number of satoshis.  `utxo_confirmations` default to 6 and represents the number of confirmations an unspent output needs to have in order to be selected for the transaction.

**CONGRATS** - now build something cool.

[[top]](README.md#getting-started-tutorial)
