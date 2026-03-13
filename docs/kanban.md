# 🗂️ Tablero Kanban – Nacho's PetCare

Este proyecto combina **Scrum** (sprints con fechas fijas) y **Kanban** (flujo visual de tareas) para maximizar la agilidad y la visibilidad del trabajo en curso.

---

## 🔄 Flujo de trabajo (columnas del tablero)

```
Backlog → Sprint Activo → In Progress → In Review → Done
```

| Columna | Descripción | Límite WIP |
|---------|-------------|-----------|
| **📦 Backlog** | Todas las tareas pendientes, ordenadas por prioridad | Ilimitado |
| **🏃 Sprint Activo** | Tareas comprometidas para el sprint actual | ≤ 15 |
| **🔨 In Progress** | Tareas en desarrollo activo | ≤ 3 por persona |
| **🔍 In Review** | PR abierto / esperando revisión de código | ≤ 5 |
| **✅ Done** | Tareas completadas y mergeadas | — |

---

## 🏷️ Etiquetas (Labels)

| Label | Color | Uso |
|-------|-------|-----|
| `sprint-0` | 🟡 amarillo | Anteproyecto |
| `sprint-1` | 🟠 naranja | Desarrollo Base |
| `sprint-2` | 🔵 azul | Desarrollo Avanzado |
| `sprint-3` | 🟢 verde | Entrega Final |
| `feature` | 💜 violeta | Nueva funcionalidad |
| `bug` | 🔴 rojo | Error o defecto |
| `docs` | ⬜ gris | Documentación |
| `testing` | 🩵 cian | Pruebas |
| `priority-high` | 🔴 rojo intenso | Prioridad alta |
| `priority-medium` | 🟡 amarillo | Prioridad media |
| `priority-low` | ⚪ blanco | Prioridad baja |

---

## 📐 Metodología Híbrida Scrum + Kanban

### Scrum
- **Sprint Planning** al inicio de cada sprint (≈ 1 h): selección de tareas del Backlog.
- **Daily Stand-up** (opcional): ¿Qué hice? ¿Qué haré? ¿Algún bloqueo?
- **Sprint Review** al final de cada sprint: demostración del incremento.
- **Sprint Retrospectiva**: ¿Qué mejorar?

### Kanban
- Flujo continuo visualizado en el tablero de GitHub Projects.
- Límites de WIP para evitar sobrecarga.
- Automatización de movimiento de tarjetas vía **GitHub Actions** ([`project-automation.yml`](../.github/workflows/project-automation.yml)).

### Reglas del tablero
1. Cada **issue** representa una tarea o historia de usuario.
2. Al crear un issue → entra automáticamente en **Backlog**.
3. Al asignar el issue a un desarrollador → pasa a **Sprint Activo**.
4. Al abrir un PR vinculado → pasa a **In Progress**.
5. Al marcar el PR como *Ready for Review* → pasa a **In Review**.
6. Al hacer merge del PR → pasa a **Done** y el issue se cierra.

---

## 📎 Recursos

- 🔗 [GitHub Projects (tablero)](https://github.com/users/cgonzalezcouso/projects/10) _(requiere acceso al proyecto si es privado)_
- 📊 [Diagrama de Gantt](plan.md)
- 🏗️ [Arquitectura](architecture.md)
- 🗄️ [Modelo de datos (ER)](er.md)
