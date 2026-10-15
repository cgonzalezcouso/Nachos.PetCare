import assert from 'node:assert/strict';
import { describe, it } from 'node:test';

import {
  notifyFailures,
  parseProjects,
  pingProject,
  run,
  sanitize,
  shouldFailOnError,
} from './supabase-ping.mjs';

const project = {
  name: 'nachos',
  url: 'https://example.supabase.co',
  key: 'anon-key',
};

function jsonResponse(body, status = 200) {
  return {
    ok: status >= 200 && status < 300,
    status,
    async text() {
      return typeof body === 'string' ? body : JSON.stringify(body);
    },
    async json() {
      return body;
    },
  };
}

describe('parseProjects', () => {
  it('lee el array JSON y acepta alias de clave', () => {
    const parsed = parseProjects({
      SUPABASE_PROJECTS: JSON.stringify([
        { name: 'a', url: 'https://a.supabase.co/', anonKey: 'k1' },
        { supabaseUrl: 'https://b.supabase.co', anon_key: 'k2' },
      ]),
    });
    assert.deepEqual(parsed.projects, [
      { name: 'a', url: 'https://a.supabase.co', key: 'k1' },
      { name: 'project-2', url: 'https://b.supabase.co', key: 'k2' },
    ]);
  });

  it('rechaza urls que no son https y JSON inválido', () => {
    assert.match(
      parseProjects({
        SUPABASE_PROJECTS: JSON.stringify([
          { name: 'a', url: 'http://a.supabase.co', key: 'k' },
        ]),
      }).error,
      /https/,
    );
    assert.match(parseProjects({ SUPABASE_PROJECTS: '{no' }).error, /JSON/);
    assert.match(parseProjects({ SUPABASE_PROJECTS: '[]' }).error, /array/);
  });

  it('usa SUPABASE_URL y SUPABASE_ANON_KEY si no hay lista', () => {
    const parsed = parseProjects({
      SUPABASE_URL: 'https://only.supabase.co/',
      SUPABASE_ANON_KEY: 'anon',
    });
    assert.deepEqual(parsed.projects, [
      { name: 'default', url: 'https://only.supabase.co', key: 'anon' },
    ]);
    assert.equal(parseProjects({}).missing, true);
    assert.match(
      parseProjects({ SUPABASE_URL: 'https://only.supabase.co' }).error,
      /SUPABASE_ANON_KEY/,
    );
  });
});

describe('shouldFailOnError', () => {
  it('falla por defecto y respeta false', () => {
    assert.equal(shouldFailOnError({}), true);
    assert.equal(shouldFailOnError({ FAIL_ON_ERROR: 'false' }), false);
    assert.equal(shouldFailOnError({ FAIL_ON_ERROR: '0' }), false);
    assert.equal(shouldFailOnError({ FAIL_ON_ERROR: 'yes' }), true);
  });
});

describe('sanitize', () => {
  it('oculta JWT y recorta el texto', () => {
    const token = `eyJhbGciOiJIUzI1NiJ9.${'a'.repeat(20)}.${'b'.repeat(20)}`;
    const clean = sanitize(`fallo ${token}\nlinea`);
    assert.equal(clean.includes(token), false);
    assert.match(clean, /\[redacted\]/);
    assert.equal(clean.includes('\n'), false);
  });
});

describe('pingProject', () => {
  it('inserta una fila y borra el exceso', async () => {
    const calls = [];
    const fetchImpl = async (url, options = {}) => {
      calls.push({ url, method: options.method || 'GET', body: options.body });
      if (options.method === 'POST') return jsonResponse('', 201);
      if (String(url).includes('select=id')) {
        return jsonResponse([{ id: 1 }, { id: 2 }, { id: 3 }, { id: 4 }, { id: 5 }, { id: 6 }]);
      }
      return jsonResponse('', 204);
    };

    const result = await pingProject(project, fetchImpl);
    assert.equal(result.ok, true);
    assert.equal(calls[0].method, 'POST');
    assert.match(calls[0].url, /\/rest\/v1\/keep_alive$/);
    assert.match(calls[2].url, /id=in\.\(1\)/);
    assert.equal(calls[2].method, 'DELETE');
    assert.equal(JSON.parse(calls[0].body).pinged_at.includes('T'), true);
  });

  it('informa el HTTP de error sin lanzar', async () => {
    const fetchImpl = async () => jsonResponse('relation keep_alive does not exist', 404);
    const result = await pingProject(project, fetchImpl);
    assert.equal(result.ok, false);
    assert.match(result.error, /HTTP 404/);
  });
});

describe('run', () => {
  it('avisa y sale 0 si no hay configuración y FAIL_ON_ERROR es false', async () => {
    const code = await run({ FAIL_ON_ERROR: 'false' }, async () => {
      throw new Error('no debería llamar a la red');
    });
    assert.equal(code, 0);
  });

  it('sale 1 si no hay configuración y FAIL_ON_ERROR está activo', async () => {
    const code = await run({ FAIL_ON_ERROR: 'true' }, async () => jsonResponse('', 201));
    assert.equal(code, 1);
  });

  it('sale 0 cuando el insert responde bien', async () => {
    const code = await run(
      {
        SUPABASE_URL: 'https://example.supabase.co',
        SUPABASE_ANON_KEY: 'anon-key',
      },
      async (url, options = {}) => {
        if (options.method === 'POST') return jsonResponse('', 201);
        return jsonResponse([{ id: 1 }]);
      },
    );
    assert.equal(code, 0);
  });

  it('no tumba el job si FAIL_ON_ERROR es false y abre un solo issue', async () => {
    const calls = [];
    const fetchImpl = async (url, options = {}) => {
      calls.push({ url: String(url), method: options.method || 'GET' });
      if (String(url).includes('api.github.com') && options.method === 'POST') {
        return jsonResponse({ number: 7 }, 201);
      }
      if (String(url).includes('api.github.com')) return jsonResponse([]);
      if (options.method === 'POST') return jsonResponse('denied', 401);
      return jsonResponse([], 401);
    };

    const env = {
      SUPABASE_PROJECTS: JSON.stringify([project]),
      FAIL_ON_ERROR: 'false',
      GH_TOKEN: 'ghs_test',
      GITHUB_REPOSITORY: 'cgonzalezcouso/Nachos.PetCare',
    };
    assert.equal(await run(env, fetchImpl), 0);
    const created = calls.filter((call) => call.method === 'POST' && call.url.endsWith('/issues'));
    assert.equal(created.length, 1);

    const fetchWithOpenIssue = async (url, options = {}) => {
      if (String(url).includes('api.github.com')) {
        return jsonResponse([{ title: 'Supabase keep-alive: el ping ha fallado' }]);
      }
      return fetchImpl(url, options);
    };
    const before = calls.length;
    assert.equal(await run(env, fetchWithOpenIssue), 0);
    const extraIssues = calls.slice(before).filter((call) => call.method === 'POST' && call.url.endsWith('/issues'));
    assert.equal(extraIssues.length, 0);
  });

  it('sale 1 cuando el ping falla y FAIL_ON_ERROR está activo', async () => {
    const code = await run(
      {
        SUPABASE_PROJECTS: JSON.stringify([project]),
        FAIL_ON_ERROR: 'true',
      },
      async () => jsonResponse('no', 500),
    );
    assert.equal(code, 1);
  });
});

describe('notifyFailures', () => {
  it('no llama a GitHub sin token', async () => {
    let called = false;
    const result = await notifyFailures(
      [{ name: 'nachos', ok: false, error: 'HTTP 500' }],
      { GITHUB_REPOSITORY: 'a/b' },
      async () => {
        called = true;
        return jsonResponse([]);
      },
    );
    assert.equal(result.notified, false);
    assert.equal(called, false);
  });
});
