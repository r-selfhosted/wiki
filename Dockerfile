FROM mcr.microsoft.com/dotnet/sdk:9.0 AS builder

WORKDIR /build
COPY . /build

RUN dotnet tool install retypeapp --version 4.6.0 --tool-path /bin
RUN bash scripts/normalize-icons.sh
RUN retype build --output .docker-build/

FROM httpd:2.4
COPY --from=builder /build/.docker-build/ /usr/local/apache2/htdocs/
