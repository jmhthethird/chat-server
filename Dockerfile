FROM elixir:1.5

WORKDIR /app
COPY . .

EXPOSE 4040

CMD ["bash"]
