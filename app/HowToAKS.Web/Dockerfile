FROM microsoft/dotnet:2.1-aspnetcore-runtime AS base
WORKDIR /app
EXPOSE 80

FROM microsoft/dotnet:2.1-sdk AS build
WORKDIR /src
COPY ["./HowToAKS.Web.csproj", "HowToAKS.Web/"]
RUN dotnet restore "HowToAKS.Web/HowToAKS.Web.csproj"
COPY . .
WORKDIR "/src"
RUN dotnet build "HowToAKS.Web.csproj" -c Release -o /app

FROM build AS publish
RUN dotnet publish "HowToAKS.Web.csproj" -c Release -o /app

FROM base AS final
WORKDIR /app
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "HowToAKS.Web.dll"]
