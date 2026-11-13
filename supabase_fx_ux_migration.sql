-- MiSai Development Hub - FX support for cost scenarios
-- Safe to run once; IF NOT EXISTS keeps existing data intact.

alter table public.cost_scenarios
  add column if not exists source_unit_cost numeric,
  add column if not exists source_currency text default 'EUR',
  add column if not exists fx_rate_to_eur numeric default 1,
  add column if not exists fx_rate_date date;
