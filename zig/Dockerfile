FROM alpine:latest AS build
RUN apk add --no-cache zig

RUN mkdir -p /root/build
WORKDIR /root/build
COPY game.zig .
RUN zig build-exe game.zig
ADD https://github.com/krallin/tini/releases/download/v0.19.0/tini-static ./tini
RUN chmod +x ./tini

FROM scratch
COPY --from=build /root/build/game /root/build/tini /
ENTRYPOINT ["/tini", "--"]
CMD [ "/game" ]