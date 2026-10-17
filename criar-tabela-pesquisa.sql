-- O SOM DA MAGIA: tabelas da pesquisa e da moderação de comentários.
-- Rode uma vez no Supabase: SQL Editor > New query > cole tudo > Run.

create table if not exists public.pesquisa (
  id                 bigint generated always as identity primary key,
  created_at         timestamptz not null default now(),
  p1_importante      text   not null check (p1_importante in ('Sim','Talvez','Não')),
  p2_contribui       text   not null check (p2_contribui in ('Sim','Talvez','Não')),
  p3_caracteristicas text[] not null check (cardinality(p3_caracteristicas) between 1 and 5),
  p4_compraria       text   not null check (p4_compraria in ('Sim','Não')),
  p4_valor           numeric check (p4_valor is null or (p4_valor >= 0 and p4_valor <= 99999)),
  p5_recomendacao    int    not null check (p5_recomendacao between 1 and 5),
  p6_local           text   not null check (char_length(p6_local) <= 80),
  p7_sugestao        text   check (p7_sugestao is null or char_length(p7_sugestao) <= 500),
  p8_comentario      text   check (p8_comentario is null or char_length(p8_comentario) <= 500),
  nome               text   check (nome is null or char_length(nome) <= 40)
);

-- Atualiza instalações existentes da tabela.
alter table public.pesquisa
  add column if not exists p8_comentario text
  check (p8_comentario is null or char_length(p8_comentario) <= 500);

-- Segurança: visitantes só conseguem ENVIAR respostas; só você (logado) consegue LER.
alter table public.pesquisa enable row level security;

drop policy if exists "visitantes enviam respostas" on public.pesquisa;
create policy "visitantes enviam respostas"
  on public.pesquisa for insert to anon
  with check (true);

drop policy if exists "equipe le respostas" on public.pesquisa;
create policy "equipe le respostas"
  on public.pesquisa for select to authenticated
  using (true);

grant insert on public.pesquisa to anon;
grant select on public.pesquisa to authenticated;

create table if not exists public.comentarios (
  id         bigint generated always as identity primary key,
  created_at timestamptz not null default now(),
  nome       text not null default 'Visitante' check (char_length(nome) <= 40),
  texto      text not null check (char_length(texto) between 1 and 500),
  tipo       text not null default 'comentario' check (tipo in ('comentario','ideia')),
  aprovado   boolean not null default false
);

alter table public.comentarios enable row level security;

drop policy if exists "visitantes enviam comentarios" on public.comentarios;
create policy "visitantes enviam comentarios"
  on public.comentarios for insert to anon
  with check (aprovado = false);

drop policy if exists "visitantes leem comentarios aprovados" on public.comentarios;
create policy "visitantes leem comentarios aprovados"
  on public.comentarios for select to anon
  using (aprovado = true);

drop policy if exists "equipe gerencia comentarios" on public.comentarios;
create policy "equipe gerencia comentarios"
  on public.comentarios for all to authenticated
  using (true)
  with check (true);

grant insert on public.comentarios to anon;
grant select on public.comentarios to anon;
grant select, update, delete on public.comentarios to authenticated;
