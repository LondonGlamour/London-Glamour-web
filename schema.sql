-- London Glamour Business Manager - Supabase starter schema
create extension if not exists pgcrypto;

create table if not exists businesses (
 id uuid primary key default gen_random_uuid(),
 owner_id uuid not null references auth.users(id) on delete cascade,
 name text not null default 'London Glamour wellampittiya',
 currency text not null default 'LKR',
 created_at timestamptz default now()
);

create table if not exists products (
 id uuid primary key default gen_random_uuid(), business_id uuid not null references businesses(id) on delete cascade,
 name text not null, category text, purchase_price numeric(12,2) default 0,
 selling_price numeric(12,2) default 0, stock numeric(12,2) default 0, min_stock numeric(12,2) default 5,
 created_at timestamptz default now()
);
create table if not exists sales (
 id uuid primary key default gen_random_uuid(), business_id uuid not null references businesses(id) on delete cascade,
 sale_date date not null default current_date, product_id uuid references products(id),
 product_name text, qty numeric(12,2) default 1, total numeric(12,2) default 0,
 payment_method text, created_at timestamptz default now()
);
create table if not exists expenses (
 id uuid primary key default gen_random_uuid(), business_id uuid not null references businesses(id) on delete cascade,
 expense_date date not null default current_date, category text, description text,
 amount numeric(12,2) default 0, paid_by text, created_at timestamptz default now()
);
create table if not exists employees (
 id uuid primary key default gen_random_uuid(), business_id uuid not null references businesses(id) on delete cascade,
 name text not null, daily_salary numeric(12,2) default 0
);
create table if not exists salary_payments (
 id uuid primary key default gen_random_uuid(), business_id uuid not null references businesses(id) on delete cascade,
 employee_id uuid references employees(id), payment_date date default current_date, amount numeric(12,2) default 0
);
create table if not exists purchases (
 id uuid primary key default gen_random_uuid(), business_id uuid not null references businesses(id) on delete cascade,
 purchase_date date default current_date, product_id uuid references products(id),
 qty numeric(12,2) default 0, total_cost numeric(12,2) default 0
);
create table if not exists customers (
 id uuid primary key default gen_random_uuid(), business_id uuid not null references businesses(id) on delete cascade,
 name text, phone text, address text, note text
);
create table if not exists suppliers (
 id uuid primary key default gen_random_uuid(), business_id uuid not null references businesses(id) on delete cascade,
 name text, phone text, address text, note text
);
create table if not exists whatsapp_orders (
 id uuid primary key default gen_random_uuid(), business_id uuid not null references businesses(id) on delete cascade,
 order_date date default current_date, customer text, phone text, items text,
 amount numeric(12,2) default 0, status text default 'Pending'
);

alter table businesses enable row level security;
alter table products enable row level security;
alter table sales enable row level security;
alter table expenses enable row level security;
alter table employees enable row level security;
alter table salary_payments enable row level security;
alter table purchases enable row level security;
alter table customers enable row level security;
alter table suppliers enable row level security;
alter table whatsapp_orders enable row level security;

-- For a production deployment, add policies scoped through businesses.owner_id = auth.uid().
-- The policy template below can be repeated for each table:
create policy "owner businesses" on businesses for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());

create or replace function public.is_business_owner(bid uuid)
returns boolean language sql security definer set search_path=public as $$
 select exists(select 1 from businesses b where b.id=bid and b.owner_id=auth.uid());
$$;

create policy "products owner" on products for all using (is_business_owner(business_id)) with check (is_business_owner(business_id));
create policy "sales owner" on sales for all using (is_business_owner(business_id)) with check (is_business_owner(business_id));
create policy "expenses owner" on expenses for all using (is_business_owner(business_id)) with check (is_business_owner(business_id));
create policy "employees owner" on employees for all using (is_business_owner(business_id)) with check (is_business_owner(business_id));
create policy "salary owner" on salary_payments for all using (is_business_owner(business_id)) with check (is_business_owner(business_id));
create policy "purchases owner" on purchases for all using (is_business_owner(business_id)) with check (is_business_owner(business_id));
create policy "customers owner" on customers for all using (is_business_owner(business_id)) with check (is_business_owner(business_id));
create policy "suppliers owner" on suppliers for all using (is_business_owner(business_id)) with check (is_business_owner(business_id));
create policy "orders owner" on whatsapp_orders for all using (is_business_owner(business_id)) with check (is_business_owner(business_id));
