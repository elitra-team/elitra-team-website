<script lang="ts">
	import { createClient } from '$lib/supabase';
	import { goto } from '$app/navigation';
	import { resolve } from '$app/paths';
	import { onMount } from 'svelte';
	import tomatImg from '$lib/assets/tomat.png';
	import type { UserProfile } from '$lib/types';

	const supabase = createClient();
	let profile = $state.raw<UserProfile | null>(null);
	let loading = $state(true);

	onMount(async () => {
		const {
			data: { session }
		} = await supabase.auth.getSession();
		if (!session) { goto(resolve('/login')); return; }

		let { data } = await supabase
			.from('users').select('*').eq('auth_id', session.user.id).single();

		if (!data) {
			const { data: created } = await supabase
				.from('users')
				.insert({
					auth_id: session.user.id,
					display_name: session.user.user_metadata?.full_name || 'Томат',
					email: session.user.email || null,
					avatar_url: session.user.user_metadata?.avatar_url || null
				})
				.select().single();
			data = created;
		}

		if (data) { profile = data as UserProfile; }
		loading = false;
	});

	function getEmoji(type: string): string {
		const map: Record<string, string> = {
			cherry: '🍅', beefsteak: '🥩', roma: '🥫', green: '🟢', yellow: '🟡'
		};
		return map[type] ?? '🍅';
	}

	async function handleSignOut() {
		await supabase.auth.signOut();
		goto(resolve('/tomaty'));
	}
</script>

<svelte:head>
	<title>Профиль — Томатный форум</title>
</svelte:head>

{#if loading}
	<div class="page-loader"><div class="spinner"></div></div>
{:else if profile}
	<img src={tomatImg} alt="" class="bg-tomato bg-1" />
	<img src={tomatImg} alt="" class="bg-tomato bg-2" />
	<img src={tomatImg} alt="" class="bg-tomato bg-3" />
	<div class="page">
		<div class="page-head">
			<h1>Профиль</h1>
			<img src={tomatImg} alt="" class="head-tomato" />
		</div>

		<div class="main-row">
		<div class="preview" class:has-avatar={!!profile.avatar_url} style:background={profile.tomato_color}>
			{#if profile.avatar_url}
				<img src={profile.avatar_url} alt="" class="preview-avatar" />
			{:else}
				<span class="preview-emoji">{getEmoji(profile.tomato_type)}</span>
				<span class="preview-name">{profile.display_name || 'Томат'}</span>
			{/if}
		</div>

			<div class="info">
				<div class="info-row">
					<span class="info-label">Имя</span>
					<span class="info-value">{profile.display_name}</span>
				</div>
				{#if profile.username}
					<div class="info-row">
						<span class="info-label">Username</span>
						<span class="info-value">@{profile.username}</span>
					</div>
				{/if}
				<div class="info-row">
					<span class="info-label">Сорт</span>
					<span class="info-value">{getEmoji(profile.tomato_type)} {profile.tomato_type}</span>
				</div>
				<div class="info-row">
					<span class="info-label">Дата</span>
					<span class="info-value">{new Date(profile.created_at).toLocaleDateString('ru-RU')}</span>
				</div>
			</div>
		</div>

		<div class="actions">
			<a href={resolve('/settings')} class="btn-settings">Настройки</a>
			<button class="btn-signout" onclick={handleSignOut}>Выйти</button>
		</div>
	</div>
{/if}

<style>
	.page-loader {
		display: flex;
		justify-content: center;
		padding: 120px 24px;
	}

	.spinner {
		width: 28px;
		height: 28px;
		border: 2px solid #292524;
		border-top-color: #ef4444;
		border-radius: 50%;
		animation: spin 0.7s linear infinite;
	}

	@keyframes spin {
		to { transform: rotate(360deg); }
	}

	.bg-tomato {
		position: fixed;
		object-fit: contain;
		pointer-events: none;
		opacity: 0.04;
		z-index: 0;
	}

	.bg-1 {
		top: 10%;
		right: 5%;
		width: 120px;
		height: 120px;
		rotate: -12deg;
		animation: float 7s ease-in-out infinite;
	}

	.bg-2 {
		bottom: 15%;
		left: 3%;
		width: 80px;
		height: 80px;
		rotate: 20deg;
		animation: float 6s ease-in-out infinite 1.5s;
	}

	.bg-3 {
		top: 50%;
		right: 15%;
		width: 50px;
		height: 50px;
		rotate: 35deg;
		animation: float 5s ease-in-out infinite 0.8s;
	}

	@keyframes float {
		0%, 100% { transform: translateY(0); }
		50% { transform: translateY(-10px); }
	}

	.page {
		max-width: 640px;
		margin: 0 auto;
		padding: 32px 24px 0;
		animation: fadeIn 0.4s ease both;
		min-height: calc(100vh - 64px);
		display: flex;
		flex-direction: column;
	}

	@keyframes fadeIn {
		from { opacity: 0; transform: translateY(12px); }
		to { opacity: 1; transform: translateY(0); }
	}

	.page-head {
		display: flex;
		align-items: center;
		gap: 10px;
		margin-bottom: 24px;
	}

	h1 {
		font-size: 22px;
		font-weight: 700;
		color: #fafaf9;
		letter-spacing: -0.02em;
	}

	.head-tomato {
		width: 22px;
		height: 22px;
		object-fit: contain;
		opacity: 0.5;
	}

	.main-row {
		display: flex;
		gap: 32px;
		align-items: flex-start;
		flex: 1;
		flex-direction: row-reverse;
	}

	.preview {
		width: 140px;
		height: 140px;
		border-radius: 50%;
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		flex-shrink: 0;
		transition: all 0.4s cubic-bezier(0.34, 1.56, 0.64, 1);
		position: sticky;
		top: 96px;
		overflow: hidden;
	}

	.preview.has-avatar {
		background: transparent;
	}

	.preview:hover {
		transform: scale(1.05);
	}

	.preview-emoji {
		font-size: 44px;
	}

	.preview-avatar {
		width: 100%;
		height: 100%;
		object-fit: cover;
	}

	.preview-name {
		color: white;
		font-weight: 700;
		font-size: 13px;
		text-shadow: 0 1px 4px rgba(0, 0, 0, 0.35);
		margin-top: 4px;
	}

	.info {
		flex: 1;
		min-width: 0;
	}

	.info-row {
		display: flex;
		justify-content: space-between;
		align-items: center;
		padding: 12px 0;
		border-bottom: 1px solid #1c1917;
	}

	.info-row:last-child {
		border-bottom: none;
	}

	.info-label {
		font-size: 14px;
		color: #78716c;
	}

	.info-value {
		font-size: 14px;
		font-weight: 500;
		color: #a8a29e;
	}

	.actions {
		display: flex;
		gap: 8px;
		margin-top: 24px;
		padding-top: 20px;
		border-top: 1px solid #1c1917;
	}

	.btn-settings {
		flex: 1;
		padding: 11px;
		background: #ef4444;
		color: white;
		border: none;
		border-radius: 8px;
		font-size: 14px;
		font-weight: 700;
		cursor: pointer;
		transition: all 0.2s;
		text-align: center;
		text-decoration: none;
		display: flex;
		align-items: center;
		justify-content: center;
	}

	.btn-settings:hover {
		background: #dc2626;
	}

	.btn-signout {
		padding: 11px 20px;
		background: transparent;
		color: #57534e;
		border: 1px solid #292524;
		border-radius: 8px;
		font-size: 14px;
		font-weight: 500;
		cursor: pointer;
		transition: all 0.2s;
	}

	.btn-signout:hover {
		color: #ef4444;
		border-color: rgba(239, 68, 68, 0.25);
	}

	@media (max-width: 600px) {
		.main-row {
			flex-direction: column;
			align-items: center;
		}

		.preview {
			position: static;
		}

		.info {
			width: 100%;
		}
	}
</style>
