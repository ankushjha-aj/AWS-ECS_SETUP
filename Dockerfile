# Stage 1: Build the NestJS application using pnpm
FROM public.ecr.aws/docker/library/node:18-alpine AS builder 

# Set working directory
WORKDIR /app

# Copy necessary files
COPY package.json pnpm-lock.yaml ./
COPY tsconfig.json ./
# COPY .env ./

# Install Corepack 0.29.4 explicitly and enable it
RUN npm install -g corepack@0.15.3

# Install pnpm globally using Corepack
RUN corepack prepare pnpm@latest --activate

# Install dependencies using pnpm
# RUN pnpm install --frozen-lockfile
RUN pnpm --version && pnpm install --frozen-lockfile

# Copy the rest of the project files
COPY . .

# Build the NestJS app
RUN pnpm build

# Stage 2: Production Image (Minimal for optimized performance)
FROM node:18-alpine

# Set the working directory
WORKDIR /app

# Install Corepack 0.29.4 explicitly in the production image
RUN npm install -g corepack@0.15.3

# Install pnpm globally using Corepack
RUN corepack prepare pnpm@latest --activate

# Set the environment to production
ENV NODE_ENV=production

# Copy necessary files from the builder stage
COPY --from=builder /app/package.json ./
COPY --from=builder /app/pnpm-lock.yaml ./
COPY --from=builder /app/dist ./dist
#COPY --from=builder /app/node_modules ./node_modules
RUN pnpm install --prod --frozen-lockfile

# Expose the port your NestJS app runs on
EXPOSE 3001

# Start the NestJS app
CMD ["pnpm", "start:prod"]

