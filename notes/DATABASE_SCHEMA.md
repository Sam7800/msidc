# Database Schema Design

**Version:** 1.0
**Database:** SQLite (current), PostgreSQL (future)
**Last Updated:** 2026-01-12

---

## 📊 Schema Overview

The database is designed to support a 33-section work entry form with flexible JSON storage for complex nested data. The schema is normalized where appropriate and uses JSON for variable section data.

**Total Tables:** 6
1. `categories` - Project categories
2. `projects` - Projects within categories
3. `work_entries` - Main work entry per project (1:1)
4. `work_entry_sections` - 33+ sections with JSON data
5. `section_attachments` - File uploads (photos, PDFs)
6. `milestones` - 5 milestones (MS-I to MS-V)

---

## 🗂️ Table Definitions

### 1. categories

**Purpose:** Store project categories (Nashik Kumbhmela, HAM Projects, etc.)

```sql
CREATE TABLE categories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  color TEXT NOT NULL,
  description TEXT,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_categories_name ON categories(name);
```

**Fields:**
- `id` - Auto-increment primary key
- `name` - Category name (unique)
- `color` - Hex color code for UI (#0061FF)
- `description` - Optional description
- `created_at` - Timestamp when created
- `updated_at` - Timestamp when last updated

**Sample Data:**
```json
{
  "id": 1,
  "name": "Nashik Kumbhmela",
  "color": "#3B82F6",
  "description": "Projects related to Nashik Kumbhmela",
  "created_at": "2026-01-12T10:00:00Z",
  "updated_at": "2026-01-12T10:00:00Z"
}
```

---

### 2. projects

**Purpose:** Store projects within categories

```sql
CREATE TABLE projects (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  sr_no TEXT NOT NULL,
  name TEXT NOT NULL,
  category_id INTEGER NOT NULL,
  status TEXT DEFAULT 'Pending',
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
);

CREATE INDEX idx_projects_category ON projects(category_id);
CREATE INDEX idx_projects_status ON projects(status);
CREATE INDEX idx_projects_sr_no ON projects(sr_no);
```

**Fields:**
- `id` - Auto-increment primary key
- `sr_no` - Serial number (display identifier)
- `name` - Project name
- `category_id` - Foreign key to categories
- `status` - Project status (Pending, In Progress, Completed, On Hold)
- `created_at` - Timestamp when created
- `updated_at` - Timestamp when last updated

**Constraints:**
- `category_id` references `categories(id)` with CASCADE delete
- If category is deleted, all projects in that category are also deleted

**Sample Data:**
```json
{
  "id": 1,
  "sr_no": "NK001",
  "name": "Road Construction Project",
  "category_id": 1,
  "status": "In Progress",
  "created_at": "2026-01-12T10:30:00Z",
  "updated_at": "2026-01-12T15:45:00Z"
}
```

---

### 3. work_entries

**Purpose:** Main work entry for each project (1:1 relationship)

```sql
CREATE TABLE work_entries (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  project_id INTEGER NOT NULL UNIQUE,
  last_updated_by TEXT,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (project_id) REFERENCES projects (id) ON DELETE CASCADE
);

CREATE UNIQUE INDEX idx_work_entries_project ON work_entries(project_id);
```

**Fields:**
- `id` - Auto-increment primary key
- `project_id` - Foreign key to projects (UNIQUE - one work entry per project)
- `last_updated_by` - Username of last person who updated
- `created_at` - Timestamp when created
- `updated_at` - Timestamp when last updated

**Constraints:**
- `project_id` is UNIQUE (one work entry per project)
- `project_id` references `projects(id)` with CASCADE delete

**Sample Data:**
```json
{
  "id": 1,
  "project_id": 1,
  "last_updated_by": "admin",
  "created_at": "2026-01-12T11:00:00Z",
  "updated_at": "2026-01-12T16:30:00Z"
}
```

---

### 4. work_entry_sections

**Purpose:** Store 33+ sections of work entry form with JSON data

```sql
CREATE TABLE work_entry_sections (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  work_entry_id INTEGER NOT NULL,
  section_name TEXT NOT NULL,
  section_data TEXT NOT NULL,
  person_responsible TEXT,
  pending_with TEXT,
  held_with TEXT,
  status TEXT DEFAULT 'not_started',
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (work_entry_id) REFERENCES work_entries (id) ON DELETE CASCADE,
  UNIQUE(work_entry_id, section_name)
);

CREATE INDEX idx_sections_work_entry ON work_entry_sections(work_entry_id);
CREATE INDEX idx_sections_name ON work_entry_sections(section_name);
CREATE INDEX idx_sections_status ON work_entry_sections(status);
CREATE INDEX idx_sections_person ON work_entry_sections(person_responsible);
```

**Fields:**
- `id` - Auto-increment primary key
- `work_entry_id` - Foreign key to work_entries
- `section_name` - Section identifier (aa, dpr, boq, ts, nit, etc.)
- `section_data` - JSON text containing section-specific fields
- `person_responsible` - Free text field (who is responsible)
- `pending_with` - Free text field (pending with whom)
- `held_with` - Free text field (held with whom)
- `status` - Section status (not_started, in_progress, completed)
- `created_at` - Timestamp when created
- `updated_at` - Timestamp when last updated

**Constraints:**
- `work_entry_id` references `work_entries(id)` with CASCADE delete
- UNIQUE constraint on (`work_entry_id`, `section_name`) - one section per work entry

**Section Names:**
- `aa` - Administrative Approval
- `dpr` - Detailed Project Report
- `boq` - Bill of Quantities
- `schedules` - Schedules
- `drawings` - Drawings
- `bid_documents` - Bid Documents
- `env` - Environmental Clearance
- `la` - Land Acquisition
- `utility_shifting` - Utility Shifting
- `ts` - Technical Sanction
- `nit` - Notice Inviting Tender
- `prebid` - Pre-bid
- `bidders` - Bidders
- `csd` - Common Set of Deviations
- `bid_submission` - Bid Submission
- `tech_evaluation` - Technical Evaluation
- `financial_bid` - Financial Bid
- `bid_acceptance` - Bid Acceptance
- `loa` - Letter of Acceptance
- `pbg` - Performance Bank Guarantee
- `work_order` - Work Order
- `agreement` - Agreement
- `ld` - Liquidated Damages
- `eot` - Extension of Time
- `cos` - Change of Scope
- `expenditure` - Expenditure
- `audit_para` - Audit Para
- `laq` - Legislative Questions
- `technical_audit` - Technical Audit
- `rev_aa` - Revised Administrative Approval
- `supplementary_agreement` - Supplementary Agreement

**Sample Data:**

```json
// AA Section
{
  "id": 1,
  "work_entry_id": 1,
  "section_name": "aa",
  "section_data": "{\"type\":\"accorded\",\"amount_crore\":100,\"aa_no\":\"AA/2026/001\",\"date\":\"2026-01-10\",\"broad_scope\":\"Infrastructure development for Nashik Kumbhmela\"}",
  "person_responsible": "Chief Engineer",
  "pending_with": "",
  "held_with": "",
  "status": "completed",
  "created_at": "2026-01-12T11:00:00Z",
  "updated_at": "2026-01-12T11:30:00Z"
}

// NIT Section with Items Table
{
  "id": 11,
  "work_entry_id": 1,
  "section_name": "nit",
  "section_data": "{\"is_issued\":true,\"date_of_issue\":\"2026-01-05\",\"amount_lakhs\":500,\"items\":[{\"name\":\"Civil Work\",\"amount\":300,\"emd\":15},{\"name\":\"Electrical Work\",\"amount\":200,\"emd\":10}],\"date_of_prebid\":\"2025-12-20\",\"date_of_submission\":\"2026-01-05\"}",
  "person_responsible": "Tender Committee",
  "pending_with": "Engineering Department",
  "held_with": "",
  "status": "in_progress",
  "created_at": "2026-01-12T11:00:00Z",
  "updated_at": "2026-01-12T14:00:00Z"
}
```

**section_data JSON Examples:**

```json
// AA (Administrative Approval)
{
  "type": "awaited|accorded",
  "proposed_amount": "100",
  "date_of_proposal": "2026-01-10",
  "pending_with_whom": "Director",
  "amount_crore": 100,
  "aa_no": "AA/2026/001",
  "date": "2026-01-10",
  "broad_scope": "Infrastructure development"
}

// DPR
{
  "status": "not_started|in_progress|submitted|approved",
  "likely_completion_date": "2026-03-15"
}

// BOQ
{
  "status": "not_started|in_progress|completed",
  "likely_completion_date": "2026-02-20",
  "items": [
    {"item": "Civil Work", "amount": 300, "unit": "Lakhs"},
    {"item": "Electrical", "amount": 200, "unit": "Lakhs"}
  ]
}

// NIT
{
  "is_issued": true,
  "date_of_issue": "2026-01-05",
  "amount_lakhs": 500,
  "items": [
    {"name": "Civil Work", "amount": 300, "emd": 15},
    {"name": "Electrical", "amount": 200, "emd": 10}
  ],
  "date_of_prebid": "2025-12-20",
  "date_of_submission": "2026-01-05"
}

// EOT (Extension of Time)
{
  "is_applicable": true,
  "status": "not_started|under_consideration|submitted|approved",
  "period_months": 6,
  "with_escalation": true,
  "with_ld": false,
  "compensation_payable": true,
  "compensation_amount": 50000
}
```

---

### 5. section_attachments

**Purpose:** Store file attachments (photos, PDFs) for sections

```sql
CREATE TABLE section_attachments (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  section_id INTEGER NOT NULL,
  file_name TEXT NOT NULL,
  file_path TEXT NOT NULL,
  file_type TEXT,
  file_size INTEGER,
  uploaded_at TEXT DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (section_id) REFERENCES work_entry_sections (id) ON DELETE CASCADE
);

CREATE INDEX idx_attachments_section ON section_attachments(section_id);
```

**Fields:**
- `id` - Auto-increment primary key
- `section_id` - Foreign key to work_entry_sections
- `file_name` - Original file name (e.g., "nit_document.pdf")
- `file_path` - Full file path on disk
- `file_type` - MIME type (image/png, image/jpeg, application/pdf)
- `file_size` - File size in bytes
- `uploaded_at` - Timestamp when uploaded

**Constraints:**
- `section_id` references `work_entry_sections(id)` with CASCADE delete

**Sample Data:**
```json
{
  "id": 1,
  "section_id": 11,
  "file_name": "nit_notice.pdf",
  "file_path": "/data/attachments/1_nit_notice.pdf",
  "file_type": "application/pdf",
  "file_size": 524288,
  "uploaded_at": "2026-01-12T14:30:00Z"
}
```

---

### 6. milestones

**Purpose:** Store milestone data (MS-I to MS-V) separately for easier querying

```sql
CREATE TABLE milestones (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  work_entry_id INTEGER NOT NULL,
  milestone_name TEXT NOT NULL,
  period_months INTEGER,
  physical_target_percent REAL,
  financial_target_amount REAL,
  physical_achieved_percent REAL,
  financial_achieved_amount REAL,
  variance_amount REAL,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (work_entry_id) REFERENCES work_entries (id) ON DELETE CASCADE
);

CREATE INDEX idx_milestones_work_entry ON milestones(work_entry_id);
CREATE INDEX idx_milestones_name ON milestones(milestone_name);
```

**Fields:**
- `id` - Auto-increment primary key
- `work_entry_id` - Foreign key to work_entries
- `milestone_name` - Milestone identifier (MS-I, MS-II, MS-III, MS-IV, MS-V)
- `period_months` - Period in months
- `physical_target_percent` - Physical target percentage (0-100)
- `financial_target_amount` - Financial target amount (in Lakhs)
- `physical_achieved_percent` - Physical achieved percentage (0-100)
- `financial_achieved_amount` - Financial achieved amount (in Lakhs)
- `variance_amount` - Calculated variance (achieved - target)
- `created_at` - Timestamp when created
- `updated_at` - Timestamp when last updated

**Constraints:**
- `work_entry_id` references `work_entries(id)` with CASCADE delete

**Sample Data:**
```json
{
  "id": 1,
  "work_entry_id": 1,
  "milestone_name": "MS-I",
  "period_months": 6,
  "physical_target_percent": 20.0,
  "financial_target_amount": 100.0,
  "physical_achieved_percent": 18.5,
  "financial_achieved_amount": 95.0,
  "variance_amount": -5.0,
  "created_at": "2026-01-12T11:00:00Z",
  "updated_at": "2026-01-12T15:00:00Z"
}
```

---

## 🔗 Relationships

```
categories (1) ──< (N) projects
    ↓
projects (1) ──< (1) work_entries
    ↓
work_entries (1) ──< (N) work_entry_sections
    ↓                       ↓
    └──< (N) milestones     └──< (N) section_attachments
```

**Legend:**
- `(1)` - One
- `(N)` - Many
- `──<` - One-to-many relationship

---

## 📐 Design Rationale

### Why JSON for section_data?

1. **Flexibility:** Each section has different fields (AA has 6 fields, NIT has 12+ fields)
2. **Conditional Fields:** Fields depend on radio button selections
3. **Dynamic Tables:** Some sections have variable-length tables (3x4, 5x3)
4. **Easy Migration:** JSON can be sent to API as-is, no schema changes needed
5. **SQLite JSONB:** SQLite supports JSON functions (json_extract, json_each)
6. **PostgreSQL Ready:** PostgreSQL has excellent JSONB support with indexing

### Why separate milestones table?

1. **Querying:** Easier to query/filter by milestone
2. **Calculations:** Can aggregate across milestones
3. **Reporting:** Simplifies milestone completion reports
4. **Performance:** Faster than parsing JSON for 5 milestones

### Why TEXT for JSON in SQLite?

- SQLite stores JSON as TEXT
- PostgreSQL will use JSONB (binary, indexed, faster)
- Models handle both transparently with `jsonEncode/jsonDecode`

---

## 🚀 Migration to PostgreSQL

**Changes needed:**

1. **Primary Keys:** `INTEGER` → `SERIAL` or `BIGSERIAL`
2. **Timestamps:** `TEXT` → `TIMESTAMP` or `TIMESTAMPTZ`
3. **JSON:** `TEXT` → `JSONB`
4. **Indexes:** Add GIN indexes on JSONB columns

```sql
-- PostgreSQL version
CREATE TABLE work_entry_sections (
  id SERIAL PRIMARY KEY,
  work_entry_id INTEGER NOT NULL,
  section_name VARCHAR(50) NOT NULL,
  section_data JSONB NOT NULL,  -- JSONB instead of TEXT
  person_responsible VARCHAR(255),
  pending_with VARCHAR(255),
  held_with VARCHAR(255),
  status VARCHAR(20) DEFAULT 'not_started',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (work_entry_id) REFERENCES work_entries (id) ON DELETE CASCADE,
  UNIQUE(work_entry_id, section_name)
);

-- GIN index for JSONB queries
CREATE INDEX idx_sections_data_gin ON work_entry_sections USING GIN (section_data);

-- Query examples with JSONB
SELECT * FROM work_entry_sections
WHERE section_data->>'type' = 'accorded';

SELECT * FROM work_entry_sections
WHERE (section_data->>'amount_crore')::numeric > 50;
```

---

## ✅ Database Checklist

- [x] All tables defined
- [x] Foreign keys with CASCADE delete
- [x] Indexes on foreign keys
- [x] Indexes on query columns (status, section_name, person_responsible)
- [x] UNIQUE constraints where needed
- [x] Default values for timestamps
- [x] JSON structure documented
- [ ] Sample data inserted (Phase 4)
- [ ] Migration tested (Phase 4)
- [ ] Performance tested with 1000+ projects (Phase 7)

---

**Last Updated:** 2026-01-12
