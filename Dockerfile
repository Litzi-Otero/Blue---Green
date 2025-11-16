# Argumento para la versión
ARG VERSION=latest

# Etapa 1: Build de React
FROM node:18-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production=false
COPY . .
RUN npm run build && echo "Version: ${VERSION}" > build/version.txt

# Etapa 2: Nginx
FROM nginx:alpine
# Instala gettext para envsubst (expande vars en conf)
RUN apk add --no-cache gettext

# Copia build de React
COPY --from=build /app/build /usr/share/nginx/html

# Copia template de config (con placeholder ${PORT})
COPY nginx.template.conf /etc/nginx/nginx.template.conf

# Expone puerto dinámico
EXPOSE ${PORT:-8080}

# Label
LABEL version=${VERSION}

# CMD: Expande $PORT en conf y arranca Nginx
CMD ["sh", "-c", "envsubst '${PORT}' < /etc/nginx/nginx.template.conf > /etc/nginx/nginx.conf && nginx -g 'daemon off;'"]