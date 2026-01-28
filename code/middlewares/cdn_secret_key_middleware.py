from starlette.middleware.base import BaseHTTPMiddleware
from fastapi import status, Response
import os


class CdnSecretKeyMiddleware(BaseHTTPMiddleware):
    """
    Deny any incoming requests that don't have the correct CDN secret key in the X-CDN-Secret-Key header
    if the CDN is enabled.
    """

    async def dispatch(self, request, call_next):
        cdn_secret_key = os.getenv("CDN_SECRET_KEY", None)
        if cdn_secret_key and request.headers.get("X-CDN-Secret-Key") != cdn_secret_key:
            return Response(status_code=status.HTTP_403_FORBIDDEN)
        return await call_next(request)
