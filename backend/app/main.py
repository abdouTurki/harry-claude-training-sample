"""API Todo — FastAPI.

Petite API de gestion de tâches, volontairement simple, pour servir de support
de formation Claude Code. Persistance SQLite (fichier), migrations au démarrage.
"""
from __future__ import annotations

from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .database import init_db
from .routers import todos


@asynccontextmanager
async def lifespan(_: FastAPI):
    # Crée le schéma au démarrage (idempotent).
    init_db()
    yield


app = FastAPI(title="Todo API", version="1.0.0", lifespan=lifespan)

# En formation on ouvre le CORS au front local ; en prod, restreindre l'origine.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(todos.router)


@app.get("/health", tags=["ops"])
def health() -> dict[str, str]:
    """Sonde de liveness (utilisée par docker-compose et le déploiement)."""
    return {"status": "ok"}
