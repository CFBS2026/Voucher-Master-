-- Voucher Master Pro: run once in the existing Supabase SQL Editor.
create extension if not exists pgcrypto;

create table if not exists public.app_access (
 user_id uuid primary key references auth.users(id) on delete cascade,
 email text not null, display_name text,
 approved boolean not null default false,
 is_admin boolean not null default false,
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);
create table if not exists public.projects (
 id uuid primary key default gen_random_uuid(),
 owner_id uuid not null references auth.users(id) on delete cascade,
 name text not null, created_at timestamptz not null default now()
);
create table if not exists public.vouchers (
 id uuid primary key default gen_random_uuid(),
 project_id uuid not null references public.projects(id) on delete cascade,
 code text not null, profile_name text, price numeric(12,2) not null default 0,
 status text not null default 'available', expires_at timestamptz,
 created_at timestamptz not null default now(), unique(project_id,code)
);
create table if not exists public.connected_devices (
 id uuid primary key default gen_random_uuid(), project_id uuid not null references public.projects(id) on delete cascade,
 device_name text, mac_address text, ip_address text, connected_at timestamptz not null default now()
);
create table if not exists public.blocked_devices (
 id uuid primary key default gen_random_uuid(), project_id uuid not null references public.projects(id) on delete cascade,
 device_name text, mac_address text, reason text, created_at timestamptz not null default now()
);
create table if not exists public.revenue_entries (
 id uuid primary key default gen_random_uuid(), project_id uuid not null references public.projects(id) on delete cascade,
 amount numeric(12,2) not null default 0, description text, created_at timestamptz not null default now()
);
create table if not exists public.traffic_devices (
 id uuid primary key default gen_random_uuid(), project_id uuid not null references public.projects(id) on delete cascade,
 device_name text, mac_address text, bytes_used bigint not null default 0, created_at timestamptz not null default now()
);
create table if not exists public.print_settings (
 id uuid primary key default gen_random_uuid(), project_id uuid not null unique references public.projects(id) on delete cascade,
 wifi_name text not null default '', footer_text text not null default '',
 updated_by uuid references auth.users(id), updated_at timestamptz not null default now()
);

create or replace function public.is_approved()
returns boolean language sql stable security definer set search_path=public
as $$ select exists(select 1 from public.app_access where user_id=auth.uid() and approved); $$;
create or replace function public.is_vm_admin()
returns boolean language sql stable security definer set search_path=public
as $$ select exists(select 1 from public.app_access where user_id=auth.uid() and approved and is_admin); $$;

create or replace function public.handle_new_voucher_user()
returns trigger language plpgsql security definer set search_path=public
as $$ begin
 insert into public.app_access(user_id,email,display_name,approved,is_admin)
 values(new.id,coalesce(new.email,''),coalesce(new.raw_user_meta_data->>'name',''),false,false)
 on conflict(user_id) do update set email=excluded.email;
 return new;
end; $$;
drop trigger if exists on_voucher_user_created on auth.users;
create trigger on_voucher_user_created after insert on auth.users
for each row execute procedure public.handle_new_voucher_user();

create or replace function public.admin_list_app_users()
returns table(user_id uuid,email text,display_name text,approved boolean,is_admin boolean,created_at timestamptz)
language sql security definer set search_path=public
as $$ select a.user_id,a.email,a.display_name,a.approved,a.is_admin,a.created_at
 from public.app_access a where public.is_vm_admin() order by a.created_at desc; $$;
create or replace function public.admin_set_app_access(target_user_id uuid,new_approved boolean)
returns void language plpgsql security definer set search_path=public
as $$ begin
 if not public.is_vm_admin() then raise exception 'Admin permission required'; end if;
 update public.app_access set approved=new_approved,updated_at=now() where user_id=target_user_id;
end; $$;

alter table public.app_access enable row level security;
alter table public.projects enable row level security;
alter table public.vouchers enable row level security;
alter table public.connected_devices enable row level security;
alter table public.blocked_devices enable row level security;
alter table public.revenue_entries enable row level security;
alter table public.traffic_devices enable row level security;
alter table public.print_settings enable row level security;

drop policy if exists "read own access" on public.app_access;
create policy "read own access" on public.app_access for select to authenticated
 using(user_id=auth.uid() or public.is_vm_admin());
drop policy if exists "own approved projects" on public.projects;
create policy "own approved projects" on public.projects for all to authenticated
 using(owner_id=auth.uid() and public.is_approved())
 with check(owner_id=auth.uid() and public.is_approved());

do $$ declare t text; begin
 foreach t in array array['vouchers','connected_devices','blocked_devices','revenue_entries','traffic_devices','print_settings'] loop
  execute format('drop policy if exists "owner approved access" on public.%I',t);
  execute format('create policy "owner approved access" on public.%I for all to authenticated using (public.is_approved() and exists(select 1 from public.projects p where p.id=project_id and p.owner_id=auth.uid())) with check (public.is_approved() and exists(select 1 from public.projects p where p.id=project_id and p.owner_id=auth.uid()))',t);
 end loop;
end $$;

grant select on public.app_access to authenticated;
grant select,insert,update,delete on public.projects,public.vouchers,public.connected_devices,
 public.blocked_devices,public.revenue_entries,public.traffic_devices,public.print_settings to authenticated;
grant execute on function public.admin_list_app_users() to authenticated;
grant execute on function public.admin_set_app_access(uuid,boolean) to authenticated;

-- After registering your own Gmail in the app, promote it as the first VM Admin:
-- update public.app_access set approved=true,is_admin=true where email='aungphythein@gmail.com';
