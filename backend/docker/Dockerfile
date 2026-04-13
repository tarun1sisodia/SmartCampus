FROM node:20-alpine as builder  
WORKDIR /app  
COPY package*.json ./  
RUN npm ci --only=production

FROM node:20-alpine  
RUN apk add --no-cache tini  
WORKDIR /app  
COPY --from=builder /app/node_modules ./node_modules  
COPY . .  
EXPOSE 5000  
ENTRYPOINT ["/sbin/tini", "--"]  
CMD ["node", "server.js"]  
