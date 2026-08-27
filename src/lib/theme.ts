import { writable } from 'svelte/store';
import { browser } from '$app/environment';

type Theme = 'light' | 'dark';

function createThemeStore() {
	const stored = browser ? (localStorage.getItem('theme') as Theme | null) : null;
	const initial: Theme =
		stored ??
		(browser && window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light');

	const store = writable<Theme>(initial);

	if (browser) {
		document.documentElement.setAttribute('data-theme', initial);
	}

	return {
		subscribe: store.subscribe,
		toggle() {
			let current: Theme = 'light';
			store.subscribe((v) => (current = v))();
			const next: Theme = current === 'light' ? 'dark' : 'light';
			store.set(next);
			if (browser) {
				localStorage.setItem('theme', next);
				document.documentElement.setAttribute('data-theme', next);
			}
		}
	};
}

export const theme = createThemeStore();
