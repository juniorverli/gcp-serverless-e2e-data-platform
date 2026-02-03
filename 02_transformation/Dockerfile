FROM python:3.12.12-slim

WORKDIR /app

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/uv

# Copy project files
COPY . .

# Install dependencies using uv
# --frozen ensures we use the exact versions in uv.lock
RUN uv sync --frozen

ARG TARGET

# Conditionally replace 'dev' with 'prod' for production builds
RUN if [ "${TARGET}" = "prod" ]; then \
    sed -i 's/dev/prod/g' profiles.yml && \
    sed -i 's/dev/prod/g' catalogs.yml; \
    fi

# Check if replacement worked (for build logs validation)
RUN cat profiles.yml
RUN cat catalogs.yml

RUN uv run dbt deps

# Helper script to run dbt
ENTRYPOINT ["uv", "run", "dbt"]
CMD ["run", "--profiles-dir", "."]
