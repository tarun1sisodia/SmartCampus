# Build Stage
FROM node:20-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm install

COPY . .

# Production Stage
FROM node:20-alpine

WORKDIR /app
COPY --from=builder /app ./

# Security: Run as non-privileged user
RUN addgroup -S nodeapp && adduser -S nodeapp -G nodeapp
USER nodeapp

EXPOSE 5000

CMD ["node", "server.js"]
