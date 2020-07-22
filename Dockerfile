FROM mcr.microsoft.com/dotnet/core/aspnet:3.1-buster-slim AS base
WORKDIR /app

FROM mcr.microsoft.com/dotnet/core/sdk:3.1-buster AS build
WORKDIR /src
COPY ["MarshallAPI/MarshallAPI.csproj", "MarshallAPI/"]
RUN dotnet restore "MarshallAPI/MarshallAPI.csproj"
COPY ./MarshallAPI ./MarshallAPI
WORKDIR "/src/MarshallAPI"
RUN dotnet build "MarshallAPI.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "MarshallAPI.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "MarshallAPI.dll"]