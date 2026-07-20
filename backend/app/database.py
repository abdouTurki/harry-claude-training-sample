"""Accès SQLite minimal (sans ORM, pour rester lisible en formation)."""
from __future__ import annotations

import os
import sqlite3
from collections.abc import Iterator
from contextlib import contextmanager

def db_path() -> str:
    """Chemin du fichier SQLite, lu à chaque appel (surchargé par TODO_DB_PATH).

    Lecture dynamique (pas au niveau module) pour rester testable : chaque test
    peut pointer une base jetable via la variable d'environnement.
    """
    return os.environ.get("TODO_DB_PATH", "todo.db")


@contextmanager
def get_conn() -> Iterator[sqlite3.Connection]:
    conn = sqlite3.connect(db_path())
    conn.row_factory = sqlite3.Row
    try:
        yield conn
        conn.commit()
    finally:
        conn.close()


def init_db() -> None:
    """Crée la table si absente (migration au démarrage)."""
    with get_conn() as conn:
        conn.execute(
            """
            CREATE TABLE IF NOT EXISTS todos (
                id    INTEGER PRIMARY KEY AUTOINCREMENT,
                title TEXT    NOT NULL,
                done  INTEGER NOT NULL DEFAULT 0
            )
            """
        )
