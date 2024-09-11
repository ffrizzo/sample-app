FROM golang:1.23-alpine AS builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o sample-app main.go

FROM scratch

EXPOSE 8080

COPY --from=builder /app/sample-app /sample-app

CMD ["/sample-app"]
