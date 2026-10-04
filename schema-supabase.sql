-- LYNK: pega todo esto en Supabase > SQL Editor > Run
create table categories(id bigint generated always as identity primary key,nombre text not null unique);
create table admins(id uuid primary key references auth.users(id) on delete cascade);
create table businesses(id bigint generated always as identity primary key,nombre text not null,slug text unique not null,categoria bigint references categories(id),desc_corta text,descripcion text,tel text,wa text,email text,web text,fb text,ig text,tk text,menu text,res text,otro text,dir text,zona text,lat double precision,lng double precision,abre text,cierra text,estado text not null default 'borrador' check(estado in('borrador','activo','inactivo')),destacado boolean not null default false,logo text,foto text,demo boolean default false,plan text default 'gratis',creado timestamptz default now(),actualizado timestamptz default now());
-- Preparado para el futuro (aún sin usar en la app)
create table business_stats(business_id bigint references businesses(id) on delete cascade,dia date,visitas int default 0,clics int default 0,primary key(business_id,dia));
create or replace function public.is_admin() returns boolean language sql security definer stable set search_path=public as $$select exists(select 1 from admins where id=auth.uid())$$;
alter table categories enable row level security;alter table businesses enable row level security;alter table admins enable row level security;alter table business_stats enable row level security;
create policy "cat lectura" on categories for select using(true);
create policy "cat admin" on categories for all using(is_admin()) with check(is_admin());
create policy "neg lectura" on businesses for select using(estado='activo' or is_admin());
create policy "neg admin" on businesses for all using(is_admin()) with check(is_admin());
create policy "admins propio" on admins for select using(id=auth.uid());
create policy "stats admin" on business_stats for all using(is_admin()) with check(is_admin());
insert into categories(nombre) values('Restaurantes'),('Bares'),('Hoteles'),('Servicios'),('Comercios'),('Salud'),('Belleza'),('Turismo'),('Automotriz'),('Profesionales');
insert into storage.buckets(id,name,public) values('negocios','negocios',true) on conflict do nothing;
create policy "img lectura" on storage.objects for select using(bucket_id='negocios');
create policy "img subir" on storage.objects for insert with check(bucket_id='negocios' and public.is_admin());
create policy "img editar" on storage.objects for update using(bucket_id='negocios' and public.is_admin());
create policy "img borrar" on storage.objects for delete using(bucket_id='negocios' and public.is_admin());
-- DESPUÉS de crear tu usuario en Authentication > Users, ejecuta esto con TU correo:
-- insert into admins(id) select id from auth.users where email='TU_CORREO@ejemplo.com';
