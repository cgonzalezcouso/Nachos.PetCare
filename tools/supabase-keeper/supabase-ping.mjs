/**
 * Mantiene activos los proyectos Supabase del plan gratuito.
 *
 * Un ping válido escribe en public.keep_alive. Hace falta esta tabla en cada
 * proyecto (SQL Editor):
 *
 *   create table if not exists public.keep_alive (
 *     id bigint generated always as identity primary key,
 *     pinged_at timestamptz not null default now()
 *   );
 *   alter table public.keep_alive enable row level security;
 *   create policy "keepalive_insert" on public.keep_alive
 *     for insert to anon, authenticated with check (true);
 *   create policy "keepalive_select" on public.keep_alive
 *     for select to anon, authenticated using (true);
 *   create policy "keepalive_delete" on public.keep_alive
 *     for delete to anon, authenticated using (true);
 *
 * Configuración, por orden:
 *   1. SUPABASE_PROJECTS: array JSON
 *      [{"name":"app","url":"https://xxx.supabase.co","key":"..."}]
 *   2. Si no existe, SUPABASE_URL + SUPABASE_ANON_KEY.
 *
 * FAIL_ON_ERROR=false deja el proceso en 0 aunque un ping falle.
 * Con GH_TOKEN y GITHUB_REPOSITORY se abre un issue si aún no hay uno abierto.
 */

import { pathToFileURL } from 'node:url';

const ISSUE_TITLE = 'Supabase keep-alive: el ping ha fallado';
const MAX_ROWS = 5;

export function shouldFailOnError(env = process.env) {
  const value = String(env.FAIL_ON_ERROR ?? 'true').trim().toLowerCase();
  return value === 'true' || value === '1' || value === 'yes';
}

export function parseProjects(env = process.env) {
  const raw = env.SUPABASE_PROJECTS?.trim();
  if (raw) {
    let parsed;
    try {
      parsed = JSON.parse(raw);
    } catch {
      return { error: 'SUPABASE_PROJECTS no es JSON válido.' };
    }
    if (!Array.isArray(parsed) || parsed.length === 0) {
      return { error: 'SUPABASE_PROJECTS debe ser un array JSON no vacío.' };
    }

    const projects = [];
    for (const [index, item] of parsed.entries()) {
      const normalized = normalizeProject(item, index);
      if (normalized.error) return { error: normalized.error };
      projects.push(normalized.project);
    }
    return { projects };
  }

  const url = env.SUPABASE_URL?.trim();
  const key = env.SUPABASE_ANON_KEY?.trim();
  if (url && key) {
    const normalized = normalizeProject(
      { name: 'default', url, key },
      0,
    );
    if (normalized.error) return { error: normalized.error };
    return { projects: [normalized.project] };
  }
  if (url || key) {
    return {
      error: 'Faltan SUPABASE_URL o SUPABASE_ANON_KEY para el proyecto por defecto.',
    };
  }
  return { projects: [], missing: true };
}

function normalizeProject(item, index) {
  if (!item || typeof item !== 'object') {
    return { error: `El proyecto #${index + 1} no es un objeto.` };
  }
  const name = String(item.name || `project-${index + 1}`).trim();
  const url = String(item.url || item.supabaseUrl || '')
    .trim()
    .replace(/\/$/, '');
  const key = String(item.key || item.anonKey || item.anon_key || '').trim();
  if (!url.startsWith('https://')) {
    return { error: `El proyecto "${name}" necesita una url https.` };
  }
  if (!key) {
    return { error: `El proyecto "${name}" necesita una clave (key).` };
  }
  return { project: { name, url, key } };
}

export function sanitize(text) {
  return String(text ?? '')
    .replace(/eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+/g, '[redacted]')
    .replace(/[\r\n]+/g, ' ')
    .slice(0, 300);
}

export async function pingProject(project, fetchImpl = fetch) {
  const started = Date.now();
  const headers = {
    apikey: project.key,
    Authorization: `Bearer ${project.key}`,
    'Content-Type': 'application/json',
    Prefer: 'return=minimal',
  };

  try {
    const response = await fetchImpl(`${project.url}/rest/v1/keep_alive`, {
      method: 'POST',
      headers,
      body: JSON.stringify({ pinged_at: new Date().toISOString() }),
    });
    const ms = Date.now() - started;
    if (!response.ok) {
      return {
        name: project.name,
        ok: false,
        ms,
        error: `HTTP ${response.status}: ${sanitize(await readBody(response))}`,
      };
    }
    await trimOldRows(project, fetchImpl);
    return { name: project.name, ok: true, ms };
  } catch (error) {
    return {
      name: project.name,
      ok: false,
      ms: Date.now() - started,
      error: sanitize(error?.message || error),
    };
  }
}

async function trimOldRows(project, fetchImpl) {
  try {
    const headers = {
      apikey: project.key,
      Authorization: `Bearer ${project.key}`,
    };
    const list = await fetchImpl(
      `${project.url}/rest/v1/keep_alive?select=id&order=id.asc`,
      { headers },
    );
    if (!list.ok) return;
    const rows = await list.json();
    if (!Array.isArray(rows) || rows.length <= MAX_ROWS) return;
    const ids = rows
      .slice(0, rows.length - MAX_ROWS)
      .map((row) => row.id)
      .filter((id) => /^\d+$/.test(String(id)));
    if (ids.length === 0) return;
    await fetchImpl(
      `${project.url}/rest/v1/keep_alive?id=in.(${ids.join(',')})`,
      {
        method: 'DELETE',
        headers: { ...headers, Prefer: 'return=minimal' },
      },
    );
  } catch {
    // La escritura ya contó como actividad. La limpieza no debe tumbar el ping.
  }
}

async function readBody(response) {
  try {
    return await response.text();
  } catch {
    return '';
  }
}

export async function notifyFailures(results, env = process.env, fetchImpl = fetch) {
  const failed = results.filter((result) => !result.ok);
  const token = env.GH_TOKEN || env.GITHUB_TOKEN;
  const repository = env.GITHUB_REPOSITORY;
  if (failed.length === 0 || !token || !repository || !repository.includes('/')) {
    return { notified: false };
  }

  const [owner, repo] = repository.split('/');
  const api = `https://api.github.com/repos/${owner}/${repo}`;
  const headers = {
    Authorization: `Bearer ${token}`,
    Accept: 'application/vnd.github+json',
    'User-Agent': 'nachos-petcare-supabase-keeper',
    'X-GitHub-Api-Version': '2022-11-28',
  };

  try {
    const existing = await fetchImpl(
      `${api}/issues?state=open&per_page=100`,
      { headers },
    );
    if (existing.ok) {
      const issues = await existing.json();
      const alreadyOpen = Array.isArray(issues)
        && issues.some((issue) => !issue.pull_request && issue.title === ISSUE_TITLE);
      if (alreadyOpen) return { notified: false, reason: 'ya existe un issue abierto' };
    }

    const lines = failed.map(
      (result) => `- **${result.name}**: ${sanitize(result.error)}`,
    );
    const created = await fetchImpl(`${api}/issues`, {
      method: 'POST',
      headers: { ...headers, 'Content-Type': 'application/json' },
      body: JSON.stringify({
        title: ISSUE_TITLE,
        body: [
          'El mantenedor programado no pudo escribir en `public.keep_alive`.',
          '',
          ...lines,
          '',
          'Revisa el secreto `SUPABASE_PROJECTS` (o `SUPABASE_URL` y `SUPABASE_ANON_KEY`) y que la tabla `keep_alive` acepte insert, select y delete con la clave anónima.',
        ].join('\n'),
      }),
    });
    return { notified: created.ok };
  } catch {
    return { notified: false };
  }
}

export async function run(env = process.env, fetchImpl = fetch) {
  const parsed = parseProjects(env);
  if (parsed.error) {
    console.error(parsed.error);
    return shouldFailOnError(env) ? 1 : 0;
  }
  if (parsed.missing || parsed.projects.length === 0) {
    console.log(
      '::warning::No hay proyectos Supabase configurados. Define SUPABASE_PROJECTS o SUPABASE_URL y SUPABASE_ANON_KEY.',
    );
    return shouldFailOnError(env) ? 1 : 0;
  }

  console.log(
    `Supabase keep-alive: ${parsed.projects.length} proyecto(s) — ${new Date().toISOString()}`,
  );
  const results = await Promise.all(
    parsed.projects.map((project) => pingProject(project, fetchImpl)),
  );
  for (const result of results) {
    if (result.ok) {
      console.log(`ok  ${result.name} (${result.ms}ms)`);
    } else {
      console.error(`fail ${result.name} (${result.ms}ms): ${sanitize(result.error)}`);
    }
  }

  const failed = results.filter((result) => !result.ok);
  if (failed.length === 0) return 0;

  await notifyFailures(results, env, fetchImpl);
  console.log(`Resultado: ${results.length - failed.length} correctos, ${failed.length} fallidos.`);
  return shouldFailOnError(env) ? 1 : 0;
}

function isMainModule() {
  const entry = process.argv[1];
  if (!entry) return false;
  return import.meta.url === pathToFileURL(entry).href;
}

if (isMainModule()) {
  run()
    .then((code) => {
      process.exit(code);
    })
    .catch((error) => {
      console.error(sanitize(error?.message || error));
      process.exit(shouldFailOnError() ? 1 : 0);
    });
}
