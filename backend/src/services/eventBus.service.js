// A simplified memory Pub/Sub mimicking Redis for single instance setup.
// If using actual Redis Pub/Sub, 'ioredis' duplicate clients would be instantiated here.
import EventEmitter from 'events';
class AppEventBus extends EventEmitter {}
const bus = new AppEventBus();

export const publish = async (channel, message) => {
  // Emulate asynchronous delivery / Redis publish
  setImmediate(() => {
    bus.emit(channel, message);
  });
};

export const registerHandler = (eventName, handler) => {
  bus.on(eventName, handler);
};

export default { publish, registerHandler };
