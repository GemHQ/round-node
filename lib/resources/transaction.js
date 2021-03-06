// Generated by CoffeeScript 1.8.0
(function() {
  var Base, Promise, Transaction, promisify,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Base = require('./base');

  Promise = require('bluebird');

  promisify = Promise.promisify;

  module.exports = Transaction = (function(_super) {
    __extends(Transaction, _super);

    Transaction.PROPS_LIST = ['value', 'fee', 'confirmations', 'hash', 'status', 'inputs', 'outputs', 'destination_addresses', 'lock_time', 'network', 'mfa_uri'];

    function Transaction(_arg) {
      var client, resource;
      resource = _arg.resource, client = _arg.client;
      this.client = client;
      this.resource = resource;
      this._setProps(Transaction.PROPS_LIST, resource);
    }

    Transaction.prototype.sign = function(_arg) {
      var inputs, signatures, txContent, txHash, wallet, _ref;
      wallet = _arg.wallet;
      if (this.resource.status !== 'unsigned') {
        Promise.reject(new Error('Transaction is already signed'));
      }
      if (wallet == null) {
        Promise.reject(new Error('A wallet is required to sign a transaction'));
      }
      _ref = wallet.prepareTransaction(this.resource), signatures = _ref.signatures, txHash = _ref.txHash;
      inputs = signatures.map(function(sig) {
        return {
          primary: sig
        };
      });
      txContent = {
        signatures: {
          transaction_hash: txHash,
          inputs: inputs
        }
      };
      this.resource.update = promisify(this.resource.update);
      return this.resource.update(txContent).then((function(_this) {
        return function(resource) {
          _this.resource = resource;
          _this._setProps(Transaction.PROPS_LIST, resource);
          return _this;
        };
      })(this))["catch"](function(error) {
        throw new Error(error);
      });
    };

    Transaction.prototype.approve = function(_arg) {
      var mfa_token;
      mfa_token = _arg.mfa_token;
      this.client.context.setMFA(mfa_token);
      this.resource.approve = promisify(this.resource.approve);
      return this.resource.approve({}).then((function(_this) {
        return function(resource) {
          _this.resource = resource;
          _this._setProps(Transaction.PROPS_LIST, resource);
          return _this;
        };
      })(this))["catch"](function(error) {
        throw new Error(error);
      });
    };

    Transaction.prototype.cancel = function() {
      this.resource.cancel = promisify(this.resource.cancel);
      return this.resource.cancel().then((function(_this) {
        return function(resource) {
          _this.resource = resource;
          _this._setProps(Transaction.PROPS_LIST, resource);
          return _this;
        };
      })(this))["catch"](function(error) {
        throw new Error(error);
      });
    };

    return Transaction;

  })(Base);

}).call(this);
