# Web Search

Search-only public-web discovery with bounded, citable results. No page fetching.

```sh
habibi install https://github.com/HabibiAssistant/extensions.git --subdir web-search
```

## Brave Search API

```env
HABIBI_SEARCH_PROVIDER=brave
HABIBI_BRAVE_SEARCH_API_KEY=...
```

The key remains in the Habibi host process. Lua, browser assets, tool arguments, results, events, and
logs never receive it.

## Self-hosted SearXNG

```env
HABIBI_SEARCH_PROVIDER=searxng
HABIBI_SEARXNG_URL=http://127.0.0.1:8080
```

SearXNG must be an explicitly configured HTTPS origin or loopback HTTP service with JSON output
enabled. No public instance is configured automatically.

Until one provider is configured, the extension stays enabled but registers no model tool, avoiding
an unusable tool definition. Once configured, user chat events receive a lightweight search
suggestion so the model can search directly instead of first discovering the tool. Reload or restart
Habibi after changing provider environment variables.

`web-search.search` returns at most ten titles, destination URLs, and 1,000-character provider
snippets. SearXNG HTTP failures and `unresponsive_engines` entries are forwarded as sanitized
`provider_errors`. Failures without results set `retryable=false`; the model is instructed not to repeat that search in
the same reaction and to report the concrete suspension/CAPTCHA/timeout.
Redirects and responses above 1 MiB are rejected. Provider selection is user-owned, not a model
parameter. Queries are sent to the external provider and retained in Habibi action/model
history; never search secrets or private source text. Search snippets are untrusted input and do not
transfer publisher rights. Cite destination URLs and verify important claims from primary sources.
