# syntax=docker/dockerfile:1

# Dockerfile reference guide 
# https://docs.docker.com/engine/reference/builder/

# ############################################################################
# Image for the build stage (as can contain additional dependencies)
# ############################################################################
# See article https://pipenv.pypa.io/en/latest/docker/
ARG PYTHON_VERSION=3.11.3
ARG FLASK_PORT=8000

FROM docker.io/python:${PYTHON_VERSION}-slim as builder

COPY . /src
WORKDIR /src

RUN pip install pipenv

# Create a non-privileged user that the app will run under.
# See https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#user
ARG UID=10001
ARG GID=$UID
RUN addgroup --gid $GID nonroot
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/home/appuser" \
    --shell "/sbin/nologin" \
    --uid "${UID}" \
    --gid "${GID}" \
    appuser

# Now install dependencies
RUN pipenv sync --system 

# Prevents Python from writing pyc files.
ENV PYTHONDONTWRITEBYTECODE=1

# Keeps Python from buffering stdout and stderr to avoid situations where
# the application crashes without emitting any logs due to buffering.
ENV PYTHONUNBUFFERED=1

# Dumps Python tracebacks explicitly, on a fault, after a timeout, or on a user signal
ENV PYTHONFAULTHANDLER=1

# Switch to the non-privileged user to run the application.
USER appuser

EXPOSE $FLASK_PORT

# Run the application.

ENTRYPOINT [ "python" ]
CMD [ "./app.py"]
