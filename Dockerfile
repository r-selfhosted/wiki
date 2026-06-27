FROM node:24-bookworm-slim AS builder

WORKDIR /build
COPY . /build

RUN npm install --global retypeapp@4.6.0
RUN bash scripts/normalize-icons.sh
RUN retype build --output .docker-build/

FROM httpd:2.4
COPY --from=builder /build/.docker-build/ /usr/local/apache2/htdocs/
