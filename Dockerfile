
FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:8.0-alpine AS build

COPY . /source

WORKDIR /source/ParallexBankDevOps

# This is the architecture you’re building for, which is passed in by the builder.
# Placing it here allows the previous steps to be cached across architectures.
ARG TARGETARCH

# Build the application.
# Leverage a cache mount to /root/.nuget/packages so that subsequent builds don't have to re-download packages.
# If TARGETARCH is "amd64", replace it with "x64" - "x64" is .NET's canonical name for this and "amd64" doesn't
#   work in .NET 6.0.
RUN --mount=type=cache,id=nuget,target=/root/.nuget/packages \
    dotnet publish -a ${TARGETARCH/amd64/x64} --use-current-runtime --self-contained false -o /app

# If you need to enable globalization and time zones:

FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine AS final
EXPOSE 5167
WORKDIR /app

# Copy everything needed to run the app from the "build" stage.
COPY --from=build /app .


USER $APP_UID

ENTRYPOINT ["dotnet", "ParallexBankDevOps.dll"]
