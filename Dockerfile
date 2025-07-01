FROM mcr.microsoft.com/dotnet/sdk:9.0 AS builder

WORKDIR /build
COPY . /build

RUN dotnet tool install retypeapp --tool-path /bin
RUN retype build --output .docker-build/

FROM httpd:latest
COPY --from=builder /build/.docker-build/ /usr/local/apache2/htdocs/
