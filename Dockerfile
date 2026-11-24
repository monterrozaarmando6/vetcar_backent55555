# ---- Etapa 1: compilar ----
FROM eclipse-temurin:21-jdk AS build
WORKDIR /app
COPY . /app
# Busca ApiServer.java en cualquier carpeta del repo. Si no existe, muestra la estructura.
RUN SOURCE="$(find /app -name ApiServer.java -print -quit)" \
    && if [ -z "$SOURCE" ]; then echo "ERROR: no se encontro ApiServer.java. Estructura del repo:"; find /app -maxdepth 5 -not -path '*/.git/*'; exit 1; fi \
    && echo "Compilando $SOURCE" \
    && mkdir -p /app/out \
    && javac -d /app/out "$SOURCE"

# ---- Etapa 2: ejecutar ----
FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=build /app/out /app/out
RUN mkdir -p /data
ENV DATA_DIR=/data
EXPOSE 8080
CMD ["java", "-cp", "out", "com.veterinaria.ApiServer"]
