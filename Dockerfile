FROM continuumio/miniconda3:4.12.0

# Create jovyan user (common for Jupyter-style containers)
ENV NB_USER=jovyan \
    NB_UID=1000 \
    HOME=/home/jovyan

RUN adduser \
    --disabled-password \
    --gecos "Default User" \
    --uid ${NB_UID} \
    --home ${HOME} \
    --force-badname \
    ${NB_USER}

# Install build tools and git
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copy Benchpark requirements and setup script
COPY ./benchpark/requirements.txt /home/${NB_USER}/benchpark/requirements.txt
COPY ./benchpark/setup-env.sh /home/${NB_USER}/benchpark/setup-env.sh

# Install Python dependencies, setup Benchpark, and install Jupyter
RUN pip install --upgrade pip && \
    pip install -r /home/${NB_USER}/benchpark/requirements.txt && \
    pip install notebook && \
    chmod +x /home/${NB_USER}/benchpark/setup-env.sh && \
    /home/${NB_USER}/benchpark/setup-env.sh

# Adjust ownership and switch to jovyan user
RUN chown -R ${NB_USER} "${HOME}"

USER ${NB_USER}
WORKDIR ${HOME}
ENV PATH="${HOME}/.local/bin:${PATH}"
