#!/usr/bin/env node
/**
 * Mantenedor Supabase — ping keep-alive para proyectos free-tier.
 *
 * Configuración (una de las dos):
 * 1. SUPABASE_PROJECTS — JSON array:
 *    [{"name":"app","url":"https://xxx.supabase.co","key":"anon-or-publishable-key"}]
 * 2. SUPABASE_URL + SUPABASE_ANON_KEY — un único proyecto
 *
 * FAIL_ON_ERROR=true hace fallar el proceso si algún ping falla (por defecto: false).
 */

const FAIL_ON_ERROR = String(process.env.FAIL_ON_ERROR || 'false').toLowerCase() === 'true';

function loadProjects() {
  const raw = process.env.SUPABASE_PROJECTS?.trim();
  if (raw) {
    let projects;
    try {
      projects = JSON.parse(raw);
    } catch {
      throw new Error('SUPABASE_PROJECTS no es JSON válido');
    }
    if (!Array.isArray(projects) || projects.length === 0) {
      throw new Error('SUPABASE_PROJECTS debe ser un array JSON no vacío');
    }
    return projects.map((p, i) => ({
      name: p.name || `project-${i + 1}`,
      url: (p.url || '').replace(/\/$/, ''),
      key: p.key || p.anon_key || p.anonKey,
    }));
  }

  const url = process.env.SUPABASE_URL?.trim()?.replace(/\/$/, '');
  const key = process.env.SUPABASE_ANON_KEY?.trim();
  if (url && key) {
    return [{ name: 'default', url, key }];
  }

  throw new Error(
    'Falta configuración. Define el secret SUPABASE_PROJECTS (JSON) ' +
      'o bien SUPABASE_URL + SUPABASE_ANON_KEY.',
  );
}

async function pingProject({ name, url, key }) {
  const start = Date.now();
  if (!url || !key) {
    return { name, ok: false, ms: 0, error: 'Faltan url o key' };
  }

  try {
    // POSTGREST /rest/v1/ realiza actividad real de base de datos
    // (a diferencia de /auth/v1/health), lo que resetea el timer de inactividad.
    const response = await fetch(`${url}/rest/v1/`, {
      method: 'GET',
      headers: {
        apikey: key,
        Authorization: `Bearer ${key}`,
      },
      signal: AbortSignal.timeout(30_000),
    });

    const ms = Date.now() - start;
    // Cualquier respuesta HTTP del API indica que el proyecto está despierto.
    // 401/404 siguen contando: el edge recibió la petición.
    if (response.status >= 500) {
      return {
        name,
        ok: false,
        ms,
        error: `HTTP ${response.status}`,
      };
    }

    console.log(` ✓ ${name} — OK (${ms}ms, HTTP ${response.status})`);
    return { name, ok: true, ms, status: response.status };
  } catch (err) {
    const ms = Date.now() - start;
    const message = err?.message || String(err);
    console.error(` ✗ ${name} — ${message} (${ms}ms)`);
    return { name, ok: false, ms, error: message };
  }
}

async function main() {
  console.log(`\n🏓 Supabase Keep-Alive — ${new Date().toISOString()}\n`);

  let projects;
  try {
    projects = loadProjects();
  } catch (err) {
    console.error(`ERROR: ${err.message}`);
    process.exit(FAIL_ON_ERROR ? 1 : 0);
  }

  console.log(`Pinging ${projects.length} proyecto(s)...\n`);

  const results = [];
  for (const project of projects) {
    results.push(await pingProject(project));
  }

  const passed = results.filter((r) => r.ok).length;
  const failed = results.filter((r) => !r.ok).length;

  console.log(`\nResumen: ${passed} ok, ${failed} fallidos\n`);

  if (failed > 0 && FAIL_ON_ERROR) {
    process.exit(1);
  }
}

main();
