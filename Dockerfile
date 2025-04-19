FROM node:16

WORKDIR /app

COPY ui/package*.json ./
RUN npm install

COPY ui/ .

EXPOSE 8080

CMD ["npm", "start"]
