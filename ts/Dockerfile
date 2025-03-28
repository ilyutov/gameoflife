FROM node:23-alpine
COPY game.ts ./
ENV NODE_OPTIONS "--experimental-strip-types --disable-warning=ExperimentalWarning"
CMD ["node", "game.ts"]
