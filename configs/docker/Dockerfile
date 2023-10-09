# Stage 1: Build the Go Binary
FROM golang:1.21.2 as build_sales-api

ENV CGO_ENABLED 0
ARG BUILD_REF

COPY . /service

WORKDIR /service

RUN go build -ldflags "-X main.build=${BUILD_REF}"

# Stage 2: Run the Go Binary in Alpine
FROM alpine:3.18

ARG BUILD_DATE
ARG BUILD_REF

COPY --from=build_sales-api /service /service

WORKDIR /service
CMD ["./service"]

LABEL org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.title="sales-api" \
      org.opencontainers.image.authors="Omid Esmailbeig <omid.delta96@gmail.com>" \
      org.opencontainers.image.source="https://github.com/OmidEsmailbeig/service/tree/master/app/services/sales-api" \
      org.opencontainers.image.revision="${BUILD_REF}"
