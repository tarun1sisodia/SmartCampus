// =============================================================
// circuitBreaker.js  ->  ALGORITHM ONLY (source: backend/src/middleware/circuitBreaker.js)
// =============================================================

// export default (asyncFunction, fallbackFunction?) :
//   wrap the function in an opossum CircuitBreaker:
//     timeout 5s, open the circuit at 50% error rate, try reset after 30s
//   optional fallback runs while the circuit is open
//   (stops cascading failures when a dependency is down)
