// =============================================================
// eventBus.service.js  ->  ALGORITHM ONLY (source: backend/src/services/eventBus.service.js)
// =============================================================

// in-memory EventEmitter singleton mimicking Redis pub/sub (single instance deployment)

// publish(channel, message) : setImmediate(() => bus.emit(channel, message))  -> async, non-blocking
// registerHandler(eventName, handler) : bus.on(eventName, handler)
