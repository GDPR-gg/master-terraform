FROM node:slim

WORKDIR / 
# Copy the package.json and package-lock.json
COPY package*.json / 

# Allow generation inside docker
RUN test -f package-lock.json || npm install

# Install dependencies
RUN npm ci

# Copy the rest of your action's code
COPY . / 

# Run `node /index.js`
ENTRYPOINT ["node", "/index.js"]

