
-- V6 accounting / invoice extensions
create table if not exists invoices (
 id uuid primary key default gen_random_uuid(),
 business_id uuid not null references businesses(id) on delete cascade,
 invoice_no text not null,
 invoice_date date default current_date,
 customer_name text,
 customer_phone text,
 subtotal numeric(12,2) default 0,
 discount numeric(12,2) default 0,
 total numeric(12,2) default 0,
 payment_method text,
 status text default 'Paid',
 created_at timestamptz default now(),
 unique(business_id, invoice_no)
);
create table if not exists invoice_items (
 id uuid primary key default gen_random_uuid(),
 invoice_id uuid not null references invoices(id) on delete cascade,
 product_id uuid references products(id),
 product_name text not null,
 qty numeric(12,2) default 1,
 unit_price numeric(12,2) default 0,
 cost_price numeric(12,2) default 0,
 line_total numeric(12,2) default 0
);
create table if not exists stock_movements (
 id uuid primary key default gen_random_uuid(),
 business_id uuid not null references businesses(id) on delete cascade,
 product_id uuid references products(id) on delete cascade,
 movement_type text not null,
 qty numeric(12,2) not null,
 reference_id uuid,
 movement_date timestamptz default now(),
 note text
);
create table if not exists app_settings (
 id uuid primary key default gen_random_uuid(),
 business_id uuid not null references businesses(id) on delete cascade,
 setting_key text not null,
 setting_value text,
 unique(business_id, setting_key)
);
alter table invoices enable row level security;
alter table invoice_items enable row level security;
alter table stock_movements enable row level security;
alter table app_settings enable row level security;
create policy "invoice owner" on invoices for all using (is_business_owner(business_id)) with check (is_business_owner(business_id));
create policy "invoice item owner" on invoice_items for all using (
 exists(select 1 from invoices i where i.id=invoice_id and is_business_owner(i.business_id))
) with check (
 exists(select 1 from invoices i where i.id=invoice_id and is_business_owner(i.business_id))
);
create policy "stock movement owner" on stock_movements for all using (is_business_owner(business_id)) with check (is_business_owner(business_id));
create policy "settings owner" on app_settings for all using (is_business_owner(business_id)) with check (is_business_owner(business_id));
