-- 在 Supabase 後台 SQL Editor 整段貼上，按 Run
create table public.souvenirs (
  id bigint primary key,
  data jsonb not null,
  updated_at timestamptz not null default now()
);
create index on public.souvenirs (updated_at);

create function public.touch_updated_at() returns trigger
language plpgsql set search_path = '' as $$
begin new.updated_at = now(); return new; end $$;

create trigger souvenirs_touch before insert or update on public.souvenirs
for each row execute function public.touch_updated_at();

alter table public.souvenirs enable row level security;

-- 只有「已登入」的人可以讀寫；因為已關閉公開註冊，能登入的只有你建立的帳號
create policy "members only" on public.souvenirs
for all to authenticated using (true) with check (true);

revoke all on public.souvenirs from anon;
grant select, insert, update, delete on public.souvenirs to authenticated;
