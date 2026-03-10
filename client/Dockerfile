# FROM node:20

# WORKDIR /usr/src/app

# COPY package*.json ./
# RUN npm ci

# COPY . .

# RUN npm run build

# EXPOSE 3000

# CMD ["npm", "start"]


FROM node:20 AS build

WORKDIR /usr/src/app

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

FROM nginx:alpine

COPY --from=build /usr/src/app/build /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]