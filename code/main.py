import os
from fastapi import FastAPI, HTTPException, status
from starlette.middleware.cors import CORSMiddleware
from starlette.responses import FileResponse
from mangum import Mangum
from dotenv import load_dotenv
import logging

# Configure logger
logger = logging.getLogger()
if logger.hasHandlers():
    # The Lambda environment pre-configures a handler logging to stderr. If a handler is already configured,
    # `.basicConfig` does not execute. Thus we set the level directly.
    logger.setLevel(logging.INFO)
else:
    logging.basicConfig(level=logging.INFO)

# Load environment variables from .env (only required for local development)
load_dotenv()


app = FastAPI(title="MyAwesomeApp")

app.add_middleware(
    CORSMiddleware,
    # Front-end origins permitted to make requests, ideally populate via environment variable
    allow_origins=["http://localhost:3000"],
    allow_methods=["GET", "PUT", "POST", "OPTIONS", "HEAD"],
    allow_headers=[
        "Access-Control-Allow-Headers",
        "Content-Type",
        "Access-Control-Allow-Origin",
        "Set-Cookie",
    ],
)


@app.get("/hello")
def hello_world():
    # Verify the environment variable is working
    message = os.environ.get("DEMO_ENVIRONMENT_VARIABLE")
    secret_key = os.environ.get("SECRET_KEY")
    # Verify the secrets file and log group are working
    logger.info(f"Secret key: {secret_key}")

    if not message:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Couldn't retrieve environment variable",
        )

    return {"message": message}


@app.get("/favicon", include_in_schema=False)
async def favicon():
    if not os.path.isfile("favicon.ico"):
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="favicon.ico not found"
        )

    return FileResponse("favicon.ico")


handler = Mangum(app)