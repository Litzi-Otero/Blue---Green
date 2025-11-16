ARG VERSION=latest

FROM node:18-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production=false
COPY . .
RUN npm run build && echo "Version: ${VERSION}" > build/version.txt

FROM nginx:alpine
COPY --from=build /app/build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
RUN sed -i 's/listen ${PORT:-80};/listen ${PORT:-8080};/' /etc/nginx/nginx.conf  # Cloud Run usa 8080
EXPOSE 8080
LABEL version=${VERSION}
CMD ["sh", "-c", "nginx -g 'daemon off;'"]