# Work Entry Form - 33 Sections Detail

**Last Updated:** 2026-01-12
**Source:** Work_entry_form_v2.docx + Details of PopUps improvidsed.docx

This document contains the complete specification for all 33+ sections in the work entry form.

---

## 📋 Section Overview

Each section has:
- **Section Name:** Unique identifier (aa, dpr, boq, etc.)
- **Section Data:** JSON object with section-specific fields
- **Person Responsible:** Free text field
- **Pending With:** Free text field
- **Held With:** Free text field
- **Tab Imprint:** Manual entry for summary badge (e.g., "100 Cr", "2026-01-05")
- **Status:** not_started, in_progress, completed

---

## 1. AA (Administrative Approval)

**Section Name:** `aa`
**Tab Imprint:** Amount (e.g., "100 Cr")

**Field Type:** Radio button (Awaited / Accorded)

**Fields:**

```json
{
  "type": "awaited" or "accorded",

  // If Awaited:
  "proposed_amount": "100",
  "date_of_proposal": "2026-01-10",
  "pending_with_whom": "Director",

  // If Accorded:
  "amount_crore_lakhs": "100",
  "aa_no": "AA/2026/001",
  "date": "2026-01-10",
  "broad_scope": "Infrastructure development for Nashik Kumbhmela"
}
```

---

## 2. DPR (Detailed Project Report)

**Section Name:** `dpr`
**Tab Imprint:** (empty or status)

**Field Type:** Checkboxes (exclusive - one at a time)

**Fields:**

```json
{
  "status": "not_started" | "in_progress" | "submitted" | "approved",
  "likely_completion_date": "2026-03-15" // If in_progress
}
```

---

## 3. BOQ (Bill of Quantities)

**Section Name:** `boq`
**Tab Imprint:** Amount

**Field Type:** Checkboxes (exclusive) + Table

**Fields:**

```json
{
  "status": "not_started" | "in_progress" | "completed",
  "likely_completion_date": "2026-02-20", // If in_progress

  // If completed: Table (5 x 3) - Dynamic rows
  "items": [
    {
      "sr_no": 1,
      "broad_item": "Civil Work",
      "amount": "300"
    },
    {
      "sr_no": 2,
      "broad_item": "Electrical Work",
      "amount": "200"
    }
  ]
}
```

**Table Structure:** Sr. No. | Broad Items | Amount (Dynamic rows)

---

## 4. Schedules

**Section Name:** `schedules`
**Tab Imprint:** (empty)

**Field Type:** Checkboxes (exclusive)

**Fields:**

```json
{
  "status": "not_started" | "in_progress" | "submitted" | "approved",
  "likely_completion_date": "2026-03-01" // If in_progress
}
```

---

## 5. Drawings

**Section Name:** `drawings`
**Tab Imprint:** (empty)

**Field Type:** Checkboxes (exclusive)

**Fields:**

```json
{
  "status": "not_started" | "in_progress" | "submitted" | "approved",
  "likely_completion_date": "2026-03-10" // If in_progress
}
```

---

## 6. Bid Documents

**Section Name:** `bid_documents`
**Tab Imprint:** (empty)

**Field Type:** Checkboxes (exclusive)

**Fields:**

```json
{
  "status": "not_started" | "in_progress" | "submitted" | "approved",
  "likely_completion_date": "2026-03-20" // If in_progress
}
```

---

## 7. ENV (Environmental Clearance)

**Section Name:** `env`
**Tab Imprint:** (empty)

**Field Type:** Radio button (Not Applicable / Applicable)

**Fields:**

```json
{
  "applicability": "not_applicable" | "applicable",

  // If applicable:
  "proposal_status": "not_started" | "under_preparation" | "submitted",
  "submission_date": "2026-01-15", // If submitted
  "status_remarks": "Awaiting approval from forest department"
}
```

---

## 8. LA (Land Acquisition)

**Section Name:** `la`
**Tab Imprint:** Area in Ha

**Field Type:** Radio button (Not Applicable / Applicable)

**Fields:**

```json
{
  "applicability": "not_applicable" | "applicable",

  // If applicable:
  "area_hectares": "25.5",
  "proposal_status": "not_started" | "under_preparation" | "submitted",
  "submission_date": "2026-01-20", // If submitted
  "status_remarks": "Land survey completed"
}
```

---

## 9. Utility Shifting Details

**Section Name:** `utility_shifting`
**Tab Imprint:** (empty)

**Field Type:** Radio button (Not Applicable / Applicable)

**Fields:**

```json
{
  "applicability": "not_applicable" | "applicable",

  // If applicable:
  "proposal_status": "not_started" | "under_preparation" | "submitted",
  "submission_date": "2026-01-25", // If submitted
  "status_remarks": "Electricity poles to be shifted"
}
```

---

## 10. TS (Technical Sanction)

**Section Name:** `ts`
**Tab Imprint:** Amount

**Field Type:** Radio button (Awaited / Accorded) + Table

**Fields:**

```json
{
  "type": "awaited" | "accorded",

  // If Awaited:
  "proposal_status": "not_started" | "in_progress",
  "likely_submission_date": "2026-02-15",
  "status_remarks": "Under technical review",

  // If Accorded:
  "amount_crore_lakhs": "95",
  "ts_no": "TS/2026/002",
  "date": "2026-01-18",

  // Detailed Scope Table (8 x 3) - Dynamic rows
  "scope_items": [
    {
      "sr_no": 1,
      "broad_item": "Road Construction",
      "amount": "50"
    },
    {
      "sr_no": 2,
      "broad_item": "Bridge Construction",
      "amount": "45"
    }
  ]
}
```

**Table Structure:** Sr. No. | Broad Items | Amount (Dynamic rows)

---

## 11. NIT (Notice Inviting Tender)

**Section Name:** `nit`
**Tab Imprint:** Date

**Field Type:** Radio button (Not Issued / Issued) + 2 Tables + Photo upload

**Fields:**

```json
{
  "is_issued": false | true,

  // If Not Issued:
  "likely_issue_date": "2026-02-01",

  // If Issued:
  "issue_date": "2026-01-20",
  "amount_crore_lakhs": "500",
  "photo_path": "/path/to/nit_document.pdf", // Optional photo upload

  // Table 1: Broad Items (4 x 3) - Dynamic rows
  "items": [
    {
      "sr_no": 1,
      "broad_item": "Civil Work",
      "amount": "300"
    },
    {
      "sr_no": 2,
      "broad_item": "Electrical",
      "amount": "200"
    }
  ],

  // Details
  "prebid_date": "2026-01-10",
  "submission_date": "2026-01-20",

  // Table 2: EMD Amounts (4 x 3) - Dynamic rows
  "emd_amounts": [
    {
      "sr_no": 1,
      "broad_item": "Civil Work",
      "amount": "15"
    },
    {
      "sr_no": 2,
      "broad_item": "Electrical",
      "amount": "10"
    }
  ]
}
```

**Tables:**
- Table 1: Sr. No. | Broad Items | Amount (Dynamic)
- Table 2: Sr. No. | Broad Items | Amount (EMD) (Dynamic)

---

## 12. Pre-bid

**Section Name:** `prebid`
**Tab Imprint:** Date

**Fields:**

```json
{
  "date": "2026-01-10",
  "bidders_participated": 8,
  "written_applications": 5
}
```

---

## 13. CSD (Common Set of Deviations)

**Section Name:** `csd`
**Tab Imprint:** Date

**Field Type:** Multiple checkboxes (can select multiple)

**Fields:**

```json
{
  "queries_reply_in_progress": true,
  "replies_submitted_for_approval": false,
  "replies_approved": false,
  "csd_uploaded": false,
  "csd_upload_date": "2026-01-15" // If uploaded
}
```

---

## 14. Bid Submission

**Section Name:** `bid_submission`
**Tab Imprint:** Date

**Fields:**

```json
{
  "submission_date": "2026-01-20",
  "bidders_tendered": 6,
  "emd_verification_done": true
}
```

---

## 15. Technical Evaluation

**Section Name:** `tech_evaluation`
**Tab Imprint:** # of qualified bidders

**Field Type:** Checkboxes (exclusive)

**Fields:**

```json
{
  "status": "in_progress" | "completed" | "results_published" | "financial_bid_opening_informed",
  "likely_completion_date": "2026-02-01", // If in_progress
  "qualified_bidders": 4, // If completed
  "financial_bid_opening_date": "2026-02-10" // If informed
}
```

---

## 16. Financial Bid

**Section Name:** `financial_bid`
**Tab Imprint:** Date & #

**Fields:**

```json
{
  "opening_date": "2026-02-10",
  "qualified_bidders_participated": 4,
  "bid_type": "l1" | "h1", // L1 or H1 offer
  "offer_amount_lakhs_cr": "480",
  "percentage_above_below": "-4.0" // Can be positive or negative
}
```

---

## 17. Bid Acceptance

**Section Name:** `bid_acceptance`
**Tab Imprint:** % +/- #

**Field Type:** Radio buttons (5 options - exclusive)

**Fields:**

```json
{
  "status": "in_progress" | "submitted" | "approved" | "board_approval" | "accepted"
}
```

---

## 18. LOA (Letter of Acceptance)

**Section Name:** `loa`
**Tab Imprint:** Date

**Field Type:** Radio buttons (Issued / Not issued)

**Fields:**

```json
{
  "is_issued": true | false,
  "issue_date": "2026-02-15", // If issued
  "not_issued_reasons": "Awaiting board approval" // If not issued
}
```

---

## 19. PBG (Performance Bank Guarantee)

**Section Name:** `pbg`
**Tab Imprint:** Date

**Field Type:** Radio buttons (Not submitted / Submitted)

**Fields:**

```json
{
  "is_submitted": false | true,

  // If submitted:
  "submission_date": "2026-02-20",
  "amount": "48",
  "period_months": 24
}
```

---

## 20. Work Order

**Section Name:** `work_order`
**Tab Imprint:** Date, Amount

**Fields:**

```json
{
  "contractor_name": "ABC Construction Pvt Ltd",
  "is_issued": false | true,

  // If not issued:
  "not_issued_reasons": "PBG pending",

  // If issued:
  "issue_date": "2026-02-25",
  "amount": "480",
  "percentage_above_below": "-4.0",
  "tender_period_months": 24,
  "wo_no": "WO/2026/001"
}
```

---

## 21. Agreement

**Section Name:** `agreement`
**Tab Imprint:** Amount

**Fields:**

```json
{
  "agreement_amount_lakhs": "480",
  "appointed_date": "2026-03-01",
  "tender_period_months": 24
}
```

**Note:** This amount is used for calculating percentage in Expenditure section.

---

## 22-26. Milestones (MS-I to MS-V)

**Section Names:** `ms_i`, `ms_ii`, `ms_iii`, `ms_iv`, `ms_v`
**Tab Imprint:** LD Amount

**Note:** Milestones are stored in separate `milestones` table, not in work_entry_sections.

**Fields (per milestone):**

```json
{
  "period_months": 6,
  "physical_target_percent": 20.0,
  "financial_target_amount": 96.0,
  "physical_achieved_percent": 18.5,
  "financial_achieved_amount": 92.0,
  "variance_amount": -4.0 // Calculated: achieved - target
}
```

---

## 27. LD (Liquidated Damages)

**Section Name:** `ld`
**Tab Imprint:** Amount

**Field Type:** Radio buttons + conditional fields

**Fields:**

```json
{
  "applicability": "not_applicable" | "applicable",

  // If applicable:
  "amount_imposed_per_week": "2.0",
  "amount_recovered": "8.0",
  "amount_deposited": "8.0",
  "amount_released": "2.0",
  "final_amount_recovered": "6.0"
}
```

---

## 28. EOT (Extension of Time)

**Section Name:** `eot`
**Tab Imprint:** # of Months

**Field Type:** Radio buttons + multiple checkboxes

**Fields:**

```json
{
  "applicability": "not_applicable" | "applicable",

  // If applicable:
  "proposal_status": "not_started" | "under_consideration" | "submitted" | "approved",
  "consideration_period_months": 3, // If under consideration
  "submission_date": "2026-03-15", // If submitted
  "approved_period_months": 3, // If approved

  // Multiple checkboxes (can select multiple):
  "with_escalation": true,
  "without_escalation": false,
  "by_freezing_indices": false,
  "without_ld": true,
  "with_ld": false,
  "compensation_payable": true,
  "compensation_claimed_amount": "5.0",
  "compensation_admitted_amount": "4.5"
}
```

---

## 29. COS (Change of Scope)

**Section Name:** `cos`
**Tab Imprint:** Amount

**Field Type:** Radio buttons + 2 tables

**Fields:**

```json
{
  "applicability": "not_applicable" | "applicable",

  // If applicable:
  "proposal_status": "not_started" | "under_consideration" | "submitted" | "approved",

  // Table 1: Under Consideration (3 x 4) - Dynamic rows
  "consideration_items": [
    {
      "sr_no": 1,
      "broad_item": "Additional Bridge",
      "amount": "50",
      "reasons": "Changed route alignment"
    }
  ],

  "submission_date": "2026-03-20", // If submitted

  // Table 2: Approved (3 x 7) - Dynamic rows
  "approved_items": [
    {
      "sr_no": 1,
      "item_description": "Additional Bridge",
      "original_amount": "0",
      "revised_amount": "50",
      "increase_decrease": "+50",
      "approval_date": "2026-03-25",
      "approval_no": "COS/2026/001",
      "remarks": "Board approved"
    }
  ]
}
```

**Tables:**
- Table 1: Sr. No. | Broad Items | Amount | Reasons (Dynamic)
- Table 2: Sr. No. | Item | Original Amt | Revised Amt | +/- | Date | Approval No. | Remarks (Dynamic)

---

## 30. Expenditure

**Section Name:** `expenditure`
**Tab Imprint:** % of Agreement amount

**Fields:**

```json
{
  "cumulative_amount": "250.0",
  "percentage_of_agreement": "52.08" // Auto-calculated: (amount / agreement_amount) * 100
}
```

**Note:** `agreement_amount` is fetched from Agreement section (section 21).

---

## 31. Audit Para

**Section Name:** `audit_para`
**Tab Imprint:** # & Date

**Field Type:** Radio buttons + 3 tables

**Fields:**

```json
{
  "applicability": "not_applicable" | "applicable",

  // If applicable:
  "draft_paras_count": 5,

  // Table 1: Details of paras (3 x 4) - Dynamic rows
  "para_details": [
    {
      "sr_no": 1,
      "short_description": "Delay in land acquisition",
      "date_of_issue": "2025-12-01",
      "remarks": "Under review"
    }
  ],

  "responsible_person": "Executive Engineer",

  // Table 2: Replies Submitted (3 x 4) - Dynamic rows
  "replies_submitted": [
    {
      "sr_no": 1,
      "short_description": "Delay in land acquisition",
      "date_of_submission": "2026-01-15",
      "status": "Pending"
    }
  ],

  // Table 3: Paras Closed (3 x 4) - Dynamic rows
  "paras_closed": [
    {
      "sr_no": 1,
      "short_description": "Minor procedural issue",
      "date_of_closure": "2026-01-20",
      "remarks": "Resolved"
    }
  ]
}
```

**Tables:**
- Table 1: Sr. No. | Para Short Description | Date of issue | Remarks (Dynamic)
- Table 2: Sr. No. | Para Short Description | Date of submission | Status (Dynamic)
- Table 3: Sr. No. | Para Short Description | Date of Closure | Remarks (Dynamic)

---

## 32. LAQ (Legislative Questions)

**Section Name:** `laq`
**Tab Imprint:** (empty)

**Field Type:** Radio buttons + 4 tables

**Fields:**

```json
{
  "applicability": "not_applicable" | "applicable",

  // If applicable:
  "laqs_count": 2,
  "lcqs_count": 1,
  "lakshvwdhi_count": 0,
  "others_count": 1,

  // Table 1: Details of Questions (3 x 4) - Dynamic rows
  "question_details": [
    {
      "sr_no": 1,
      "laq_lcq_no": "LAQ/2026/045",
      "date_of_question": "2025-11-20",
      "remarks": "Project delay inquiry"
    }
  ],

  "responsible_person": "Project Director",

  // Table 2: Replies Submitted (3 x 4) - Dynamic rows
  "replies_submitted": [
    {
      "sr_no": 1,
      "laq_lcq_no": "LAQ/2026/045",
      "date_of_reply": "2025-12-05",
      "remarks": "Detailed explanation provided"
    }
  ],

  // Table 3: Promises given by Minister (3 x 4) - Dynamic rows
  "promises_given": [
    {
      "sr_no": 1,
      "laq_lcq_no": "LAQ/2026/045",
      "date_of_question": "2025-11-20",
      "remarks": "Complete by March 2026"
    }
  ],

  // Table 4: Promises Compliance (3 x 5) - Dynamic rows
  "promises_compliance": [
    {
      "sr_no": 1,
      "laq_lcq_no": "LAQ/2026/045",
      "date_of_promise": "2025-11-20",
      "promise_contents": "Complete project by March 2026",
      "action_taken": "Expedited construction, 85% complete"
    }
  ]
}
```

**Tables:**
- Table 1: Sr. No. | LAQ/LCQ No. | Date of Question | Remarks (Dynamic)
- Table 2: Sr. No. | LAQ/LCQ No. | Date of Reply submitted | Remarks (Dynamic)
- Table 3: Sr. No. | LAQ/LCQ No. | Date of Question | Remarks (Dynamic)
- Table 4: Sr. No. | LAQ/LCQ No. | Date of Promise | Promise contents | Action taken (Dynamic)

---

## 33. Technical Audit

**Section Name:** `technical_audit`
**Tab Imprint:** (empty)

**Field Type:** Radio buttons + fields

**Fields:**

```json
{
  "status": "not_done" | "carried_out",

  // If carried out:
  "findings_count": 3,
  "findings_details": "Minor structural issues in bridge pier, drainage inadequate",
  "responsible_ee": "Executive Engineer (Civil)",
  "compliance_submitted": "2",
  "compliance_dates": "2026-01-10, 2026-01-25"
}
```

---

## 34. Rev AA (Revised Administrative Approval)

**Section Name:** `rev_aa`
**Tab Imprint:** Amount

**Field Type:** Radio buttons + conditional fields

**Fields:**

```json
{
  "requirement": "not_required" | "necessary",

  // If necessary:
  "reasons": "Scope change due to additional bridge construction",
  "amount_proposed_crore_lakhs": "150",
  "status": "in_progress" | "submitted" | "approved" | "board_approval" | "accorded",

  // If accorded:
  "revised_aa_no": "RAA/2026/001",
  "date": "2026-03-30",
  "recap_sheet_photo_path": "/path/to/recap_sheet.pdf" // Table photo upload
}
```

---

## 35. Supplementary Agreement

**Section Name:** `supplementary_agreement`
**Tab Imprint:** (empty)

**Field Type:** Radio buttons + fields

**Fields:**

```json
{
  "applicability": "not_applicable" | "applicable",

  // If applicable:
  "necessity": "Additional work scope approved",
  "amount_lakhs": "50",
  "date": "2026-04-01",
  "scope_of_work": "Construction of additional drainage system",
  "period_months": 6
}
```

---

## 🔢 Section Name Constants

```dart
class WorkEntrySections {
  static const String aa = 'aa';
  static const String dpr = 'dpr';
  static const String boq = 'boq';
  static const String schedules = 'schedules';
  static const String drawings = 'drawings';
  static const String bidDocuments = 'bid_documents';
  static const String env = 'env';
  static const String la = 'la';
  static const String utilityShifting = 'utility_shifting';
  static const String ts = 'ts';
  static const String nit = 'nit';
  static const String prebid = 'prebid';
  static const String csd = 'csd';
  static const String bidSubmission = 'bid_submission';
  static const String techEvaluation = 'tech_evaluation';
  static const String financialBid = 'financial_bid';
  static const String bidAcceptance = 'bid_acceptance';
  static const String loa = 'loa';
  static const String pbg = 'pbg';
  static const String workOrder = 'work_order';
  static const String agreement = 'agreement';
  static const String msI = 'ms_i';
  static const String msII = 'ms_ii';
  static const String msIII = 'ms_iii';
  static const String msIV = 'ms_iv';
  static const String msV = 'ms_v';
  static const String ld = 'ld';
  static const String eot = 'eot';
  static const String cos = 'cos';
  static const String expenditure = 'expenditure';
  static const String auditPara = 'audit_para';
  static const String laq = 'laq';
  static const String technicalAudit = 'technical_audit';
  static const String revAa = 'rev_aa';
  static const String supplementaryAgreement = 'supplementary_agreement';
}
```

---

## 📊 Tab Imprint Summary

| Section | Tab Imprint Example |
|---------|-------------------|
| AA | "100 Cr" |
| BOQ | "500 Lakhs" |
| LA | "25.5 Ha" |
| TS | "95 Cr" |
| NIT | "2026-01-20" |
| Pre-Bid | "2026-01-10" |
| CSD | "2026-01-15" |
| Bid Submission | "2026-01-20" |
| Tech Evaluation | "4" (qualified) |
| Financial Bid | "2026-02-10 & 4" |
| Bid Acceptance | "-4%" |
| LOA | "2026-02-15" |
| PBG | "2026-02-20" |
| Work Order | "2026-02-25, 480L" |
| Agreement | "480 Lakhs" |
| Tender Period | "24 months" |
| Milestone | "6 Lakhs" (LD) |
| LD | "6 Lakhs" |
| EOT | "3 months" |
| COS | "50 Lakhs" |
| Expenditure | "52.08%" |
| Audit Para | "5 & 2025-12-01" |
| Rev AA | "150 Cr" |

---

**Document Created:** 2026-01-12
**Maintained By:** Development Team
