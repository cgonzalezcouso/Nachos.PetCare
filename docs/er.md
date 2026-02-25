erDiagram
  USER ||--o{ PET : owns
  PET  ||--o{ VACCINATION : has
  PET  ||--o{ MEDICAL_EVENT : has
  PET  ||--o{ REMINDER : has
  PET  ||--o| LOST_REPORT : may_have
  PET  ||--o| ADOPTION_LISTING : may_have

  USER {
    string id PK
    string email
    string displayName
    datetime createdAt
  }

  PET {
    string id PK
    string ownerId FK
    string name
    string species
    string breed
    date   birthDate
    string photoUrl
    string microchip
  }

  VACCINATION {
    string id PK
    string petId FK
    string vaccineName
    date   dateGiven
    date   nextDueDate
    string vetName
    string notes
  }

  MEDICAL_EVENT {
    string id PK
    string petId FK
    string type  "illness|visit|treatment|allergy"
    date   date
    string title
    string details
  }

  REMINDER {
    string id PK
    string petId FK
    string type "vaccine|meds|visit|custom"
    datetime dueAt
    boolean done
    string notes
  }

  LOST_REPORT {
    string id PK
    string petId FK
    datetime lostAt
    string lastLocationText
    float  lastLat
    float  lastLng
    string description
    string contactPhone
    boolean active
  }

  ADOPTION_LISTING {
    string id PK
    string petId FK
    datetime publishedAt
    string locationText
    string description
    string requirements
    boolean active
  }
