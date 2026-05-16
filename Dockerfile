# Stage 1 - Build
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS builder
WORKDIR /app

# Copy solution and restore dependencies
COPY src/ .
RUN dotnet restore

# Build and publish
RUN dotnet publish -c Release -o /app/publish

# Stage 2 - Runtime
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=builder /app/publish .

EXPOSE 7070

ENTRYPOINT ["dotnet", "cartservice.dll"]
