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
	let saving = $state(false);
	let saved = $state(false);
	let deleting = $state(false);
	let confirmDelete = $state('');

	let displayName = $state('');
	let username = $state('');
	let avatarUrl = $state('');
	let tomatoType = $state('cherry');
	let tomatoColor = $state('#ef4444');

	const tomatoTypes = [
		{ id: 'cherry', name: 'Черри' },
		{ id: 'bull_heart', name: 'Бычье сердце' },
		{ id: 'roma', name: 'Рома' },
		{ id: 'arkadia', name: 'Аркадия' },
		{ id: 'mikado', name: 'Микадо' },
		{ id: 'baron', name: 'Барон' },
		{ id: 'zefir', name: 'Зефир' }
	];

	const allColors = [
		{ color: '#ff0000', admin: false },
		{ color: '#ef4444', admin: false },
		{ color: '#dc2626', admin: false },
		{ color: '#b91c1c', admin: false },
		{ color: '#991b1b', admin: false },
		{ color: '#7f1d1d', admin: false },
		{ color: '#f97316', admin: true },
		{ color: '#ea580c', admin: true },
		{ color: '#c2410c', admin: true },
		{ color: '#eab308', admin: true }
	];

	const tomatoColors = $derived(
		allColors.filter((c) => !c.admin || profile?.admin)
	);

	onMount(async () => {
		const {
			data: { session }
		} = await supabase.auth.getSession();
		if (!session) { goto(resolve('/login')); return; }

		let { data } = await supabase.from('users').select('*').eq('auth_id', session.user.id).single();

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

		if (data) {
			profile = data as UserProfile;
			displayName = profile.display_name;
			username = profile.username ?? '';
			avatarUrl = profile.avatar_url ?? '';
			tomatoType = profile.tomato_type;
			tomatoColor = profile.tomato_color;
		}
		loading = false;
	});

	async function save() {
		if (!profile) return;
		saving = true;

		const { error } = await supabase
			.from('users')
			.update({
				display_name: displayName,
				username: username || null,
				avatar_url: avatarUrl || null,
				tomato_type: tomatoType,
				tomato_color: tomatoColor,
				updated_at: new Date().toISOString()
			})
			.eq('id', profile.id);

		if (!error) {
			saved = true;
			setTimeout(() => (saved = false), 2000);
		}
		saving = false;
	}

	async function deleteAccount() {
		if (!profile || confirmDelete !== 'УДАЛИТЬ') return;
		deleting = true;

		await supabase.from('users').delete().eq('id', profile.id);
		await supabase.auth.signOut();
		goto(resolve('/tomaty'));
	}
</script>

<svelte:head>
	<title>Настройки — Томатный форум</title>
</svelte:head>

{#if loading}
	<div class="page-loader"><div class="spinner"></div></div>
{:else if profile}
	<img src={tomatImg} alt="" class="bg-tomato bg-1" />
	<img src={tomatImg} alt="" class="bg-tomato bg-2" />
	<div class="page">
		<h1>Настройки</h1>

		{#if avatarUrl}
			<div class="avatar-preview">
				<img src={avatarUrl} alt="Аватар" />
			</div>
		{/if}

		<div class="row">
			<div class="section" style:flex="1">
				<label for="name">Имя</label>
				<input id="name" type="text" bind:value={displayName} placeholder="Ваше имя" />
			</div>
			<div class="section" style:flex="1">
				<label for="username">Username</label>
				<input id="username" type="text" bind:value={username} placeholder="username" />
			</div>
		</div>

		<div class="section">
			<label for="avatar">Аватар (URL)</label>
			<input id="avatar" type="url" bind:value={avatarUrl} placeholder="https://example.com/avatar.jpg" />
		</div>

		<div class="row">
			<div class="section" style:flex="1">
				<label>Сорт</label>
				<select bind:value={tomatoType}>
					{#each tomatoTypes as type (type.id)}
						<option value={type.id}>{type.name}</option>
					{/each}
				</select>
			</div>
			<div class="section" style:flex="1">
				<label>Цвет</label>
				<div class="color-row">
					{#each tomatoColors as item (item.color)}
						<button class="color-btn" class:active={tomatoColor === item.color} style:background={item.color} onclick={() => (tomatoColor = item.color)} aria-label={item.color}></button>
					{/each}
				</div>
			</div>
		</div>

		<button class="btn-save" onclick={save} disabled={saving || saved}>
			{#if saving}Сохранение...{:else if saved}✓ Сохранено{:else}Сохранить{/if}
		</button>

		<div class="divider"></div>

		<div class="info-section">
			<div class="info-row">
				<span class="info-label">Email</span>
				<span class="info-value">{profile.email || 'Не указан'}</span>
			</div>
			<div class="info-row">
				<span class="info-label">Дата регистрации</span>
				<span class="info-value">{new Date(profile.created_at).toLocaleDateString('ru-RU')}</span>
			</div>
		</div>

		<div class="divider"></div>

		<div class="danger-section">
			<h2 class="danger-title">Опасная зона</h2>
			<p class="danger-text">Удаление аккаунта необратимо.</p>

			{#if !deleting}
				<button class="btn-danger" onclick={() => (deleting = true)}>Удалить аккаунт</button>
			{:else}
				<div class="delete-confirm">
					<p>Введите <strong>УДАЛИТЬ</strong> для подтверждения:</p>
					<div class="delete-row">
						<input type="text" bind:value={confirmDelete} placeholder="УДАЛИТЬ" class="delete-input" />
						<button class="btn-danger-sm" disabled={confirmDelete !== 'УДАЛИТЬ'} onclick={deleteAccount}>Подтвердить</button>
						<button class="btn-cancel" onclick={() => { deleting = false; confirmDelete = ''; }}>Отмена</button>
					</div>
				</div>
			{/if}
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

	.page {
		max-width: 560px;
		margin: 0 auto;
		padding: 48px 24px 80px;
		animation: fadeIn 0.4s ease both;
	}

	@keyframes fadeIn {
		from { opacity: 0; transform: translateY(12px); }
		to { opacity: 1; transform: translateY(0); }
	}

	.bg-tomato {
		position: fixed;
		object-fit: contain;
		pointer-events: none;
		opacity: 0.04;
		z-index: 0;
	}

	.bg-1 {
		top: 8%;
		right: 4%;
		width: 110px;
		height: 110px;
		rotate: -20deg;
		animation: float 7s ease-in-out infinite;
	}

	.bg-2 {
		bottom: 12%;
		left: 5%;
		width: 70px;
		height: 70px;
		rotate: 15deg;
		animation: float 6s ease-in-out infinite 1s;
	}

	@keyframes float {
		0%, 100% { transform: translateY(0); }
		50% { transform: translateY(-10px); }
	}

	h1 {
		font-size: 26px;
		font-weight: 700;
		color: #fafaf9;
		letter-spacing: -0.02em;
		margin-bottom: 24px;
	}

	.row {
		display: flex;
		gap: 16px;
		margin-bottom: 20px;
	}

	.section {
		margin-bottom: 20px;
	}

	label {
		display: block;
		font-weight: 600;
		font-size: 11px;
		color: #78716c;
		margin-bottom: 6px;
		text-transform: uppercase;
		letter-spacing: 0.06em;
	}

	input {
		width: 100%;
		padding: 10px 14px;
		border: 1px solid #292524;
		border-radius: 8px;
		font-size: 14px;
		font-family: inherit;
		transition: all 0.2s;
		background: #1c1917;
		color: #fafaf9;
	}

	input:hover { border-color: #44403c; }
	input:focus { outline: none; border-color: #ef4444; }

	select {
		width: 100%;
		padding: 10px 14px;
		border: 1px solid #292524;
		border-radius: 8px;
		font-size: 14px;
		font-family: inherit;
		transition: all 0.2s;
		background: #1c1917;
		color: #fafaf9;
		appearance: none;
		background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 12 12'%3E%3Cpath fill='%2378716c' d='M2 4l4 4 4-4'/%3E%3C/svg%3E");
		background-repeat: no-repeat;
		background-position: right 12px center;
		padding-right: 32px;
		cursor: pointer;
	}

	select:hover { border-color: #44403c; }
	select:focus { outline: none; border-color: #ef4444; }

	.hint {
		display: block;
		margin-top: 4px;
		font-size: 12px;
		color: #57534e;
	}

	.avatar-preview {
		margin-bottom: 24px;
		text-align: center;
	}

	.avatar-preview img {
		width: 96px;
		height: 96px;
		border-radius: 50%;
		object-fit: cover;
		border: 2px solid #292524;
	}

	.color-row {
		display: flex;
		gap: 6px;
		flex-wrap: wrap;
	}

	.color-btn {
		width: 28px;
		height: 28px;
		border-radius: 50%;
		border: 2px solid transparent;
		cursor: pointer;
		transition: all 0.2s cubic-bezier(0.34, 1.56, 0.64, 1);
		padding: 0;
	}

	.color-btn:hover { transform: scale(1.15); }

	.color-btn.active {
		border-color: #fafaf9;
		transform: scale(1.2);
	}

	.btn-save {
		width: 100%;
		padding: 12px;
		background: #ef4444;
		color: white;
		border: none;
		border-radius: 8px;
		font-size: 14px;
		font-weight: 700;
		cursor: pointer;
		transition: all 0.2s;
		margin-top: 8px;
	}

	.btn-save:hover:not(:disabled) {
		background: #dc2626;
		transform: translateY(-1px);
	}

	.btn-save:disabled {
		opacity: 0.5;
		cursor: not-allowed;
	}

	.divider {
		height: 1px;
		background: #1c1917;
		margin: 20px 0;
	}

	.info-section {
		display: flex;
		flex-direction: column;
	}

	.info-row {
		display: flex;
		justify-content: space-between;
		align-items: center;
		padding: 10px 0;
		border-bottom: 1px solid #1c1917;
	}

	.info-row:last-child { border-bottom: none; }

	.info-label { font-size: 14px; color: #78716c; }
	.info-value { font-size: 14px; font-weight: 500; color: #a8a29e; }

	.danger-section { margin-top: 8px; }

	.danger-title {
		font-size: 17px;
		font-weight: 700;
		color: #ef4444;
		margin-bottom: 6px;
	}

	.danger-text {
		font-size: 14px;
		color: #78716c;
		margin-bottom: 14px;
	}

	.btn-danger {
		padding: 10px 20px;
		background: transparent;
		color: #ef4444;
		border: 1px solid rgba(239, 68, 68, 0.25);
		border-radius: 8px;
		font-size: 14px;
		font-weight: 600;
		cursor: pointer;
		transition: all 0.2s;
	}

	.btn-danger:hover {
		background: rgba(239, 68, 68, 0.08);
		border-color: #ef4444;
	}

	.delete-confirm p {
		font-size: 14px;
		color: #a8a29e;
		margin-bottom: 10px;
	}

	.delete-row {
		display: flex;
		gap: 8px;
		align-items: center;
	}

	.delete-input {
		flex: 1;
		padding: 10px 14px;
		border: 1px solid rgba(239, 68, 68, 0.25);
		border-radius: 6px;
		font-size: 14px;
		font-family: inherit;
	}

	.delete-input:focus { outline: none; border-color: #ef4444; }

	.btn-danger-sm {
		padding: 10px 16px;
		background: #ef4444;
		color: white;
		border: none;
		border-radius: 6px;
		font-size: 13px;
		font-weight: 600;
		cursor: pointer;
		white-space: nowrap;
		transition: all 0.2s;
	}

	.btn-danger-sm:hover:not(:disabled) { background: #dc2626; }
	.btn-danger-sm:disabled { opacity: 0.4; cursor: not-allowed; }

	.btn-cancel {
		padding: 10px 16px;
		background: #1c1917;
		color: #78716c;
		border: none;
		border-radius: 6px;
		font-size: 13px;
		font-weight: 600;
		cursor: pointer;
		white-space: nowrap;
		transition: all 0.2s;
	}

	.btn-cancel:hover { background: #292524; }

	@media (max-width: 500px) {
		.row { flex-direction: column; gap: 0; }
	}
</style>
