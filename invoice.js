/* V6 Invoice & Accounting module */
window.LGInvoice = (() => {
  function nextNo(){
    const y=new Date().getFullYear();
    const n=(JSON.parse(localStorage.getItem("lg_invoice_seq")||"0")+1);
    localStorage.setItem("lg_invoice_seq",String(n));
    return `INV-${y}-${String(n).padStart(5,"0")}`;
  }
  function create(items, customer="", phone="", payment="Cash", discount=0){
    const subtotal=items.reduce((s,x)=>s+(+x.qty)*(+x.price),0);
    const total=Math.max(0,subtotal-(+discount||0));
    const inv={invoice_no:nextNo(),date:new Date().toISOString().slice(0,10),
      customer,phone,subtotal,discount:+discount||0,total,payment,items};
    const all=JSON.parse(localStorage.getItem("lg_invoices")||"[]");
    all.push(inv); localStorage.setItem("lg_invoices",JSON.stringify(all)); return inv;
  }
  function print(inv,biz){
    const w=window.open("","_blank","width=480,height=700");
    if(!w)return;
    w.document.write(`<html><head><title>${inv.invoice_no}</title><style>
      body{font-family:Arial;padding:20px}h2{text-align:center}.line{display:flex;justify-content:space-between}
      table{width:100%;border-collapse:collapse}td,th{padding:6px;border-bottom:1px solid #ddd;text-align:left}
    </style></head><body><h2>${biz||"London Glamour wellampittiya"}</h2>
    <p>Invoice: ${inv.invoice_no}<br>Date: ${inv.date}<br>Customer: ${inv.customer||"Walk-in"}<br>Payment: ${inv.payment}</p>
    <table><tr><th>Item</th><th>Qty</th><th>Total</th></tr>
    ${inv.items.map(x=>`<tr><td>${x.name}</td><td>${x.qty}</td><td>Rs ${(+x.qty*+x.price).toFixed(2)}</td></tr>`).join("")}
    </table><p class="line"><b>Subtotal</b><b>Rs ${inv.subtotal.toFixed(2)}</b></p>
    <p class="line"><b>Discount</b><b>Rs ${inv.discount.toFixed(2)}</b></p>
    <p class="line"><b>Total</b><b>Rs ${inv.total.toFixed(2)}</b></p><p style="text-align:center">Thank you!</p>
    <script>window.print()<\/script></body></html>`);w.document.close();
  }
  return {create,print};
})();