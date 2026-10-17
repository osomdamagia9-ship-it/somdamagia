-- O SOM DA MAGIA: tabela da pesquisa de opinião
-- Rode uma vez no Supabase: menu "SQL Editor" > New query > cole tudo > Run.

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
