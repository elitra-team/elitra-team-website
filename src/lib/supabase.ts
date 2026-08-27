import { createBrowserClient } from '@supabase/ssr';

let client: ReturnType<typeof createBrowserClient> | null = null;

export function createClient() {
	if (client) return client;

	const url = import.meta.env.VITE_SUPABASE_URL;
	const key = import.meta.env.VITE_SUPABASE_ANON_KEY;

	if (!url || !key || url === 'your-supabase-url' || key === 'your-supabase-anon-key') {
		console.warn(
			'[Томатный форум] Supabase не настроен. Заполните VITE_SUPABASE_URL и VITE_SUPABASE_ANON_KEY в .env'
		);
	}

	client = createBrowserClient(url || 'https://placeholder.supabase.co', key || 'placeholder');
	return client;
}
