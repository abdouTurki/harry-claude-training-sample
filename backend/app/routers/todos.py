"""Endpoints CRUD des tâches — controller mince, délègue à la base."""
from __future__ import annotations

from fastapi import APIRouter, HTTPException, Response, status

from ..database import get_conn
from ..models import Todo, TodoCreate, TodoUpdate

router = APIRouter(prefix="/todos", tags=["todos"])


@router.get("", response_model=list[Todo])
def list_todos(done: bool | None = None) -> list[Todo]:
    # Filtre optionnel par état : ?done=true|false. Sans paramètre → toutes les tâches.
    if done is None:
        query, params = "SELECT id, title, done FROM todos ORDER BY id", ()
    else:
        query = "SELECT id, title, done FROM todos WHERE done = ? ORDER BY id"
        params = (int(done),)
    with get_conn() as conn:
        rows = conn.execute(query, params).fetchall()
    return [Todo(id=r["id"], title=r["title"], done=bool(r["done"])) for r in rows]


@router.post("", response_model=Todo, status_code=status.HTTP_201_CREATED)
def create_todo(payload: TodoCreate) -> Todo:
    with get_conn() as conn:
        cur = conn.execute("INSERT INTO todos (title, done) VALUES (?, 0)", (payload.title,))
        todo_id = cur.lastrowid
    return Todo(id=todo_id, title=payload.title, done=False)


@router.patch("/{todo_id}", response_model=Todo)
def update_todo(todo_id: int, payload: TodoUpdate) -> Todo:
    with get_conn() as conn:
        row = conn.execute("SELECT id, title, done FROM todos WHERE id = ?", (todo_id,)).fetchone()
        if row is None:
            raise HTTPException(status_code=404, detail="Todo introuvable")
        title = payload.title if payload.title is not None else row["title"]
        done = payload.done if payload.done is not None else bool(row["done"])
        conn.execute("UPDATE todos SET title = ?, done = ? WHERE id = ?", (title, int(done), todo_id))
    return Todo(id=todo_id, title=title, done=done)


@router.delete("/{todo_id}", status_code=status.HTTP_204_NO_CONTENT, response_class=Response)
def delete_todo(todo_id: int) -> Response:
    with get_conn() as conn:
        cur = conn.execute("DELETE FROM todos WHERE id = ?", (todo_id,))
        if cur.rowcount == 0:
            raise HTTPException(status_code=404, detail="Todo introuvable")
    return Response(status_code=status.HTTP_204_NO_CONTENT)
