// A simplified memory Pub/Sub mimicking Redis for single instance setup.
// If using actual Redis Pub/Sub, 'ioredis' duplicate clients would be instantiated here.
const EventEmitter = require('events');
class AppEventBus extends EventEmitter {}
const bus = new AppEventBus();

exports.publish = async (channel, message) => {
  // Emulate asynchronous delivery / Redis publish
  setImmediate(() => {
    bus.emit(channel, message);
  });
};

exports.registerHandler = (eventName, handler) => {
  bus.on(eventName, handler);
};
