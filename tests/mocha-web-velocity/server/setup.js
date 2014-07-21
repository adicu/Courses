// Use chai assert like normal assert.
assert = chai.assert;

stubMeteor = function() {
  var sinon = Meteor.require('sinon');

  Session = {
    get: sinon.stub(),
    set: sinon.stub()
  };
};

