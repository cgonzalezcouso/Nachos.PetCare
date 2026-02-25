flowchart TD
  A[App inicia] --> B{¿Hay sesión/token válido?}
  B -- Sí --> H[Entrar a Home]
  B -- No --> C[Pantalla Login]

  C -->|Email/Password| D[Validar formato + requeridos]
  D --> E{¿Credenciales correctas?}
  E -- Sí --> F[Crear sesión / guardar token]
  F --> H
  E -- No --> G[Mostrar error + permitir reintento]
  G --> C

  C -->|Google/Apple| I[Iniciar OAuth]
  I --> J{¿OAuth ok?}
  J -- Sí --> F
  J -- No --> G

  C -->|Ir a Registro| K[Pantalla Registro]
  K --> L[Validar campos + password fuerte]
  L --> M{¿Email ya existe?}
  M -- Sí --> N[Mostrar "ya existe" + link a Login]
  N --> C
  M -- No --> O[Crear usuario]
  O --> P[Crear perfil inicial]
  P --> F

  C -->|¿Olvidaste contraseña?| Q[Reset password]
  Q --> R[Enviar email / código]
  R --> S[Confirmación]
  S --> C
