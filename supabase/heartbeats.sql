-- Supabase の無料プロジェクト自動休止(7日間の低活動)を防ぐためのハートビート用テーブル。
-- .github/workflows/keepalive.yml が毎日1行INSERTする。
--
-- records への 401 GET では活動とみなされず休止したため、
-- 「成功する書き込み」に変更した経緯がある。
--
-- SQL Editor で一度だけ実行すること。

create table if not exists public.heartbeats (
  id     uuid primary key default gen_random_uuid(),
  at     timestamptz not null default now(),
  source text
);

create index if not exists heartbeats_at_idx on public.heartbeats (at desc);

alter table public.heartbeats enable row level security;

-- records と同じ方針。anon は INSERT のみ。読み取り・更新・削除は不可
drop policy if exists "anon insert only" on public.heartbeats;
create policy "anon insert only" on public.heartbeats
  for insert to anon with check (true);

-- プロジェクト設定で「新規テーブルの自動公開」をオフにしているため明示的に付与する
grant insert on public.heartbeats to anon;


-- 動作確認（ダッシュボードからは自分の権限で読めます）
-- select count(*) as 件数, max(at) as 最終 from public.heartbeats;

-- 古い行の掃除が必要になったら（年365行程度なので当面不要）
-- delete from public.heartbeats where at < now() - interval '90 days';
