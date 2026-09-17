/* London Glamour V5 — optional Supabase cloud sync
   This module mirrors the local data model into Supabase.
   It never uses a service_role key in the browser.
*/
window.CloudSync = (() => {
  const tables = {
    products:"products", sales:"sales", expenses:"expenses",
    employees:"employees", salary:"salary_payments", purchases:"purchases",
    customers:"customers", suppliers:"suppliers", orders:"whatsapp_orders"
  };
  let client=null, businessId=null;

  async function init(){
    if(!window.supabase || !window.SUPABASE_URL || !window.SUPABASE_ANON_KEY) return false;
    client=window.supabase.createClient(window.SUPABASE_URL,window.SUPABASE_ANON_KEY);
    const {data:{user}}=await client.auth.getUser();
    if(!user) return false;
    let {data:b}=await client.from("businesses").select("id").eq("owner_id",user.id).limit(1).maybeSingle();
    if(!b){
      const r=await client.from("businesses").insert({owner_id:user.id,name:"London Glamour wellampittiya",currency:"LKR"}).select("id").single();
      if(r.error) throw r.error; b=r.data;
    }
    businessId=b.id;
    return true;
  }

  async function pull(){
    if(!client || !businessId) return null;
    const out={};
    for(const [key,table] of Object.entries(tables)){
      const r=await client.from(table).select("*").eq("business_id",businessId);
      if(r.error) throw r.error;
      out[key]=r.data||[];
    }
    return out;
  }

  async function pushLocal(local){
    if(!client || !businessId) return false;
    // Cloud-first mirror: upload current local records using their business scope.
    // Existing cloud rows are not blindly deleted; this is intentionally conservative.
    const rows=[];
    for(const [key,table] of Object.entries(tables)){
      for(const item of (local[key]||[])){
        const row={...item,business_id:businessId};
        if(key==="products"){row.purchase_price=row.cost;row.selling_price=row.sell;row.min_stock=row.min;delete row.cost;delete row.sell;delete row.min;}
        if(key==="sales"){row.sale_date=row.date;row.payment_method=row.payment;delete row.date;delete row.payment;}
        if(key==="expenses"){row.expense_date=row.date;delete row.date;}
        if(key==="salary"){row.payment_date=row.date;delete row.date;row.employee_id=null;delete row.employee;}
        if(key==="purchases"){row.purchase_date=row.date;row.total_cost=row.cost;delete row.date;delete row.cost;}
        if(key==="orders"){row.order_date=row.Date||row.date;row.amount=+row.Amount||+row.amount||0;row.customer=row.Customer||row.customer;row.phone=row.Phone||row.phone;row.items=row.Items||row.items;row.status=row.Status||row.status;delete row.Date;delete row.Amount;delete row.Customer;delete row.Phone;delete row.Items;delete row.Status;delete row.date;}
        rows.push({table,row});
      }
    }
    // Upsert only tables whose rows have stable ids. Legacy local records don't have UUIDs,
    // so they are inserted; the app remains usable locally and cloud setup is safe.
    for(const x of rows){
      const r=await client.from(x.table).insert(x.row);
      if(r.error && !String(r.error.message||"").includes("duplicate")) throw r.error;
    }
    return true;
  }

  async function signOut(){ if(client) await client.auth.signOut(); businessId=null; }
  return {init,pull,pushLocal,signOut,getClient:()=>client};
})();
