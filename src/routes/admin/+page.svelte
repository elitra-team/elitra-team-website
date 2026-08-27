<script lang="ts">
	import { createClient } from '$lib/supabase';
	import { goto } from '$app/navigation';
	import { resolve } from '$app/paths';
	import { onMount } from 'svelte';
	import type { UserProfile } from '$lib/types';

	const supabase = createClient();
	let profile = $state.raw<UserProfile | null>(null);
	let users = $state.raw<UserProfile[]>([]);
	let loading = $state(true);
	let error = $state('');

	onMount(async () => {
		const {
			data: { session }
		} = await supabase.auth.getSession();
		if (!session) {
			goto(resolve('/login'));
			return;
		}

		const { data } = await supabase
			.from('users')
			.select('*')
			.eq('auth_id', session.user.id)
			.single();

		if (!data || !(data as UserProfile).admin) {
			goto(resolve('/profile'));
			return;
		}

		profile = data as UserProfile;

		const { data: allUsers, error: fetchError } = await supabase
			.from('users')
			.select('*')
			.order('created_at', { ascending: false });

		if (fetchError) {
			error = fetchError.message;
		} else {
			users = (allUsers as UserProfile[]) ?? [];
		}
		loading = false;
	});

	async function toggleAdmin(userId: string, currentAdmin: boolean) {
		const { error: updateError } = await supabase
			.from('users')
			.update({ admin: !currentAdmin, updated_at: new Date().toISOString() })
			.eq('id', userId);

		if (!updateError) {
			users = users.map((u) => (u.id === userId ? { ...u, admin: !currentAdmin } : u));
		}
	}

	async function deleteUser(userId: string) {
		const { error: deleteError } = await supabase.from('users').delete().eq('id', userId);

		if (!deleteError) {
			users = users.filter((u) => u.id !== userId);
		}
	}

	function getEmoji(type: string): string {
		const map: Record<string, string> = {
			cherry: '🍅',
			beefsteak: '🥩',
			roma: '🥫',
			green: '🟢',
			yellow: '🟡'
		};
		return map[type] ?? '🍅';
	}
</script>

<svelte:head>
	<title>Админка — Томатный форум</title>
</svelte:head>

{#if loading}
	<div class="page-loader"><div class="spinner"></div></div>
{:else if profile}
	<div class="page">
		<div class="page-head">
			<h1>Админ-панель</h1>
			<span class="count">{users.length}</span>
		</div>

		{#if error}
			<p class="error">{error}</p>
		{/if}

		<div class="list">
			{#each users as u (u.id)}
				<div class="row">
					<div class="row-main">
						<div class="avatar" style:background={u.admin ? '#7c3aed' : u.tomato_color || '#475569'}>
							{#if u.avatar_url}
								<img src={u.avatar_url} alt="" />
							{:else}
								{u.display_name?.charAt(0) ?? '?'}
							{/if}
						</div>
						<div class="info">
							<span class="name">{u.display_name}</span>
							<span class="meta">{u.email || u.auth_id.slice(0, 16) + '…'} · {new Date(u.created_at).toLocaleDateString('ru-RU')}</span>
						</div>
						<span class="tomato" style:background={u.tomato_color || '#475569'}>{getEmoji(u.tomato_type)}</span>
						{#if u.admin}
							<span class="tag tag-admin">админ</span>
						{/if}
					</div>
					<div class="row-actions">
						<button class="btn-act" onclick={() => toggleAdmin(u.id, u.admin)}>
							{u.admin ? '– админ' : '+ админ'}
						</button>
						<button class="btn-act btn-del" onclick={() => deleteUser(u.id)}>удалить</button>
					</div>
				</div>
			{/each}
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
		to {
			transform: rotate(360deg);
		}
	}

	.page {
		max-width: 900px;
		margin: 0 auto;
		padding: 48px 24px 80px;
		animation: fadeIn 0.4s ease both;
	}

	@keyframes fadeIn {
		from {
			opacity: 0;
			transform: translateY(12px);
		}
		to {
			opacity: 1;
			transform: translateY(0);
		}
	}

	.page-head {
		display: flex;
		align-items: baseline;
		gap: 12px;
		margin-bottom: 32px;
	}

	h1 {
		font-size: 26px;
		font-weight: 700;
		color: #fafaf9;
		letter-spacing: -0.02em;
	}

	.count {
		font-size: 13px;
		font-weight: 600;
		color: #57534e;
	}

	.error {
		padding: 12px 16px;
		background: rgba(239, 68, 68, 0.08);
		color: #ef4444;
		border-radius: 8px;
		font-size: 13px;
		margin-bottom: 20px;
	}

	.list {
		display: flex;
		flex-direction: column;
	}

	.row {
		display: flex;
		align-items: center;
		justify-content: space-between;
		padding: 14px 0;
		border-bottom: 1px solid #1c1917;
		gap: 16px;
	}

	.row:last-child {
		border-bottom: none;
	}

	.row-main {
		display: flex;
		align-items: center;
		gap: 14px;
		min-width: 0;
		flex: 1;
	}

	.avatar {
		width: 36px;
		height: 36px;
		border-radius: 50%;
		display: flex;
		align-items: center;
		justify-content: center;
		font-size: 14px;
		font-weight: 700;
		color: #fff;
		flex-shrink: 0;
		overflow: hidden;
	}

	.avatar img {
		width: 100%;
		height: 100%;
		object-fit: cover;
	}

	.info {
		display: flex;
		flex-direction: column;
		min-width: 0;
	}

	.name {
		font-size: 14px;
		font-weight: 600;
		color: #fafaf9;
		white-space: nowrap;
		overflow: hidden;
		text-overflow: ellipsis;
	}

	.meta {
		font-size: 12px;
		color: #57534e;
		white-space: nowrap;
		overflow: hidden;
		text-overflow: ellipsis;
	}

	.tomato {
		width: 28px;
		height: 28px;
		border-radius: 6px;
		display: flex;
		align-items: center;
		justify-content: center;
		font-size: 13px;
		flex-shrink: 0;
	}

	.tag {
		font-size: 11px;
		font-weight: 600;
		padding: 2px 8px;
		border-radius: 4px;
		white-space: nowrap;
		flex-shrink: 0;
	}

	.tag-admin {
		background: rgba(124, 58, 237, 0.15);
		color: #a78bfa;
	}

	.row-actions {
		display: flex;
		gap: 6px;
		flex-shrink: 0;
	}

	.btn-act {
		padding: 5px 10px;
		background: transparent;
		border: 1px solid #292524;
		border-radius: 6px;
		color: #a8a29e;
		font-size: 11px;
		font-weight: 500;
		cursor: pointer;
		transition: all 0.15s;
		white-space: nowrap;
	}

	.btn-act:hover {
		background: #1c1917;
		color: #fafaf9;
		border-color: #44403c;
	}

	.btn-del:hover {
		background: rgba(239, 68, 68, 0.08);
		color: #ef4444;
		border-color: rgba(239, 68, 68, 0.25);
	}
</style>
