# Rules

## AI Boundaries & Coding Standards

1. **Libraries**:
   - Use stable, well-maintained libraries.
   - Avoid deprecated packages.
   - When integrating QR code reading, prefer lightweight client-side libraries unless server-side processing is necessary.

2. **Error Handling**:
   - Always include try/catch blocks for API calls.
   - Fail gracefully. Show meaningful error messages to the user if QR scan fails.
   - Log errors comprehensively for debugging.

3. **What AI Should Do**:
   - Always refer to these documentation files before starting a new phase.
   - Follow the `Architecture.md` guidelines for file placement.
   - Update `Memory.md` continuously as tasks are completed.

4. **What AI Shouldn't Do**:
   - Do not stray outside the phased plan in `Phases.md`.
   - Do not introduce massive breaking changes without first explicitly stating the impact in a plan.
   - Do not make assumptions about environment variables; always document required env vars.
