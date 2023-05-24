# syntax=docker/dockerfile:1

# Dockerfile reference guide 
# https://docs.docker.com/engine/reference/builder/

# ############################################################################
# Image for the build stage (as can contain additional dependencies)
# ############################################################################
# See article https://pipenv.pypa.io/en/latest/docker/
ARG PYTHON_VERSION=3.10.4
FROM docker.io/python:${PYTHON_VERSION}-slim as builder

COPY . /code
WORKDIR /code

RUN pip install "pipenv==2023.5.19"

# Now install dependencies
RUN pipenv install --deploy --system --ignore-pipfile

# NOTE: If you install binary packages required for a python module, you need
# to install them again in the runtime. For example, if you need to install pycurl
# you need to have pycurl build dependencies libcurl4-gnutls-dev and libcurl3-gnutls
# In the runtime container you need only libcurl3-gnutls
# RUN apt install -y libcurl3-gnutls libcurl4-gnutls-dev

RUN python -c "import flask; print(flask.__version__)"

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

# Prevents Python from writing pyc files.
ENV PYTHONDONTWRITEBYTECODE=1

# Keeps Python from buffering stdout and stderr to avoid situations where
# the application crashes without emitting any logs due to buffering.
ENV PYTHONUNBUFFERED=1

# Dumps Python tracebacks explicitly, on a fault, after a timeout, or on a user signal
ENV PYTHONFAULTHANDLER=1

# Switch to the non-privileged user to run the application.
USER appuser

EXPOSE 8000

# Run the application.
CMD ["pipenv","run" ,"python","app.py"]
