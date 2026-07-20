// Client d'API todo. Base URL injectée au build (VITE_API_URL), défaut = localhost:8000.
const BASE = import.meta.env.VITE_API_URL ?? "http://localhost:8000";

// done: undefined = toutes, true = terminées, false = actives.
export async function listTodos(done) {
  const url = done === undefined ? `${BASE}/todos` : `${BASE}/todos?done=${done}`;
  const r = await fetch(url);
  if (!r.ok) throw new Error("GET /todos a échoué");
  return r.json();
}

export async function createTodo(title) {
  const r = await fetch(`${BASE}/todos`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ title }),
  });
  if (!r.ok) throw new Error("POST /todos a échoué");
  return r.json();
}

export async function toggleTodo(id, done) {
  const r = await fetch(`${BASE}/todos/${id}`, {
    method: "PATCH",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ done }),
  });
  if (!r.ok) throw new Error("PATCH /todos a échoué");
  return r.json();
}

export async function deleteTodo(id) {
  const r = await fetch(`${BASE}/todos/${id}`, { method: "DELETE" });
  if (!r.ok) throw new Error("DELETE /todos a échoué");
}
