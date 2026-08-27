<script lang="ts">
	import { createClient } from '$lib/supabase';
	import { goto } from '$app/navigation';
	import { resolve } from '$app/paths';
	import { onMount } from 'svelte';
	import tomatImg from '$lib/assets/tomat.png';

	const supabase = createClient();
	let loading = $state(false);
	let error = $state('');

	onMount(async () => {
		const {
			data: { session }
		} = await supabase.auth.getSession();
		if (session) goto(resolve('/profile'));
	});

	async function signInWithGoogle() {
		loading = true;
		error = '';
		const { error: authError } = await supabase.auth.signInWithOAuth({
			provider: 'google',
			options: {
				redirectTo: `${window.location.origin}${resolve('/profile')}`
			}
		});
		if (authError) {
			error = authError.message;
			loading = false;
		}
	}
</script>

<svelte:head>
	<title>Вход — Томатный форум</title>
</svelte:head>

<div class="login-page">
	<div class="login-glow"></div>
	<img src={tomatImg} alt="" class="bg-tomato bg-tomato-1" />
	<img src={tomatImg} alt="" class="bg-tomato bg-tomato-2" />

	<div class="login-content">
		<img src={tomatImg} alt="Томатный форум" class="logo-img" />
		<h1>Стать томатом</h1>
		<p class="subtitle">Войдите, чтобы стать томатом</p>

		{#if error}
			<p class="error">{error}</p>
		{/if}

		<button class="btn-google" onclick={signInWithGoogle} disabled={loading}>
			{#if loading}
				<div class="btn-spinner"></div>
			{:else}
				<svg width="20" height="20" viewBox="0 0 24 24">
					<path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92a5.06 5.06 0 0 1-2.2 3.32v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.1z" fill="#4285F4" />
					<path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853" />
					<path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z" fill="#FBBC05" />
					<path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335" />
				</svg>
				Продолжить с Google
			{/if}
		</button>

		<p class="terms">Нажимая «Продолжить», вы соглашаетесь с условиями использования</p>
	</div>
</div>

<style>
	.login-page {
		min-height: 100vh;
		display: flex;
		align-items: center;
		justify-content: center;
		background: #0c0a09;
		padding: 24px;
		position: relative;
		overflow: hidden;
	}

	.login-glow {
		position: absolute;
		top: -200px;
		left: 50%;
		transform: translateX(-50%);
		width: 500px;
		height: 500px;
		background: radial-gradient(circle, rgba(239, 68, 68, 0.06) 0%, transparent 60%);
		pointer-events: none;
	}

	.bg-tomato {
		position: absolute;
		object-fit: contain;
		pointer-events: none;
		opacity: 0.06;
	}

	.bg-tomato-1 {
		top: 15%;
		right: 8%;
		width: 140px;
		height: 140px;
		rotate: -15deg;
		animation: float 6s ease-in-out infinite;
	}

	.bg-tomato-2 {
		bottom: 10%;
		left: 6%;
		width: 90px;
		height: 90px;
		rotate: 20deg;
		animation: float 5s ease-in-out infinite 1s;
	}

	@keyframes float {
		0%, 100% { transform: translateY(0); }
		50% { transform: translateY(-12px); }
	}

	.login-content {
		text-align: center;
		position: relative;
		z-index: 1;
		animation: fadeIn 0.5s cubic-bezier(0.16, 1, 0.3, 1) both;
	}

	@keyframes fadeIn {
		from { opacity: 0; transform: translateY(20px); }
		to { opacity: 1; transform: translateY(0); }
	}

	.logo-img {
		width: 64px;
		height: 64px;
		object-fit: contain;
		margin-bottom: 24px;
		animation: bounceIn 0.6s cubic-bezier(0.34, 1.56, 0.64, 1) 0.15s both;
	}

	@keyframes bounceIn {
		from { opacity: 0; transform: scale(0.5); }
		to { opacity: 1; transform: scale(1); }
	}

	h1 {
		font-size: 28px;
		font-weight: 700;
		margin-bottom: 8px;
		letter-spacing: -0.02em;
		color: #fafaf9;
	}

	.subtitle {
		color: #78716c;
		font-size: 15px;
		margin-bottom: 36px;
	}

	.error {
		padding: 12px 16px;
		background: rgba(239, 68, 68, 0.08);
		color: #ef4444;
		border-radius: 8px;
		font-size: 13px;
		margin-bottom: 20px;
		font-weight: 500;
	}

	.btn-google {
		width: 100%;
		display: flex;
		align-items: center;
		justify-content: center;
		gap: 12px;
		padding: 14px 24px;
		border: 1px solid #292524;
		border-radius: 10px;
		background: transparent;
		font-size: 15px;
		font-weight: 600;
		color: #fafaf9;
		cursor: pointer;
		transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
	}

	.btn-google:hover:not(:disabled) {
		border-color: #44403c;
		background: rgba(255, 255, 255, 0.03);
	}

	.btn-google:active:not(:disabled) {
		transform: translateY(0);
	}

	.btn-google:disabled {
		opacity: 0.5;
		cursor: not-allowed;
	}

	.btn-spinner {
		width: 18px;
		height: 18px;
		border: 2px solid #44403c;
		border-top-color: #a8a29e;
		border-radius: 50%;
		animation: spin 0.7s linear infinite;
	}

	@keyframes spin {
		to { transform: rotate(360deg); }
	}

	.terms {
		margin-top: 28px;
		font-size: 12px;
		color: #44403c;
		line-height: 1.5;
	}
</style>
