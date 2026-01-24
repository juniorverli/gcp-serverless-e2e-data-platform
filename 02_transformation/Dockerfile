FROM python:3.12.12-slim

WORKDIR /app

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/uv

# Copy project files
COPY . .

# Install dependencies using uv
# --frozen ensures we use the exact versions in uv.lock
RUN uv sync --frozen

# Replace 'dev' with 'prod' in profiles.yml to switch environment
RUN sed -i 's/dev/prod/g' profiles.yml

# Check if replacement worked (for build logs validation)
RUN cat profiles.yml

# Helper script to run dbt
ENTRYPOINT ["uv", "run", "dbt"]
CMD ["run", "--profiles-dir", "."]
