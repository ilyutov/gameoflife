FROM golang:1.24-alpine as builder
WORKDIR /build
COPY game.go ./
RUN go build game.go

FROM scratch
COPY --from=builder /build/game .
CMD ["./game"]
