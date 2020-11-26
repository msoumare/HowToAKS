FROM microsoft/dotnet:2.1-aspnetcore-runtime AS base
WORKDIR /app
EXPOSE 80

FROM microsoft/dotnet:2.1-sdk AS build
WORKDIR /src
COPY ["./HowToAKS.WebApi.csproj", "HowToAKS.WebApi/"]
RUN dotnet restore "HowToAKS.WebApi/HowToAKS.WebApi.csproj"
COPY . .
WORKDIR "/src"
RUN dotnet build "HowToAKS.WebApi.csproj" -c Release -o /app

FROM build AS publish
RUN dotnet publish "HowToAKS.WebApi.csproj" -c Release -o /app

FROM base AS final
WORKDIR /app
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "HowToAKS.WebApi.dll"]
