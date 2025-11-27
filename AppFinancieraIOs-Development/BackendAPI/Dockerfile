# Stage 1: Build
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copia el archivo de proyecto
COPY ["BackendAPI.csproj", "./"]

# Restaura dependencias
RUN dotnet restore "BackendAPI.csproj"

# Copia el código fuente
COPY . .

# Compila en modo Release
RUN dotnet build "BackendAPI.csproj" -c Release -o /app/build

# Stage 2: Publish
FROM build AS publish
RUN dotnet publish "BackendAPI.csproj" -c Release -o /app/publish

# Stage 3: Runtime
FROM mcr.microsoft.com/dotnet/aspnet:8.0

# Instala herramientas útiles para debugging (opcional, comentar en producción)
RUN apt-get update && apt-get install -y --no-install-recommends \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copia los binarios publicados desde el stage anterior
COPY --from=publish /app/publish .

# Expone puerto 80 (HTTP)
EXPOSE 80

# Configura el entry point
ENTRYPOINT ["dotnet", "BackendAPI.dll"]
