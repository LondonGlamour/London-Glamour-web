LONDON GLAMOUR BUSINESS MANAGER — V4 CLOUD-READY

Included:
- Responsive browser web app
- Dashboard: sales, expenses, profit, products, low stock
- Sales/POS with stock deduction
- Expenses
- Products & stock
- Purchases with stock addition
- Employees + salary
- Customers / suppliers
- WhatsApp order register
- CSV exports + JSON backup + print
- LocalStorage mode works immediately
- Supabase Auth/database starter configuration

IMPORTANT:
This package is cloud-ready, but cloud sync is NOT active until you create a Supabase project, run supabase/schema.sql, and put the project URL + anon/publishable key in config.js.

Deploy:
1. Create a Supabase project.
2. Open SQL Editor and run supabase/schema.sql.
3. Copy config.example.js to config.js.
4. Add SUPABASE_URL and SUPABASE_ANON_KEY.
5. Upload this folder to any static host (Netlify, Vercel, GitHub Pages, etc.).
6. The browser login UI will then connect to Supabase Auth.

Security:
- Never put a Supabase service_role key in config.js.
- Review RLS policies before production use.
- For true automatic server backups, use Supabase scheduled backups/managed database backups or a separate server-side backup job.

Current limitation:
The included UI still stores operational records in browser LocalStorage. The Supabase schema/auth scaffolding is included so the next integration step can replace those local CRUD calls with cloud CRUD calls. No claim of live cloud synchronization is made without credentials/project setup.


V5 CLOUD SYNC:
- Added cloud-sync.js.
- Login initializes/creates the user's business record.
- “Sync Local → Cloud” uploads local operational records into the user's Supabase business.
- RLS is enabled by the supplied schema.
- This is a safe starter sync layer; it does not claim conflict-free bidirectional synchronization.
- Before production, use UUIDs/upserts and server-side transactions for strict accounting consistency.


V6 PRODUCTION FEATURES ADDED:
- Invoice number generation (INV-YYYY-00001 format)
- Invoice creation + browser print
- Invoice database schema
- Invoice line-items schema
- Stock movement audit schema
- App settings schema
- RLS policies for the new tables
- Local invoice storage for immediate use

NEXT ACTIVATION REQUIREMENT:
To make cloud accounting fully live, the Supabase SQL files must be run in the user's own Supabase project and config.js must contain that project's URL and anon/publishable key. The package does not contain or invent credentials.
