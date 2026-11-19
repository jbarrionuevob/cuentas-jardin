-- =====================================================================
-- Cuentas del Jardín: configuración de Supabase
-- Pégalo completo en Supabase > SQL Editor > New query > Run (una sola vez).
-- =====================================================================

-- 1) Perfiles del equipo (nombre y rol de cada persona)
create table if not exists public.profiles (
  id         uuid primary key references auth.users(id) on delete cascade,
  name       text not null default '',
  email      text,
  role       text not null default 'pendiente'
             check (role in ('admin','empleado','pendiente','bloqueado')),
  created_at timestamptz not null default now()
);

-- 2) Todos los datos del negocio (productos, pedidos, gastos, cotizaciones, ajustes)
create table if not exists public.records (
  id         text primary key,
  kind       text not null check (kind in ('product','order','expense','quote','settings')),
  data       jsonb not null,
  updated_at timestamptz not null default now(),
  updated_by uuid references auth.users(id)
);
create index if not exists records_kind_idx on public.records(kind);

alter table public.profiles enable row level security;
alter table public.records  enable row level security;

-- 3) Rol de quien está conectado (función segura para usar en las reglas)
create or replace function public.my_role()
returns text language sql stable security definer set search_path = public as $$
  select role from public.profiles where id = auth.uid()
$$;

-- 4) Al crear una cuenta se crea su perfil. La primera cuenta es administradora;
--    las demás quedan "pendiente" hasta que el administrador las apruebe.
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, name, email, role)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'name', ''),
    new.email,
    case when exists (select 1 from public.profiles) then 'pendiente' else 'admin' end
  );
  return new;
end $$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- 5) Siempre debe quedar al menos un administrador
create or replace function public.keep_one_admin()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if old.role = 'admin' and new.role <> 'admin'
     and not exists (select 1 from public.profiles where role = 'admin' and id <> old.id) then
    raise exception 'Debe quedar al menos un administrador';
  end if;
  return new;
end $$;

drop trigger if exists keep_one_admin_trg on public.profiles;
create trigger keep_one_admin_trg
  before update on public.profiles
  for each row execute function public.keep_one_admin();

-- 6) Cada persona puede cambiar su propio nombre (pero no su rol)
create or replace function public.set_my_name(new_name text)
returns void language sql security definer set search_path = public as $$
  update public.profiles set name = left(trim(new_name), 60) where id = auth.uid();
$$;

-- 7) Quién y cuándo modificó cada registro
create or replace function public.touch_record()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  new.updated_at := now();
  new.updated_by := auth.uid();
  return new;
end $$;

drop trigger if exists touch_record_trg on public.records;
create trigger touch_record_trg
  before insert or update on public.records
  for each row execute function public.touch_record();

-- 8) Reglas de acceso
drop policy if exists profiles_read   on public.profiles;
drop policy if exists profiles_update on public.profiles;
drop policy if exists records_read    on public.records;
drop policy if exists records_insert  on public.records;
drop policy if exists records_update  on public.records;
drop policy if exists records_delete  on public.records;

-- Perfiles: cada quien ve el suyo; administradores y empleados ven a todo el equipo.
create policy profiles_read on public.profiles for select to authenticated
  using (id = auth.uid() or public.my_role() in ('admin','empleado'));
-- Solo el administrador cambia roles y nombres de otros.
create policy profiles_update on public.profiles for update to authenticated
  using (public.my_role() = 'admin') with check (public.my_role() = 'admin');

-- Datos: administrador y empleado ven, crean y editan; solo el administrador elimina.
create policy records_read   on public.records for select to authenticated
  using (public.my_role() in ('admin','empleado'));
create policy records_insert on public.records for insert to authenticated
  with check (public.my_role() in ('admin','empleado'));
create policy records_update on public.records for update to authenticated
  using (public.my_role() in ('admin','empleado'))
  with check (public.my_role() in ('admin','empleado'));
create policy records_delete on public.records for delete to authenticated
  using (public.my_role() = 'admin');

-- 9) Cambios en vivo entre teléfonos
do $$ begin
  begin alter publication supabase_realtime add table public.records;  exception when others then null; end;
  begin alter publication supabase_realtime add table public.profiles; exception when others then null; end;
end $$;
alter table public.records replica identity full;
