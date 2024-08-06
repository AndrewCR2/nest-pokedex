# Instalar dependencias solo cuando sea necesario
FROM node:18-alpine3.19 AS deps
# Check https://github.com/nodejs/docker-node/tree/b4117f9333da4138b03a546ec926ef50a31506c3#nodealpine para entender por qué podría necesitarse libc6-compat.
RUN apk add --no-cache libc6-compat
WORKDIR /app
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

# Construir la aplicación con dependencias cacheadas
FROM node:18-alpine3.19 AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN yarn build

# Imagen de producción, copiar todos los archivos y ejecutar la aplicación
FROM node:18-alpine3.19 AS runner

# Establecer el directorio de trabajo
WORKDIR /usr/src/app

# Copiar solo los archivos necesarios para la producción
COPY package.json yarn.lock ./

RUN yarn install --prod

COPY --from=builder /app/dist ./dist

# Exponer el puerto (puedes ajustar este puerto según tu aplicación)
EXPOSE 3000

# Comando para ejecutar la aplicación
CMD [ "node", "dist/main" ]
