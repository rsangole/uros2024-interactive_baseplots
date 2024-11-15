FROM rocker/shiny-verse:latest

# Install pipx
RUN apt-get update && apt-get install -y \
    pipx && \
    pipx ensurepath

# Install radian
RUN pipx install --include-deps radian && \
    pipx install --include-deps quarto-cli

# Set the default command to radian
CMD ["radian"]