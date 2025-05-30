FROM rust:alpine as build
RUN rustup default nightly
WORKDIR /build
ADD https://github.com/krallin/tini/releases/download/v0.19.0/tini-static ./tini
RUN chmod +x ./tini
COPY game.rs ./
RUN rustc game.rs

FROM scratch
COPY --from=build /build/game /build/tini /
ENTRYPOINT ["/tini", "--"]
CMD [ "/game" ]
