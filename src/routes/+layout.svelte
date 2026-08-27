<script lang="ts">
	import favicon from '$lib/assets/favicon.svg';
	import tomatImg from '$lib/assets/tomat.png';
	import { createClient } from '$lib/supabase';
	import { goto } from '$app/navigation';
	import { resolve } from '$app/paths';
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	import { theme } from '$lib/theme';
	import type { UserProfile } from '$lib/types';

	let { children } = $props();

	const supabase = createClient();
	let user = $state.raw<UserProfile | null>(null);
	let loading = $state(true);

	function fallbackUser(sessionUser: {
		id: string;
		email?: string;
		user_metadata?: Record<string, unknown>;
	}): UserProfile {
		return {
			id: '',
			auth_id: sessionUser.id,
			display_name: (sessionUser.user_metadata?.full_name as string) || 'Томат',
			email: sessionUser.email || null,
			avatar_url: (sessionUser.user_metadata?.avatar_url as string) || null,
			username: null,
			admin: false,
			tomato_type: 'cherry',
			tomato_color: '#ef4444',
			created_at: new Date().toISOString(),
			updated_at: new Date().toISOString()
		} as UserProfile;
	}

	async function ensureUserRecord(sessionUser: {
		id: string;
		email?: string;
		user_metadata?: Record<string, unknown>;
	}) {
		const { data } = await supabase
			.from('users')
			.select('*')
			.eq('auth_id', sessionUser.id)
			.single();

		if (data) return data as UserProfile;

		const { data: created } = await supabase
			.from('users')
			.insert({
				auth_id: sessionUser.id,
				display_name: (sessionUser.user_metadata?.full_name as string) || 'Томат',
				email: sessionUser.email || null,
				avatar_url: (sessionUser.user_metadata?.avatar_url as string) || null
			})
			.select()
			.single();

		return (created as UserProfile) ?? fallbackUser(sessionUser);
	}

	onMount(() => {
		(async () => {
			const { data: { session: currentSession } } = await supabase.auth.getSession();
			if (currentSession?.user) {
				try {
					user = await ensureUserRecord(currentSession.user);
				} catch (e) {
					console.error('ensureUserRecord failed:', e);
					user = fallbackUser(currentSession.user);
				}
			}
			loading = false;
		})();

		const {
			data: { subscription }
		} = supabase.auth.onAuthStateChange(
			async (
				_event: string,
				session: {
					user: { id: string; user_metadata?: Record<string, unknown>; email?: string };
				} | null
			) => {
				if (!session?.user) {
					user = null;
					loading = false;
					return;
				}

				try {
					user = await ensureUserRecord(session.user);
				} catch (e) {
					console.error('ensureUserRecord failed on auth change:', e);
					user = fallbackUser(session.user);
				}
				loading = false;
			}
		);

		return () => subscription.unsubscribe();
	});

	async function handleSignOut() {
		await supabase.auth.signOut();
		user = null;
		goto(resolve('/tomaty'));
	}

	function toggleTheme() {
		theme.toggle();
	}

	const isAuthPage = $derived($page.url.pathname === '/login');
	const isLanding = $derived($page.url.pathname === '/' || $page.url.pathname === '/tomaty');
</script>

<svelte:head>
	<link rel="icon" href={favicon} />
	<link rel="preconnect" href="https://fonts.googleapis.com" />
	<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="anonymous" />
	<link
		href="https://fonts.googleapis.com/css2?family=IBM+Plex+Sans:wght@400;500;600;700&display=swap"
		rel="stylesheet"
	/>
</svelte:head>

{#if !isLanding && !isAuthPage}
	<header class="header">
		<div class="header-inner">
			<a href={resolve('/tomaty')} class="logo"><img src={tomatImg} alt="" class="logo-img" /> Томатный форум</a>
			<nav class="nav">
				{#if user}
					<a href={resolve('/profile')} class="nav-link">Профиль</a>
					<a href={resolve('/settings')} class="nav-link">Настройки</a>
					{#if user.admin}
						<a href={resolve('/admin')} class="nav-link nav-admin">Админ</a>
					{/if}
					<div class="nav-user">
						{#if user.avatar_url}
							<img src={user.avatar_url} alt="" class="nav-avatar" />
						{:else}
							<div class="nav-avatar-placeholder">
								{user.display_name?.charAt(0) ?? 'T'}
							</div>
						{/if}
						<button class="btn-ghost" onclick={handleSignOut}>Выйти</button>
					</div>
				{:else}
					<a href={resolve('/login')} class="btn-primary-sm">Войти</a>
				{/if}
				<button class="theme-toggle" onclick={toggleTheme} aria-label="Сменить тему">
					{#if $theme === 'dark'}
						☀️
					{:else}
						🌙
					{/if}
				</button>
			</nav>
		</div>
	</header>
{/if}

<main class:has-header={!isLanding && !isAuthPage}>
	{#if loading && !isLanding && !isAuthPage}
		<div class="loading-screen">
			<div class="spinner"></div>
		</div>
	{:else}
		{@render children()}
	{/if}
</main>

<style>
	:global(*) {
		margin: 0;
		padding: 0;
		box-sizing: border-box;
	}

	:global(:root) {
		--bg: #0c0a09;
		--bg-surface: #0c0a09;
		--bg-card: #1c1917;
		--bg-input: #1c1917;
		--text: #fafaf9;
		--text-secondary: #a8a29e;
		--text-muted: #78716c;
		--text-faint: #44403c;
		--border: #292524;
		--border-strong: #44403c;
		--border-input: #292524;
		--shadow-xs: none;
		--shadow-sm: none;
		--shadow-md: none;
		--shadow-lg: none;
		--shadow-xl: none;
		--accent: #ef4444;
		--accent-hover: #dc2626;
		--accent-bg: rgba(239, 68, 68, 0.1);
		--accent-border: rgba(239, 68, 68, 0.25);
		--accent-glow: rgba(239, 68, 68, 0.15);
		--header-bg: rgba(12, 10, 9, 0.9);
		--hover-bg: #1c1917;
		--row-hover: rgba(255, 255, 255, 0.02);
		--badge-bg: #1c1917;
		--danger-bg: rgba(239, 68, 68, 0.08);
		--danger-border: rgba(239, 68, 68, 0.2);
		--cell-id: #57534e;
		--radius-sm: 6px;
		--radius-md: 8px;
		--radius-lg: 12px;
		--radius-xl: 16px;
		--ease-out: cubic-bezier(0.16, 1, 0.3, 1);
		--ease-spring: cubic-bezier(0.34, 1.56, 0.64, 1);
	}

	:global([data-theme='dark']) {
		--bg: #0c0a09;
		--bg-surface: #0c0a09;
		--bg-card: #1c1917;
		--bg-input: #1c1917;
		--text: #fafaf9;
		--text-secondary: #a8a29e;
		--text-muted: #78716c;
		--text-faint: #44403c;
		--border: #292524;
		--border-strong: #44403c;
		--border-input: #292524;
		--shadow-xs: none;
		--shadow-sm: none;
		--shadow-md: none;
		--shadow-lg: none;
		--shadow-xl: none;
		--accent: #ef4444;
		--accent-hover: #dc2626;
		--accent-bg: rgba(239, 68, 68, 0.1);
		--accent-border: rgba(239, 68, 68, 0.25);
		--accent-glow: rgba(239, 68, 68, 0.15);
		--header-bg: rgba(12, 10, 9, 0.9);
		--hover-bg: #1c1917;
		--row-hover: rgba(255, 255, 255, 0.02);
		--badge-bg: #1c1917;
		--danger-bg: rgba(239, 68, 68, 0.08);
		--danger-border: rgba(239, 68, 68, 0.2);
		--cell-id: #57534e;
	}

	:global(body) {
		font-family:
			'IBM Plex Sans',
			-apple-system,
			BlinkMacSystemFont,
			'Segoe UI',
			Roboto,
			sans-serif;
		-webkit-font-smoothing: antialiased;
		-moz-osx-font-smoothing: grayscale;
		color: var(--text);
		background: var(--bg);
		transition: background 0.3s var(--ease-out), color 0.3s var(--ease-out);
		line-height: 1.5;
	}

	:global(a) {
		color: inherit;
		text-decoration: none;
	}

	:global(input) {
		background: var(--bg-input);
		color: var(--text);
		border-color: var(--border-input);
	}

	:global(.fade-in) {
		animation: fadeIn 0.5s var(--ease-out) both;
	}

	:global(.slide-up) {
		animation: slideUp 0.6s var(--ease-out) both;
	}

	:global(.slide-up-delay-1) {
		animation: slideUp 0.6s var(--ease-out) 0.1s both;
	}

	:global(.slide-up-delay-2) {
		animation: slideUp 0.6s var(--ease-out) 0.2s both;
	}

	:global(.slide-up-delay-3) {
		animation: slideUp 0.6s var(--ease-out) 0.3s both;
	}

	@keyframes fadeIn {
		from { opacity: 0; }
		to { opacity: 1; }
	}

	@keyframes slideUp {
		from {
			opacity: 0;
			transform: translateY(24px);
		}
		to {
			opacity: 1;
			transform: translateY(0);
		}
	}

	.header {
		position: sticky;
		top: 0;
		z-index: 100;
		background: var(--header-bg);
		backdrop-filter: blur(20px) saturate(180%);
		-webkit-backdrop-filter: blur(20px) saturate(180%);
		border-bottom: 1px solid var(--border);
	}

	.header-inner {
		max-width: 1120px;
		margin: 0 auto;
		padding: 0 24px;
		height: 64px;
		display: flex;
		align-items: center;
		justify-content: space-between;
	}

	.logo {
		font-size: 20px;
		font-weight: 700;
		color: var(--accent);
		letter-spacing: -0.02em;
		transition: transform 0.2s var(--ease-spring);
		display: flex;
		align-items: center;
		gap: 6px;
	}

	.logo:hover {
		transform: scale(1.03);
	}

	.logo-img {
		width: 26px;
		height: 26px;
		object-fit: contain;
	}

	.nav {
		display: flex;
		align-items: center;
		gap: 4px;
	}

	.nav-link {
		padding: 8px 14px;
		border-radius: var(--radius-sm);
		font-size: 14px;
		font-weight: 500;
		color: var(--text-secondary);
		transition: all 0.2s var(--ease-out);
	}

	.nav-link:hover {
		background: var(--hover-bg);
		color: var(--text);
	}

	.nav-admin {
		color: var(--accent);
	}

	.nav-admin:hover {
		background: var(--accent-bg);
	}

	.nav-user {
		display: flex;
		align-items: center;
		gap: 10px;
		margin-left: 8px;
		padding-left: 16px;
		border-left: 1px solid var(--border);
	}

	.nav-avatar {
		width: 34px;
		height: 34px;
		border-radius: 50%;
		object-fit: cover;
		border: 2px solid var(--border);
		transition: border-color 0.2s;
	}

	.nav-avatar:hover {
		border-color: var(--accent);
	}

	.nav-avatar-placeholder {
		width: 34px;
		height: 34px;
		border-radius: 50%;
		background: linear-gradient(135deg, var(--accent), var(--accent-hover));
		color: white;
		display: flex;
		align-items: center;
		justify-content: center;
		font-size: 14px;
		font-weight: 700;
		box-shadow: 0 2px 8px var(--accent-glow);
	}

	.btn-ghost {
		padding: 7px 14px;
		border: none;
		background: none;
		color: var(--text-muted);
		font-size: 13px;
		font-weight: 500;
		cursor: pointer;
		border-radius: var(--radius-sm);
		transition: all 0.2s var(--ease-out);
	}

	.btn-ghost:hover {
		background: var(--hover-bg);
		color: var(--accent);
	}

	.btn-primary-sm {
		padding: 8px 20px;
		background: linear-gradient(135deg, var(--accent), var(--accent-hover));
		color: white;
		border-radius: var(--radius-sm);
		font-size: 14px;
		font-weight: 600;
		transition: all 0.2s var(--ease-out);
		box-shadow: 0 2px 8px var(--accent-glow);
	}

	.btn-primary-sm:hover {
		transform: translateY(-1px);
		box-shadow: 0 4px 16px var(--accent-glow);
	}

	.btn-primary-sm:active {
		transform: translateY(0);
	}

	.theme-toggle {
		width: 36px;
		height: 36px;
		display: flex;
		align-items: center;
		justify-content: center;
		border: 1px solid var(--border);
		border-radius: var(--radius-sm);
		background: var(--bg-card);
		cursor: pointer;
		font-size: 16px;
		transition: all 0.2s var(--ease-out);
		margin-left: 4px;
	}

	.theme-toggle:hover {
		background: var(--hover-bg);
		border-color: var(--border-strong);
		transform: scale(1.05);
	}

	.has-header {
		min-height: calc(100vh - 64px);
	}

	.loading-screen {
		display: flex;
		justify-content: center;
		align-items: center;
		min-height: calc(100vh - 64px);
	}

	.spinner {
		width: 36px;
		height: 36px;
		border: 3px solid var(--border);
		border-top-color: var(--accent);
		border-radius: 50%;
		animation: spin 0.7s linear infinite;
		box-shadow: 0 0 20px var(--accent-glow);
	}

	@keyframes spin {
		to {
			transform: rotate(360deg);
		}
	}
</style>
