FROM erlang:27-alpine
COPY game.erl ./
RUN erlc game.erl
CMD ["erl", "-noshell", "-run", "game"]
