# 🗺️ Planificación – Nacho's PetCare (2026)

Metodología **Scrum + Kanban** híbrida:
- Ciclos de trabajo en **Sprints** de 2–3 semanas (Scrum).
- Tablero visual de flujo continuo con columnas Kanban (ver [`kanban.md`](kanban.md)).
- Revisión y retrospectiva al final de cada sprint.
- Automatización del tablero vía GitHub Actions ([`project-automation.yml`](../.github/workflows/project-automation.yml)).

---

## 📅 Diagrama de Gantt

```mermaid
gantt
  title Nacho's PetCare – Planificación 2026
  dateFormat  YYYY-MM-DD

  section 🏁 Hitos
  Anteproyecto                   :milestone, m0, 2026-02-22, 0d
  1ª Parcial  (50 %%)            :milestone, m1, 2026-03-15, 0d
  2ª Parcial  (85 %%)            :milestone, m2, 2026-04-05, 0d
  Entrega Final (100 %%)         :milestone, m3, 2026-05-03, 0d
  Defensa Oral                   :milestone, m4, 2026-05-17, 0d

  section 📋 Sprint 0 – Anteproyecto
  Definir requisitos F / NF      :done, s0t1, 2026-02-10, 4d
  Investigar tecnologías         :done, s0t2, 2026-02-10, 4d
  Diagrama de arquitectura       :done, s0t3, 2026-02-14, 2d
  Wireframes / Prototipos        :done, s0t4, 2026-02-14, 3d
  Modelo de datos (ER)           :done, s0t5, 2026-02-16, 2d
  Setup repositorio              :done, s0t6, 2026-02-18, 2d
  Redactar documento anteproyecto:done, s0t7, 2026-02-19, 4d

  section 🚀 Sprint 1 – Desarrollo Base
  Setup proyecto Flutter         :done, s1t1, 2026-02-23, 2d
  Autenticación Firebase         :done, s1t2, 2026-02-25, 5d
  Modelo BD SQLite               :done, s1t3, 2026-03-02, 4d
  CRUD Mascotas                  :done, s1t4, 2026-03-06, 5d
  Pantallas y navegación         :done, s1t5, 2026-03-11, 3d
  Tests unitarios (auth + CRUD)  :done, s1t6, 2026-03-11, 3d
  README técnico actualizado     :done, s1t7, 2026-03-15, 1d

  section 🏥 Sprint 2 – Desarrollo Avanzado
  Módulo vacunas                 :s2t1, 2026-03-16, 5d
  Historial médico / visitas vet :s2t2, 2026-03-21, 5d
  Sistema de notificaciones      :s2t3, 2026-03-26, 5d
  Informes veterinarios (PDF)    :s2t4, 2026-03-31, 3d
  Integración F↔B + bug-fixing   :s2t5, 2026-04-02, 2d
  Mejoras UX / UI                :s2t6, 2026-04-01, 4d
  Documentación técnica parcial  :s2t7, 2026-04-04, 2d

  section 🎁 Sprint 3 – Entrega Final
  Módulo mascota perdida         :s3t1, 2026-04-06, 5d
  Adopción responsable           :s3t2, 2026-04-11, 5d
  Directorio de profesionales    :s3t3, 2026-04-16, 5d
  Sitios pet-friendly            :s3t4, 2026-04-21, 4d
  Testing final (unit+integ+UI)  :s3t5, 2026-04-25, 5d
  Optimización de rendimiento    :s3t6, 2026-04-28, 3d
  Memoria técnica completa       :s3t7, 2026-04-24, 9d
  Tag release v1.0.0             :s3t8, 2026-05-03, 1d

  section 🎤 Defensa
  Preparar presentación          :s4t1, 2026-05-04, 7d
  Ensayar defensa oral           :s4t2, 2026-05-11, 6d
  🎓 Defensa (17/05 · 19:40)    :milestone, m5, 2026-05-17, 0d
```

---

## 🏃 Sprints – Resumen

| Sprint | Período | Entrega | Objetivo |
|--------|---------|---------|----------|
| **Sprint 0** | 10/02 – 22/02 | Anteproyecto | Definición, arquitectura y planificación |
| **Sprint 1** | 23/02 – 15/03 | 1ª Parcial (50 %) | Auth + CRUD mascotas + BD |
| **Sprint 2** | 16/03 – 05/04 | 2ª Parcial (85 %) | Salud, notificaciones, informes |
| **Sprint 3** | 06/04 – 03/05 | Entrega Final (100 %) | Módulos extra, testing, memoria |
| **Defensa** | 04/05 – 17/05 | Defensa Oral | Presentación y exposición |

---

## 📋 Backlog por Sprint

### Sprint 0 – Anteproyecto ✅
- [x] Definir requisitos funcionales y no funcionales
- [x] Investigar tecnologías (Flutter/Dart, Firebase, SQLite)
- [x] Crear diagrama de arquitectura inicial
- [x] Prototipos de pantallas (wireframes)
- [x] Redactar documento del anteproyecto
- [x] Setup inicial del repositorio (README, .gitignore, estructura)
- [x] Definir modelo de datos inicial (ER diagram)

### Sprint 1 – Desarrollo Base ✅
- [x] Configurar proyecto Flutter (estructura, dependencias)
- [x] Implementar autenticación (Firebase Auth + Google Sign-In)
- [x] Diseñar e implementar modelo de BD (SQLite)
- [x] CRUD de mascotas (añadir, editar, eliminar, listar)
- [x] Pantallas principales de navegación (Home, Perfil, Mascotas)
- [x] Primeras pruebas unitarias (auth + CRUD)
- [x] README técnico actualizado

### Sprint 2 – Desarrollo Avanzado 🔄
- [ ] Módulo de vacunas (registro + próxima dosis)
- [ ] Historial médico / visitas al veterinario
- [ ] Sistema de notificaciones y recordatorios
- [ ] Generación de informes veterinarios (PDF)
- [ ] Integración completa Frontend ↔ Backend
- [ ] Pruebas de integración y corrección de bugs
- [ ] Mejoras de UX/UI basadas en feedback
- [ ] Documentación técnica parcial

### Sprint 3 – Entrega Final ⏳
- [ ] Módulo mascota perdida (estado + contacto + ubicación)
- [ ] Módulo adopción responsable (listados/artículos)
- [ ] Directorio de profesionales (veterinarios, adiestradores…)
- [ ] Sitios pet-friendly
- [ ] Testing final (unitario, integración, UI)
- [ ] Optimización de rendimiento
- [ ] Exportar y documentar esquema de BD definitivo
- [ ] Redactar memoria técnica completa
- [ ] Revisar y actualizar README y documentación
- [ ] Tag de release `v1.0.0` en GitHub

### Defensa ⏳
- [ ] Preparar presentación (slides, demos)
- [ ] Ensayar defensa oral
- [ ] **Defensa: 17/05/2026 a las 19:40**
