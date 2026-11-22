-- MiSai Development Hub
-- Private supplier quotation documents + complete SAMPRO quotation notes
-- Safe to run multiple times.

alter table public.supplier_profiles
  add column if not exists document_path text,
  add column if not exists document_name text,
  add column if not exists sampling_notes text;

insert into storage.buckets (id, name, public)
values ('supplier-documents', 'supplier-documents', false)
on conflict (id) do update set public = false;

drop policy if exists "Authenticated users can read supplier documents" on storage.objects;
create policy "Authenticated users can read supplier documents"
on storage.objects for select
to authenticated
using (bucket_id = 'supplier-documents');

drop policy if exists "Authenticated users can upload supplier documents" on storage.objects;
create policy "Authenticated users can upload supplier documents"
on storage.objects for insert
to authenticated
with check (bucket_id = 'supplier-documents');

drop policy if exists "Authenticated users can update supplier documents" on storage.objects;
create policy "Authenticated users can update supplier documents"
on storage.objects for update
to authenticated
using (bucket_id = 'supplier-documents')
with check (bucket_id = 'supplier-documents');

drop policy if exists "Authenticated users can delete supplier documents" on storage.objects;
create policy "Authenticated users can delete supplier documents"
on storage.objects for delete
to authenticated
using (bucket_id = 'supplier-documents');

update public.supplier_profiles sp
set
  sampling_notes = 'Quotation: Sample quantity 5 pcs (2 x L + 3 x XL). Fabric swatches available before sampling; swatches free of charge, courier at buyer cost if applicable. Sample development approx. 7–10 working days after confirmation and final artwork/reference details. No separate standard sublimation setup charge currently identified; exceptional artwork, tooling or special packaging costs require prior approval.',
  included_items = 'Cutting, sewing & finishing; Hauptstoff; Standard-Sublimation; Standard-Branding/Logos; Neck Label; Size Label; Care Label; Tag Card; individuell bedruckter Polybag. Keine separate Standard-Sublimations-Setupgebühr aktuell ausgewiesen; Sonder-Artwork, Tooling oder spezielle Verpackung ggf. extra nach vorheriger Freigabe.',
  next_requirements = '1) Antwort zu echten Mesh-/Belüftungszonen + Aufpreis; 2) Artwork-/Sublimations-Template von SAMPRO; 3) Fit-Messungen und Measurement Chart; 4) finale Vektordateien; 5) finalen Größenmix; 6) bestätigen, ob ein oder mehrere Colorways bestellt werden; 7) deutsche Liefer-PLZ und später Menge; 8) GSP+/Statement-on-Origin final bestätigen; 9) finalen DAP-Versandpreis einholen.',
  updated_at = now()
from public.suppliers s
where sp.supplier_id = s.id
  and lower(s.name) like '%sampro%';

notify pgrst, 'reload schema';
