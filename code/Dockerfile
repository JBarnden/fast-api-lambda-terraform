# Build stage
FROM public.ecr.aws/lambda/python:3.11 AS builder
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

WORKDIR /build
COPY requirements.txt ./
RUN pip3 wheel --no-cache-dir --wheel-dir /wheels -r requirements.txt

FROM public.ecr.aws/lambda/python:3.11
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# Runtime stage (keeps build-time artifacts out of the final image)
WORKDIR /app
COPY --from=builder /wheels /wheels
COPY requirements.txt ./
RUN pip3 install --no-cache-dir --no-index --find-links=/wheels -r requirements.txt \
    && rm -rf /wheels

COPY . ./
CMD [ "main.handler" ]
