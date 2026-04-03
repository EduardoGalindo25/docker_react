# ==========================================
# ETAPA 1: BASE (El cimiento para ambos)
# ==========================================
FROM node:22-alpine AS base
WORKDIR /app
COPY package*.json ./
# Instalamos las librerías aquí para que dev y prod las hereden
RUN npm install

# ==========================================
# ETAPA 2: DESARROLLO (target: dev)
# ==========================================
FROM base AS dev
# Copiamos el código fuente
COPY . .
# Exponemos el puerto por defecto de Vite
EXPOSE 5173
# Ejecutamos Vite permitiendo conexiones externas (--host)
CMD ["npm", "run", "dev", "--", "--host"]

# ==========================================
# ETAPA 3: CONSTRUCTOR (Paso intermedio para Prod)
# ==========================================
FROM base AS builder
COPY . .
# Compilamos el código de React a HTML/CSS/JS estático
RUN npm run build

# ==========================================
# ETAPA 4: PRODUCCIÓN (target: prod)
# ==========================================
FROM nginx:alpine AS prod

# AGREGA ESTA LÍNEA: Copia tu config personalizada al contenedor
COPY docker/nginx/nginx.conf /etc/nginx/conf.d/default.conf

# Copiamos la carpeta /dist (Esto ya lo tenías bien)
COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]