# syntax=docker/dockerfile:1

# Dockerfile reference guide 
# https://docs.docker.com/engine/reference/builder/

# Prevents Python from writing pyc files.
ENV PYTHONDONTWRITEBYTECODE=1

# Keeps Python from buffering stdout and stderr to avoid situations where
# the application crashes without emitting any logs due to buffering.
ENV PYTHONUNBUFFERED=1

# Dumps Python tracebacks explicitly, on a fault, after a timeout, or on a user signal
ENV PYTHONFAULTHANDLER=1

# ############################################################################
# Image for the build stage (as can contain additional dependencies)
# ############################################################################
# See article https://pipenv.pypa.io/en/latest/docker/
ARG PYTHON_VERSION=3.10.4
FROM docker.io/python:${PYTHON_VERSION}-slim as builder
RUN pip install --user "pipenv==2023.5.19"

# Tell pipenv to create venv in the current directory
ENV PIPENV_VENV_IN_PROJECT=1

# Pipfile contains requests
ADD Pipfile.lock Pipfile /app

WORKDIR /app

# NOTE: If you install binary packages required for a python module, you need
# to install them again in the runtime. For example, if you need to install pycurl
# you need to have pycurl build dependencies libcurl4-gnutls-dev and libcurl3-gnutls
# In the runtime container you need only libcurl3-gnutls
# RUN apt install -y libcurl3-gnutls libcurl4-gnutls-dev

RUN /root/.local/bin/pipenv sync
RUN /app/.venv/bin/python -c "import requests; print(requests.__version__)"

# ############################################################################
# Image for the runtime 
# ############################################################################
FROM docker.io/python:${PYTHON_VERSION}-slim as runtime

RUN mkdir -v /app/.venv
COPY --from=builder /app/.venv/ /app/.venv/

RUN /usr/src/.venv/bin/python -c "import requests; print(requests.__version__)"

# ############################################################################
# Code for the runtime application image
# ############################################################################
# Create a non-privileged user that the app will run under.
# See https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#user
ARG UID=10001
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    appuser

WORKDIR /app

# Switch to the non-privileged user to run the application.
USER appuser

# Run the application.
ENTRYPOINT ["python3"]
CMD ["app.py"]
