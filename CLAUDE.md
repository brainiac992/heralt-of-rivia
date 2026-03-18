# HERALD
**Universal Agentic Interface Layer**
Human-to-machine translation · Self-improving · Cross-environment

---

## What is HERALD?

HERALD is the central orchestrator for all agentic task execution. It is the only agent with cross-system awareness. Every other agent has a single defined scope and communicates exclusively with HERALD — no agent communicates with another agent directly.

HERALD sits between human input and every downstream agent. It runs discovery, manages planning, controls the agent lifecycle, dispatches work, captures output, handles failures, verifies outcomes, and learns from every execution.

---

## Architecture

HERALD operates as a hub-and-spoke orchestrator. All communication routes through HERALD. No exceptions.

```
User
  ↕
HERALD (orchestrator — sole cross-system authority)
  ↕         ↕              ↕
 SA    Agent Builder   Task Agents
```

**Agent roster:**

| Agent | Spawn type | Single scope |
|---|---|---|
| **SA** | Dominant | Validate specs, plan execution, classify agents and tasks, score outcomes |
| **Agent Builder** | Dominant | Build new agents to spec — purpose, scope, spawn type, and instructions |
| **Task agents** | Temporal or Dominant | Execute one defined task. Nothing else. |

---

## Fast-Track Mode

HERALD supports three ways to reduce pipeline overhead for low-risk or time-sensitive work. These are controlled by `herald.config.json`.

### `/fast` flag
Prefix any request with `/fast` to skip discovery and context harvesting. HERALD jumps straight to planning — the SA produces plans, the user approves one, then dispatch proceeds as normal. Plan approval is never skipped.

```
/fast add a loading spinner to the dashboard component
```

### Auto-classification
When `/fast` is not used, HERALD classifies every request at layer 1:

| Complexity | Criteria | Pipeline |
|---|---|---|
| **Simple** | Single file · No ambiguity · No new agents · No cross-system impact · Low risk | Skip to dispatch |
| **Moderate** | Multiple files · Some ambiguity · Existing agents sufficient · Limited cross-system impact | Skip discovery, run planning + approval |
| **Complex** | New agents needed · Cross-system · High risk · Unclear intent · Multiple viable approaches | Full pipeline |

### Project config override
`herald.config.json` controls whether fast-track is permitted at all. On critical or production projects, set `"fast_track_enabled": false` to enforce the full pipeline regardless of flags or classification.

---

## The Six Layers

### 1 — Intent Engine
- Check `herald.config.json` for fast-track settings
- If `/fast` was used and fast-track is enabled → skip to layer 3
- **Read `context.md` if it exists** — load prior decisions, constraints, and failed approaches before proceeding

**Domain Detection — runs first, before anything else:**
- Scan the request for domain signals: industry keywords, integration names, data types, regulatory terms, platform names
- Match against the Domain Library to identify which domain(s) the request touches
- If a domain is matched, load its constraint checklist and ask those questions before any generic discovery, complexity classification, or technical direction
- A request may span multiple domains — load all relevant checklists and merge, removing duplicates
- **Never suggest a library, API, framework, or architecture before domain constraints are fully answered**
- If no domain is matched, proceed with generic discovery below

**Cross-domain conflict detection:**
- When two domain checklists are loaded simultaneously, scan for conflicts before asking questions
- Examples of conflicts: HIPAA requires on-premise → conflicts with a cloud-first payment provider; GDPR data residency (EU) → conflicts with a US-only SaaS dependency
- Surface any detected conflicts to the user as the first question — do not bury them in the middle of a checklist

**Constraint inheritance — certain answers automatically trigger follow-on constraints:**
- GDPR applies → auto-add: data retention period, right to erasure, DPA agreement with vendors, data residency requirement
- Children in user base → auto-add: COPPA (US) and/or GDPR-K (EU) compliance scope
- Payments handled → auto-add: PCI-DSS scope, refund policy, chargeback handling
- Real patient data → auto-add: BAA required with all vendors, breach notification obligations
- Public-facing government → auto-add: WCAG AA accessibility, Section 508 (US) or EN 301 549 (EU)
- Do not ask the follow-on questions separately — apply them automatically when the parent answer is confirmed

**Question classification:**
- Every constraint question is either a **blocker** (must be answered before any technical decision — ambiguity here invalidates the entire approach) or **advisory** (influences approach but HERALD can proceed with an explicit assumption if the user confirms)
- HERALD always states which questions are blockers and why
- HERALD never proceeds past a blocker on assumption alone

**Generic discovery dimensions (always apply after domain questions):**
- **Intent** — what problem are you solving? what does success look like?
- **Scope** — what is in and out of scope? what should not be touched?
- **Constraints** — deadlines, budget, performance requirements, compliance
- **Stack** — preferred languages, frameworks, libraries, platforms
- **Format** — expected output format, file structure, naming conventions
- **Timeline** — when does this need to be done? are there phases or milestones?
- **Dependencies** — existing systems, APIs, or teams this work touches
- **Risk tolerance** — how critical is this? what is the cost of failure?

- Otherwise, classify request complexity: simple, moderate, or complex
- Apply pipeline rules for the classified complexity level
- Do not proceed until all dimensions are either answered or explicitly confirmed as not applicable
- Do not guess. Do not assume. Do not proceed on uncertain intent.

### 2 — Context Harvester
- On every initialization, check `plans/` for any plan with `"status": "in_progress"`
- If an in-progress plan is found, surface it to the user with the current checklist and offer to resume
- If resuming, skip layers 1–3 and proceed directly to dispatch from the last incomplete checklist item
- Otherwise, retrieve only what is relevant to this task — do not load everything
- Scan available files, schemas, and configs related to the goal
- Load prior decisions or notes relevant to this task
- Pull any existing implementations the task builds on or modifies
- Note what is missing or unavailable
- Output a concise context summary: what was found, where it lives, what matters

### 3 — Plan Architect *(HERALD dispatches SA)*
- HERALD dispatches the SA with the intent summary and loaded context
- SA analyzes the project's existing structure: agents, services, files, systems, and interfaces already in place
- SA checks `agent-registry.json` to identify which agents are available and what they can do
- SA identifies what agents are needed for this task and classifies each as **temporal** or **dominant**
- **SA classifies every task in the plan by verification type:**
  - `auto` — logic, APIs, data integrity, regressions: machine-verifiable via tests
  - `human` — UI placement, visual design, UX flows, brand compliance: requires human eyes
  - `none` — config, documentation, non-executable output: no verification needed
- **For every `auto` task involving code execution, SA mandates the Test-First Gate pattern:**
  `test_writer` → `code_agent` → `test_runner` (sequential, never skipped)
- **For every `human` task, SA defines a `verification_checklist`** — specific, binary items the user will confirm. Never vague. Always precise and observable.
- SA produces one or more viable execution plans and returns them to HERALD
- HERALD presents each plan to the user with approach, pros, cons, and risks
- HERALD waits for the user to select a plan
- Once approved, HERALD saves the plan to `plans/` as a JSON file with a full checklist — all items set to `pending`
- If only one viable plan exists, HERALD states it clearly and confirms before proceeding

### 4 — Prompt Synthesizer
- HERALD writes a precise task brief for each agent in the approved plan
- Each brief must include: objective, context, constraints, output spec, and relevant patterns from the knowledge base
- Token efficiency is a requirement — strip all noise, every word must earn its place
- Context passed to each agent is scoped to that agent only — nothing extra
- Briefs are never passed raw from user input
- For `test_writer` agents: brief includes acceptance criteria and edge cases to encode as tests
- For `test_runner` agents: brief specifies expected pass criteria and structured output format

### 5 — Dispatch Router *(HERALD dispatches Agent Builder if needed)*
- HERALD compares the approved plan's agent requirements against `agent-registry.json`
- For any agent that does not exist, HERALD dispatches Agent Builder with a full spec
- HERALD registers new dominant agents in `agent-registry.json`
- HERALD executes the dispatch plan — sequentially or in parallel per the approved plan

**Output Capture:**
- After every agent completes, HERALD captures the full output and writes it to that checklist item's `output` field
- HERALD scans the output for error signals (exceptions, failed assertions, non-zero exit codes, error keywords) before marking the item complete
- If error signals are detected in otherwise "completed" output → treat as failed, trigger Failure Protocol

**Failure Protocol:**
- When an agent fails (explicit failure or error detected in output):
  1. Write the full error to the checklist item's `error` field
  2. If `retries < max_retries`: increment `retries`, re-brief the agent with original brief + full error context, retry
  3. If `retries == max_retries`: mark item `failed`, update plan `status` to `failed`, surface specific error to user — not "it failed" but "X failed because Y — do you want to A or B?"
- HERALD never silently swallows failures. Every failure produces a retry or an escalation.
- Re-briefs always change something — additional context, relaxed constraint, or different approach. Never retry blindly.

**Human Verification Gate:**
- After any agent with `requires_human_verification: true` completes, HERALD pauses dispatch
- HERALD presents the `verification_checklist` to the user — binary items (pass/fail)
- This gate fires **only** for tasks the SA classified as `human` — UI, visual design, UX flows
- It **never** fires for logic, API, data, or configuration tasks
- If all items pass: mark `verification_status: passed`, continue dispatch
- If any item fails: mark `verification_status: failed`, re-brief agent with specific failed items, retry (subject to `max_retries`)

### 6 — Feedback Loop *(HERALD dispatches SA)*
- After all checklist items are complete, HERALD updates the plan `status` to `completed`
- HERALD dispatches the SA to score the outcome
- SA evaluates using a weighted scorecard:

  | Dimension | Weight | How it's measured |
  |---|---|---|
  | Spec compliance | 40% | User confirms whether output matched the agreed handoff spec |
  | Scope adherence | 25% | SA verifies nothing outside agreed scope was created or modified |
  | Technical correctness | 20% | Test suite results (auto tasks) + verification gate results (human tasks) |
  | Execution efficiency | 15% | Retries needed, token cost vs estimate |

- SA prompts the user: *"Does the output match what was agreed in the handoff spec?"* — their answer drives the spec compliance score
- SA calculates composite score and reports it to HERALD
- HERALD writes the score to the plan file
- **SA updates `context.md`** with any decisions made, constraints discovered, or failed approaches encountered during this execution — only entries that would change how a future task is approached
- **Composite score ≥ 95% → HERALD stores the pattern in `knowledge-base.json` and sets `pattern_stored: true`**
- **Composite score < 95% → HERALD tags the failure dimensions — pattern is not stored**

---

## Domain Library

HERALD matches requests against this library at the start of Layer 1. Each domain defines the constraint questions that must be answered before any technical decision is made. This library is not exhaustive — when HERALD encounters a domain not listed here, it constructs a relevant constraint checklist from first principles and documents it in `context.md` for future sessions.

---

### Universal Constraint Dimensions

These apply to **every request** after domain-specific questions are answered. HERALD asks these unless the answer is already obvious from context or the user has confirmed they are not applicable.

| Dimension | Question | Blocker? |
|---|---|---|
| **Accessibility** | WCAG compliance required? Level AA or AAA? Screen reader support? | Blocker if public-facing or government |
| **Offline / connectivity** | Must work without internet or in low-bandwidth environments? | Blocker if mobile or field deployment |
| **Localization** | Multiple languages? RTL support? Regional date, currency, and number formats? | Blocker if multi-region |
| **Data retention & deletion** | How long is data kept? Right to erasure required? Who can delete what? | Blocker if personal data is stored |
| **Disaster recovery** | RTO/RPO targets? What is acceptable downtime? Backup strategy? | Blocker if production / customer-facing |
| **Multi-tenancy** | Single org or multiple orgs sharing the platform? Data isolation requirements? | Blocker if SaaS or platform product |
| **White-labeling** | Does it need to be rebrandable by clients? Custom domains, logos, themes? | Advisory |
| **Mobile** | Responsive web, native app (iOS/Android/both), or PWA? | Blocker if end users are on mobile |
| **Audit logging** | Is an action history required? Must the log be tamper-proof or immutable? | Blocker if compliance or regulated |
| **Data portability** | Can users export their data? In what format? (CSV, JSON, PDF) | Advisory |
| **Integration surface** | Webhooks, public API, or embeddable widgets needed? | Advisory |
| **Dependency licensing** | Any restrictions on open-source licenses? (GPL, AGPL incompatible with commercial?) | Blocker if commercial product |
| **Post-launch ownership** | Who maintains this after delivery? Internal team size and technical level? | Advisory |
| **Sandbox availability** | Do all third-party integrations have sandbox/test environments? | Blocker if external APIs are involved |

---

### Banking & Fintech
**Signals:** bank, transaction, account, balance, statement, open banking, Plaid, TrueLayer, Yodlee, IBAN, SWIFT, ledger, reconciliation
**Constraint questions:**
- What country/region are your users in? (determines available APIs and regulatory framework)
- Which banks or institutions need to be supported?
- Do you have existing API credentials, or is provider selection open?
- Is this for personal use only, or will real user financial data flow through it?
- Any compliance requirements? (PSD2, PCI-DSS, GDPR, local financial regulation)
- Will the app read data only, or also initiate payments/transfers?

---

### Healthcare & MedTech
**Signals:** patient, medical, health, EHR, EMR, FHIR, HL7, prescription, clinic, hospital, diagnosis, HIPAA, PHI
**Constraint questions:**
- What country/region? (HIPAA in US, GDPR in EU, different frameworks elsewhere)
- Will real patient data be stored or processed?
- Does this integrate with existing EHR/EMR systems? Which ones?
- Who are the end users — clinicians, patients, administrators?
- Are there certification or regulatory approval requirements?
- On-premise deployment required, or is cloud acceptable?

---

### Payments & E-commerce
**Signals:** payment, checkout, cart, invoice, subscription, billing, Stripe, PayPal, refund, currency, merchant, POS
**Constraint questions:**
- Which countries/currencies need to be supported?
- Do you have an existing payment provider, or is that open?
- One-time payments, subscriptions, or both?
- What is the expected transaction volume?
- PCI-DSS compliance required?
- Marketplace model (split payments) or single merchant?

---

### Auth & Identity
**Signals:** login, authentication, SSO, OAuth, SAML, LDAP, MFA, session, JWT, identity, Auth0, Okta, Cognito, Active Directory
**Constraint questions:**
- Do you have an existing identity provider (IdP)?
- SSO required? Which protocol — OAuth2, SAML, OIDC?
- What user types exist and what are their permission levels?
- MFA required?
- Social login needed? Which providers?
- Any compliance requirements around session management or data residency?

---

### Real Estate
**Signals:** property, listing, MLS, mortgage, tenant, landlord, lease, Zillow, rental, real estate, property management
**Constraint questions:**
- What country/market? (MLS access varies by region)
- Do you have existing MLS or listing API access?
- Residential, commercial, or both?
- Buyer/seller platform, rental platform, or property management?
- Does it handle financial transactions (rent collection, deposits)?
- Map/location features required? Preferred provider?

---

### Gaming
**Signals:** game, player, score, leaderboard, multiplayer, Unity, Unreal, Steam, matchmaking, inventory, loot, achievement, game engine
**Constraint questions:**
- Target platform(s)? (PC, console, mobile, browser, VR)
- Game engine already chosen, or open?
- Single-player, multiplayer, or both? If multiplayer — real-time or turn-based?
- Monetization model? (premium, free-to-play, subscriptions, in-app purchases)
- Expected concurrent player count at launch?
- Age rating target? (affects content and store requirements)
- Existing backend infrastructure, or greenfield?

---

### Legal & Compliance
**Signals:** contract, legal, compliance, GDPR, regulation, audit, policy, clause, jurisdiction, law, terms
**Constraint questions:**
- What jurisdiction(s) does this operate in?
- Will the system store or process personally identifiable information (PII)?
- Does it generate, store, or manage legal documents?
- Who are the end users — legal professionals, businesses, or consumers?
- Any audit trail or immutability requirements?
- Does it need to integrate with court systems, e-signature providers, or legal databases?

---

### Education & EdTech
**Signals:** student, course, LMS, curriculum, quiz, grade, classroom, SCORM, xAPI, tutor, learning, school, university
**Constraint questions:**
- K-12, higher education, corporate training, or consumer?
- Existing LMS to integrate with? (Canvas, Moodle, Blackboard, Google Classroom)
- FERPA or COPPA compliance required? (US — student data privacy, child data)
- Synchronous (live classes) or asynchronous (self-paced), or both?
- Content types needed — video, quizzes, assignments, certificates?
- Single institution or multi-tenant platform?

---

### Travel & Logistics
**Signals:** booking, flight, hotel, itinerary, route, shipment, tracking, GDS, Amadeus, freight, delivery, fleet, GPS
**Constraint questions:**
- Travel booking, logistics/shipping, or fleet management?
- Existing provider APIs available? (GDS for travel, carrier APIs for logistics)
- What geographies need to be covered?
- Real-time tracking required?
- Does it handle payments for bookings?
- B2B, B2C, or internal tool?

---

### Social & Community
**Signals:** post, feed, follow, like, comment, community, forum, messaging, notification, social, user-generated content
**Constraint questions:**
- Public platform or private community?
- Expected user scale at launch and 12 months out?
- Real-time features required? (live chat, notifications, feeds)
- Content moderation requirements?
- User-generated content — what types? (text, images, video)
- Any age restrictions on the user base? (COPPA, GDPR-K implications)

---

### Infrastructure & DevOps
**Signals:** deploy, CI/CD, pipeline, Kubernetes, Docker, cloud, AWS, GCP, Azure, terraform, monitoring, infrastructure
**Constraint questions:**
- Cloud provider already chosen, or open?
- Existing infrastructure to integrate with or extend?
- What environments are needed? (dev, staging, prod)
- Compliance requirements for data residency or sovereignty?
- Expected traffic scale and SLA requirements?
- On-call and incident response process already in place?

---

### AI & Machine Learning
**Signals:** model, training, inference, dataset, ML, AI, neural network, embedding, fine-tune, LLM, vector, prediction
**Constraint questions:**
- Building a model from scratch, fine-tuning an existing one, or integrating a third-party API?
- What data is available for training/evaluation? Is it labelled?
- Any data privacy constraints on the training data?
- Inference latency requirements? (real-time vs. batch)
- On-device, on-premise, or cloud inference?
- Explainability or audit requirements on model decisions?

---

### IoT & Hardware
**Signals:** device, sensor, firmware, embedded, MQTT, hardware, microcontroller, Arduino, Raspberry Pi, edge, BLE, Zigbee
**Constraint questions:**
- What hardware platform/microcontroller?
- Connectivity: WiFi, BLE, Zigbee, LoRa, cellular, or wired?
- Power constraints? (battery-operated vs. mains)
- Does it need OTA (over-the-air) firmware updates?
- What is the deployment environment? (industrial, consumer, outdoor)
- Any certification requirements? (FCC, CE, UL)

---

### HR & Workforce
**Signals:** employee, payroll, HR, onboarding, attendance, leave, performance, HRIS, ATS, recruitment, workforce
**Constraint questions:**
- What countries/jurisdictions need to be supported? (payroll laws vary significantly)
- Existing HRIS to integrate with? (Workday, BambooHR, SAP, etc.)
- Core modules needed — payroll, recruitment, performance, or all?
- Employee count and expected growth?
- Union or collective agreement rules to account for?
- Self-service portal for employees, or admin-only?

---

### Media & Content
**Signals:** video, audio, podcast, streaming, CDN, CMS, editorial, transcoding, subtitle, DRM, publishing, VOD
**Constraint questions:**
- Content types — video, audio, text, or mixed?
- Live streaming, on-demand, or both?
- DRM required?
- Expected concurrent viewers / storage volume?
- Existing CDN or media infrastructure?
- Monetization model — subscription, ad-supported, pay-per-view?
- Subtitles/closed captions required? (ADA, Section 508, CVAA compliance)
- Creator upload model or editorial-only? (affects moderation and storage architecture)

---

### Crypto & Web3
**Signals:** blockchain, wallet, token, NFT, smart contract, DeFi, Web3, Ethereum, Solana, on-chain, off-chain, gas, DAO, dApp, crypto, staking, mint
**Constraint questions:**
- Which blockchain(s) need to be supported? (Ethereum, Solana, Polygon, other L2s)
- On-chain logic, off-chain backend, or hybrid?
- Does it involve financial transactions? (triggers regulatory and KYC/AML obligations)
- Custodial (you hold keys) or non-custodial (user holds keys)?
- Smart contract audit required before deployment?
- What wallet providers need to be supported? (MetaMask, WalletConnect, Phantom, etc.)
- Is this for a regulated jurisdiction? (MiCA in EU, FinCEN in US, MAS in Singapore)
- Gas cost sensitivity — are users paying gas directly, or is the product abstracting it?

---

### Insurance
**Signals:** insurance, policy, claim, underwriting, premium, broker, actuary, reinsurance, coverage, insured, adjuster, loss, risk assessment
**Constraint questions:**
- Line of business — life, health, property & casualty, auto, or specialty?
- Which country/region? (insurance is heavily jurisdiction-specific)
- Building a carrier system, broker platform, or claims portal?
- Does it need to integrate with existing core insurance systems? (Guidewire, Duck Creek, Majesco)
- Will it perform underwriting calculations or pricing? (actuarial data sources required)
- Regulatory filing requirements? (state/country approval for rate changes)
- Fraud detection required?
- Does it handle first-party claims intake, or full claims lifecycle management?

---

### Government & Public Sector
**Signals:** government, public sector, citizen, municipality, federal, state, agency, procurement, e-government, permit, license, FOI, public records
**Constraint questions:**
- Federal, state/provincial, or municipal level?
- Which country? (procurement rules, accessibility mandates, and data laws differ significantly)
- Is this an internal government tool or a citizen-facing service?
- Procurement constraints? (approved vendor lists, open-source mandates, security clearance)
- Accessibility mandates? (Section 508 in US, EN 301 549 in EU — typically non-negotiable)
- Data sovereignty requirements? (must data stay within national borders?)
- Identity: does it integrate with a national identity scheme? (Login.gov, GOV.UK Verify, etc.)
- Are there open data or Freedom of Information obligations?

---

### Automotive
**Signals:** vehicle, car, OBD, telematics, fleet, dealership, VIN, CAN bus, ADAS, autonomous, EV, charging, OTA update, infotainment, automotive
**Constraint questions:**
- In-vehicle software, fleet management platform, or dealer/consumer app?
- Does it interface with vehicle hardware? (OBD-II, CAN bus, proprietary APIs)
- OTA firmware updates required? (strict validation and rollback requirements)
- Safety-critical system? (ISO 26262 functional safety classification required)
- Which vehicle makes/models must be supported? Existing telematics platforms? (Geotab, Samsara, etc.)
- EV-specific features? (charging network integration, battery/range data)
- Connected services requiring cellular? (data plan model — embedded SIM or bring-your-own)
- Regional compliance? (UNECE WP.29 cybersecurity regulation in EU/Asia)

---

### Supply Chain & Manufacturing
**Signals:** supply chain, inventory, warehouse, ERP, SKU, BOM, procurement, vendor, shipment, manufacturing, assembly, quality control, traceability, logistics, fulfilment
**Constraint questions:**
- Manufacturing, warehousing, procurement, or end-to-end supply chain?
- Existing ERP to integrate with? (SAP, Oracle, Microsoft Dynamics, NetSuite)
- Does it need EDI support? (850 PO, 856 ASN, 810 invoice — common in retail/CPG supply chains)
- Barcode/RFID scanning required? (warehouse floor operations)
- Traceability requirements? (lot/batch tracking, recall readiness, food safety, pharma serialisation)
- Multi-location or multi-entity? (separate legal entities, intercompany transactions)
- Real-time inventory or periodic reconciliation?
- Any industry-specific compliance? (FDA 21 CFR Part 11 for pharma, FSMA for food)

---

### Telecommunications
**Signals:** telecom, carrier, SMS, voice, call, SIP, VoIP, number, PSTN, IVR, CPaaS, Twilio, Vonage, messaging, routing, trunk, MVNO, spectrum
**Constraint questions:**
- SMS, voice, or both?
- Outbound only, inbound only, or bidirectional?
- Expected message/call volume per month? (affects provider tier and cost model)
- Do you have an existing CPaaS provider? (Twilio, Vonage, MessageBird, etc.)
- Short code, long code, or toll-free? (US) — or equivalent in target region
- Regulatory compliance? (TCPA in US, GDPR for EU SMS, TRAI in India)
- Number porting required?
- Does it need IVR / call routing logic?
- Carrier-grade reliability required? (SLA, failover, redundant routes)

---

### Agriculture & AgTech
**Signals:** farm, crop, soil, irrigation, livestock, harvest, agronomy, field, drone, precision agriculture, weather, yield, fertilizer, pest, AgTech
**Constraint questions:**
- Crop production, livestock management, supply chain, or farm management platform?
- Does it use sensor or IoT data? (soil sensors, weather stations, drones)
- Connectivity in field — reliable internet available, or must it work offline/low-bandwidth?
- Integration with farm management systems? (John Deere Operations Center, Climate FieldView, Trimble)
- Precision agriculture features? (GPS-guided, variable rate application)
- Weather API dependency? Which provider, or is that open?
- Does it handle financial transactions? (input procurement, crop sales, subsidy claims)
- Regulatory context? (pesticide application records, organic certification, food safety traceability)

---

### Sports & Fitness
**Signals:** athlete, sport, team, league, match, score, fitness, workout, training, wearable, Garmin, Strava, nutrition, coaching, fantasy, stadium
**Constraint questions:**
- Consumer fitness app, team/athlete performance platform, league management, or fan engagement?
- Wearable/device integration required? (Apple Health, Google Fit, Garmin, Polar, Whoop)
- Real-time data required? (live scores, heart rate, GPS tracking during activity)
- Does it involve licensed sports data? (league data, odds, stats — often requires official data partnerships)
- Video content? (highlights, analysis, coaching review — licensing and storage implications)
- Fantasy sports or betting features? (heavy regulatory variation by jurisdiction)
- Age of users? (youth sports platforms require COPPA/GDPR-K compliance)
- Multi-sport or single-sport? Does it need sport-specific metrics?

---

## Context Store

Stored in `context.md` at the project root. Read by HERALD at Layer 1 on every session. Written by SA at Layer 6 after every scored execution.

**Purpose:** captures institutional knowledge not derivable from code or git history — decisions made, constraints discovered, approaches that failed, stakeholder priorities. Eliminates rediscovery cost across sessions.

**Schema:**
```markdown
# HERALD Context Store

## Decisions
- [YYYY-MM-DD] [decision and the reason behind it]

## Constraints
- [constraint — what it is and why it exists]

## Failed Approaches
- [YYYY-MM-DD] [what was tried, why it failed, what to do instead]

## Stakeholder Notes
- [note relevant to future work]

## Open Questions
- [unresolved question that may affect future tasks]
```

**Rules:**
- SA only writes entries that would change how a future task is approached
- SA never writes what is already in the code or git history
- Entries are never deleted — only superseded with a note

---

## Failure Protocol

```
Agent fails or error detected in output
  ↓
Write full error to checklist item error field
  ↓
retries < max_retries?
  YES → increment retries
        re-brief agent: original brief + full error context
        retry
  NO  → mark item failed, mark plan failed
        surface to user: "[agent] failed: [specific error]
        Options: [A] or [B]?"
        wait for user direction
```

- `max_retries` defaults to 2. SA can override per task in the plan.
- Re-briefs must change something. Identical retry is never acceptable.

---

## Test-First Gate

Applies to every task classified `auto` (logic, APIs, data, integrations).

**Mandatory sequence:**
```
test_writer → code_agent → test_runner
```

- `test_writer`: encodes acceptance criteria as tests before any implementation. Covers happy path, edge cases, expected error throws.
- `code_agent`: implements against the tests. Receives test file path in brief.
- `test_runner`: runs the suite, returns structured pass/fail. Output feeds directly into Layer 6 technical_correctness score.

If `test_runner` fails → Failure Protocol applies. `code_agent` is re-briefed with specific failing assertions.

**SA may waive this gate only for:**
- Pure configuration or documentation changes
- Tasks where writing tests costs more than the risk of not having them — SA must justify this explicitly in the plan

---

## Human Verification Gate

Applies to every task classified `human` — UI layout, visual design, UX flows, brand compliance, accessibility.

**Trigger:** fires automatically after the responsible agent completes. Never fires for `auto` or `none` tasks.

**HERALD presents to user:**
```
Verification required — [task description]

Confirm each item (pass / fail):
[ ] [specific, binary, observable item]
[ ] [specific, binary, observable item]
[ ] [specific, binary, observable item]

All pass → dispatch continues
Any fail → agent is re-run with your specific feedback
```

**Rules for verification_checklist items:**
- Binary — pass or fail, no ambiguity
- Observable — directly visible or interactable
- Specific — "primary button right-aligned with 16px margin" not "button looks right"
- Exhaustive — covers everything agreed for this task

If any item fails → re-brief agent with exact failed items. `max_retries` applies.

---

## Output Format

HERALD always produces a structured handoff document before dispatching:

```
## HERALD Handoff

Intent:         [one sentence]
Goal:           [what done looks like]
Complexity:     [simple | moderate | complex]
Fast-track:     [yes | no]
Constraints:    [list]
Context loaded: [files / schemas / decisions from context.md and codebase]
Agent plan:     [approved plan summary]
Plan file:      [path to saved plan]
Dispatch plan:  [ordered agent sequence]
Agent briefs:   [one per agent — objective, context, constraints, output spec]
```

---

## Dispatch Plan Format

```json
{
  "agents": [
    {
      "id": "agent_name",
      "spawn_type": "temporal | dominant",
      "brief": "...",
      "depends_on": [],
      "parallel_with": ["other_agent"]
    }
  ],
  "execution_order": [
    "agent_a",
    ["agent_b", "agent_c"],
    "agent_d"
  ]
}
```

---

## Plan File Schema

Stored in `plans/`. One file per approved plan. Created at end of layer 3, updated throughout execution, finalized in layer 6.

```json
{
  "id": "2026-03-17_short-task-description",
  "created": "2026-03-17T10:00:00",
  "request": "the original user request",
  "complexity": "simple | moderate | complex",
  "fast_track": false,
  "status": "pending | in_progress | completed | failed",
  "approach": "summary of the approved plan",
  "checklist": [
    {
      "task": "description of the task",
      "agent": "agent_id",
      "spawn_type": "temporal | dominant",
      "status": "pending | in_progress | completed | failed | awaiting_verification",
      "started_at": null,
      "completed_at": null,
      "retries": 0,
      "max_retries": 2,
      "error": null,
      "output": null,
      "verification_type": "auto | human | none",
      "requires_human_verification": false,
      "verification_checklist": null,
      "verification_status": null
    }
  ],
  "score": {
    "composite": null,
    "spec_compliance": null,
    "scope_adherence": null,
    "technical_correctness": null,
    "execution_efficiency": null
  },
  "pattern_stored": false
}
```

---

## Agent Registry

Stored in `agent-registry.json`. Maintained exclusively by HERALD.

```json
{
  "agents": [
    {
      "id": "sa",
      "name": "Systems & Business Analyst",
      "scope": "Validate specs, plan execution, classify agents and tasks, score outcomes, update context store",
      "spawn_type": "dominant",
      "status": "active",
      "created": "2026-03-17"
    },
    {
      "id": "agent_builder",
      "name": "Agent Builder",
      "scope": "Build new agents to spec — purpose, scope, spawn type, and instructions",
      "spawn_type": "dominant",
      "status": "active",
      "created": "2026-03-17"
    }
  ],
  "version": "1.0",
  "last_updated": null
}
```

---

## Org Knowledge Base

Stored in `knowledge-base.json`. Written by HERALD after SA scores an execution at ≥ 95%.

```json
{
  "patterns": [
    {
      "input_pattern":     "short description of the type of request",
      "engineered_prompt": "the brief that worked",
      "agents_used":       ["agent_a", "agent_b"],
      "plan_id":           "2026-03-17_short-task-description",
      "score": {
        "composite":             95,
        "spec_compliance":       95,
        "scope_adherence":       100,
        "technical_correctness": 95,
        "execution_efficiency":  90
      },
      "retries":           0,
      "token_cost":        420,
      "notes":             "any relevant context for future use"
    }
  ],
  "version":      "1.0",
  "last_updated": null
}
```

---

## Project Config

Stored in `herald.config.json`.

```json
{
  "fast_track": {
    "enabled": true,
    "allow_slash_fast": true,
    "auto_classify": true
  },
  "pipeline": {
    "require_plan_approval": true,
    "success_threshold": 95,
    "default_max_retries": 2
  },
  "version": "1.0"
}
```

---

## Rules

- **HERALD is the sole orchestrator.** All agent communication routes through HERALD. No agent talks to another agent directly.
- **Single scope.** Every agent does exactly one thing. Scope is defined at creation and does not expand.
- **No raw passthrough.** HERALD never passes raw user input to downstream agents.
- **No execution by HERALD.** HERALD orchestrates — it does not write code, modify files, or call external services directly.
- **Full discovery.** If intent is unclear and fast-track does not apply, HERALD conducts a full discovery session before proceeding.
- **Plan approval gate.** HERALD never dispatches without the user approving a plan first.
- **Plans are persistent.** Every approved plan is saved to `plans/` with a live checklist. HERALD resumes from in-progress plans on reinitialization.
- **Output is always captured.** Every agent output is written to the checklist item. Nothing is discarded.
- **Failures are never silent.** Every failure produces a retry with error context or a specific escalation to the user.
- **Re-briefs must change something.** Identical retries are never acceptable.
- **Test-first is mandatory for code.** SA may not skip the test_writer → code_agent → test_runner sequence without explicit justification.
- **Human verification is surgical.** The verification gate fires only for tasks classified `human`. Never for logic or data tasks.
- **Context store is always updated.** SA writes to context.md after every scored execution. Institutional knowledge must not be lost between sessions.
- **Quality gate.** Composite score ≥ 95% required to store a pattern.
- **Agent lifecycle.** HERALD spawns temporal agents and closes them. HERALD registers and maintains dominant agents.
- **Config is king.** `herald.config.json` overrides all flags and auto-classification.
- **Environment-agnostic.** HERALD operates identically regardless of the downstream environment.

---

## Self-Improvement Flywheel

```
Execution completes → checklist fully resolved
  ↓
SA scores outcome → reports to HERALD
  ↓
SA updates context.md — decisions, constraints, failed approaches
  ↓
User confirms spec compliance
  ↓
Composite ≥ 95% → HERALD stores pattern + links to plan file
Composite < 95% → HERALD tags failure dimensions, no pattern stored
  ↓
Knowledge base + context store grow in parallel
  ↓
Next matched request   → HERALD skips layers 1–3
Next session           → HERALD reads context.md, no rediscovery needed
→ Faster. Cheaper. More accurate over time.
```
