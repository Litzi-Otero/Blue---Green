# Argumento para la versión (usado en build y label)
ARG VERSION=latest

# Etapa 1: Build de la app React
FROM node:18-alpine AS build

# Establece directorio de trabajo
WORKDIR /app

# Copia package*.json
COPY package*.json ./

# Instala dependencias (incluye dev para build)
RUN npm ci --only=production=false

# Copia el código fuente
COPY . .

# Build de producción y agrega versión para verificación
RUN npm run build && echo "Version: ${VERSION}" > build/version.txt

# Etapa 2: Servir con Nginx (imagen ligera)
FROM nginx:alpine

# Copia los archivos build de la etapa anterior
COPY --from=build /app/build /usr/share/nginx/html

# Copia configuración personalizada de Nginx
COPY nginx.conf /etc/nginx/nginx.conf

# Ajusta Nginx para escuchar en puerto dinámico (para Render/AWS, etc.)
RUN sed -i 's/listen 80;/listen ${PORT:-80};/' /etc/nginx/nginx.conf

# Expone el puerto (default 80, pero flexible para $PORT)
EXPOSE ${PORT:-80}

# Label con versión
LABEL version=${VERSION}

# Comando por defecto: Nginx en foreground
CMD ["sh", "-c", "nginx -g 'daemon off;'"]