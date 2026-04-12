const CircuitBreaker = require('opossum');

module.exports = (asyncFunction, fallbackFunction) => {
  const breaker = new CircuitBreaker(asyncFunction, {
    timeout: 5000,
    errorThresholdPercentage: 50,
    resetTimeout: 30000
  });

  if (fallbackFunction) {
    breaker.fallback(fallbackFunction);
  }

  return breaker;
};
