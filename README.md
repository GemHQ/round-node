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
* __Slack room__:[![](https://gem-support-slackin.herokuapp.com/badge.svg)](https://gem-support-slackin.herokuapp.com)
* __Detailed API Docs__:  [Gem API Docs](http://guide.gem.co)

## Installation

### Install gem dependencies:
Round depends on libsodium. On a Mac run:
  
      $ brew install libsodium

For Linux, follow the instructions on: 
      
      http://doc.libsodium.org/installation/README.html
  
Install the rest of the dependencies: 

      $ npm install

## Configuration

Require Round where needed:
```node
  var Round = require("round-node");

  Round.client(function(error, client) {
      ...
  });
```

## Authentication

You must authenticate to interact with the API. Depending on what you are trying to do there are different authentication schemes available.

### Developer

Authenticating as a developer will allow you create and manage your applications. Authenticating in this way requires the developer's email, as well as their private key. The method will return a `Round::Developer` object.
```node
var developerCreds = {
  privkey: PRIVKEY,
  email: EMAIL@ADDRE.SS
};

client.authenticateDeveloper(developerCreds, function(error, dev) {
  ...
});
```

### Application

Authenticating as an application will give you read-only access to your users and their wallets. This requires the `app_url`, the `api_token`, and an `instance_id`. The method will return a Round Application object.
```node
var applicationCreds = {
  app_url: APP_URL,
  api_token: API_TOKEN,
  instance_id: INSTANCE_ID
};

client.authenticateApplication(applicationCreds, function(error, app) {
  ...
});
```

Your `instance_id` is provided to you via email when you authorize an application instance using Developer auth:
```node
client.authenticateDeveloper(developerCreds, function (error, developer) {
  developer.applications(function(error, apps) {
    var app = apps.get('default');
    
    app.authorizeInstance({name: INSTANCE_NAME}, function(error) {
      // handle error if error
      // an instance_id has been sent to your developer email
    });
  });
});
```

### Device

Authenticating as a device allows you to perform all actions on a wallet permitted by a user. Requires an `email`, an `api_token`, a `user_token`, and a `device_id`. The method will return a Round User object.
```node
var deviceCreds = {
  email: USER_EMAIL,
  api_token: API_TOKEN,
  user_token: USER_TOKEN,
  device_id: DEVICE_ID
};

client.authenticateDevice(deviceCreds, function(error, user) {
  ...
});
```
The `user_token` is obtained by a user authorizing your application to operate on their wallet. This level of authorization is received through the `completeDeviceAuthorization` call:
```node
var deviceCreds = {
  api_token: API_TOKEN,
  device_id: DEVICE_ID,
  name: DEVICE_NAME,
  email: USER_EMAIL
};


client.beginDeviceAuthorization(deviceCreds, function(error, key) {
  deviceCreds.key = key
});
```

This will trigger an out of band email to the user that will include a one time pass that will allow you to complete the device authorization:
```node
var deviceCreds = {
  api_token: API_TOKEN,
  device_id: DEVICE_ID,
  name: DEVICE_NAME,
  email: USER_EMAIL,
  key: KEY,
  secret: OTP_FROM_EMAIL
};

client.completeDeviceAuthorization(<DEVICE_NAME>, <DEVICE_ID>, <API_TOKEN>, key, <OTP_FROM_EMAIL>)
```

## Basic Usage

### Wallets

Once you've got a User authenticated with a device you can start to do fun stuff like create wallets:

```node
var walletData = {
  name: WALLET_NAME,
  passphrase: WALLET_PASSPHRASE
};

user.wallets(function(error, wallets) {
  wallets.create(walletData, function(error, backup_seed, wallet) {
    ...
  });
});

```

__IMPORTANT__: Creating a wallet this way will automatically generate your backup key tree. You can get it by accessing `wallet.multiWallet`. This will return the `CoinOp.Bit.MultiWallet` object containing both private seeds. __Make sure you save it somewhere__.

### Accounts

Once you have a wallet you're going to want to send and receive funds from it, right? You do this by creating accounts within the wallet:
```node
wallet.accounts(function(error, accounts) {
  accounts.create({name: ACCOUNT_NAME}, function(error, account) {
    ...
  });
});
```

To receive payments, you'll have to generate a new address:
```node
account.addresses(function(error, addresses) {
  addresses.create(function(error, address) {
    ...
  });
});
```

Sending payments is easy too:
```node
payees = [
  {address: ADDRESS, amount: PAYMENT_AMOUNT},
  {address: ADDRESS, amount: PAYMENT_AMOUNT},
  {address: ADDRESS, amount: PAYMENT_AMOUNT}
];
account.pay({payees: payees}, function(error, data) {
  ...
});
```

You can add as many payees as you need.
Don't forget to unlock the wallet before trying to pay someone:
```node
wallet.unlock(PASSPHRASE);
```
