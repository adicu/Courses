// Use chai assert like normal assert.
assert = chai.assert;

stubMeteor = function() {
  var sinon = Meteor.require('sinon');

  var getStub = sinon.stub()
    .withArgs('currentSemester').returns('20143');
  Session = {
    get: getStub,
    set: sinon.stub()
  };
};

