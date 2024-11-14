FROM rocker/shiny-verse:latest

# Install pipx
RUN apt-get update && apt-get install -y \
    pipx && \
    pipx ensurepath

# Install radian
RUN pipx install radian

# Set the default command to radian
CMD ["radian"]