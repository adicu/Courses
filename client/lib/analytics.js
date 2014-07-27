if (!this.Co) {
  Co = {};
}
Co.analytics = {};

// Initialize analytics code.
Co.analytics.start = function() {
  // Heap analytics code
  var heapID;
  if (Meteor.settings &&
    Meteor.settings.public &&
    Meteor.settings.public.heapID) {
    heapID = Meteor.settings.public.heapID;
  } else {
    heapID = Co.constants.analytics.heapID;
  }
  heap.load(heapID);

  Deps.autorun(function() {
    var userID = Meteor.userId();
    if (userID) {
      heap.identify({
        handle: userID
      });
    }
  });
};

// @param eventName String - the name of the event to track
// @param data Object - any additional data to track
Co.analytics.track = function(eventName, data) {
  console.log(eventName, data);
  heap.track(eventName, data);
};
