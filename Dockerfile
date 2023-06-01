# First stage: Building the application
FROM node:16.18.0-alpine AS builder

# Install libc6-compat needed for some Node.js applications on Alpine
# Check https://github.com/nodejs/docker-node/tree/b4117f9333da4138b03a546ec926ef50a31506c3#nodealpine to understand why libc6-compat might be needed.
RUN apk add --no-cache libc6-compat

# Update packages in the image
RUN apk update

# Set the working directory
WORKDIR /app

# Copy dependency configuration files
COPY package.json package-lock.json ./

# Install dependencies with frozen lockfile
RUN npm install --frozen-lockfile

# Copy the application source code
COPY . .

# Build the application
RUN npm run build

# Remove development dependencies
RUN npm prune --production

# Second stage: Running the application in a production environment
FROM node:16.18.0-alpine

# Install libc6-compat needed for some Node.js applications on Alpine
RUN apk add --no-cache libc6-compat

# Update packages in the image
RUN apk update

# Set the working directory
WORKDIR /app

# Copy necessary files from the build image
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public

# Expose port 3000
EXPOSE 3000

# Command to start the application
CMD ["npm", "start"]
