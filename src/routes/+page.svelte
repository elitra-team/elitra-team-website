<script lang="ts">
	import { goto } from '$app/navigation';
	import { resolve } from '$app/paths';
	import { onMount } from 'svelte';
	import { theme } from '$lib/theme';
	import tomatImg from '$lib/assets/tomat.png';

	let visible = $state(false);
	let clickCount = $state(0);
	let redirecting = $state(false);

	onMount(() => {
		requestAnimationFrame(() => (visible = true));
	});

	function toggleTheme() {
		theme.toggle();
	}

	function onTomatClick() {
		clickCount++;
		if (clickCount >= 5) {
			redirecting = true;
			setTimeout(() => {
				goto(resolve('/tomaty'));
			}, 300);
		}
	}
</script>

<svelte:head>
	<title>Elitra OS</title>
</svelte:head>

<div class="landing">
	<header class="header">
		<div class="header-inner">
			<span class="logo">Elitra OS</span>
			<button class="theme-toggle" onclick={toggleTheme} aria-label="Сменить тему">
				{#if $theme === 'dark'}☀️{:else}🌙{/if}
			</button>
		</div>
	</header>

	<section class="hero">
		<div class="hero-glow"></div>
		<div class="hero-content" class:visible>
			<h1>Elitra <span class="highlight">OS</span></h1>
			<p class="hero-sub">
				Минималистичная операционная система с удобным интерфейсом и огромным количеством настроек.
				Гибкая, практичная и молодая — от соло-разработчика.
			</p>
			<div class="hero-badge">Скоро</div>
		</div>
	</section>

	<section class="features">
		<div class="features-inner">
			<div class="feature">
				<h3>Минимализм</h3>
				<p>Чистый интерфейс без лишнего. Только то, что вам нужно.</p>
			</div>
			<div class="feature">
				<h3>Настройки</h3>
				<p>Огромное количество опций. Настройте систему под себя полностью.</p>
			</div>
			<div class="feature">
				<h3>Практичность</h3>
				<p>Каждая деталь продумана для максимального удобства.</p>
			</div>
		</div>
	</section>

	<footer class="footer">
		{#if redirecting}
			<div class="redirect-hint">Переключаюсь...</div>
		{:else if clickCount > 0}
			<div class="click-hint">{5 - clickCount}</div>
		{/if}
		<button
			class="tomat-btn"
			class:redirecting
			onclick={onTomatClick}
			aria-label="Томат"
		>
			<img src={tomatImg} alt="" class="tomat-img" />
		</button>
		<p class="footer-text">Elitra OS © 2026</p>
	</footer>
</div>

<style>
	.landing {
		min-height: 100vh;
		background: #0c0a09;
		color: #fafaf9;
		display: flex;
		flex-direction: column;
	}

	.header {
		padding: 20px 40px;
	}

	.header-inner {
		max-width: 1120px;
		margin: 0 auto;
		display: flex;
		align-items: center;
		justify-content: space-between;
	}

	.logo {
		font-size: 20px;
		font-weight: 700;
		color: #fafaf9;
		letter-spacing: -0.02em;
	}

	.theme-toggle {
		width: 36px;
		height: 36px;
		display: flex;
		align-items: center;
		justify-content: center;
		border: 1px solid #292524;
		border-radius: 8px;
		background: transparent;
		cursor: pointer;
		font-size: 16px;
		transition: all 0.2s;
	}

	.theme-toggle:hover {
		background: #1c1917;
		border-color: #44403c;
	}

	.hero {
		position: relative;
		max-width: 700px;
		margin: 0 auto;
		text-align: center;
		padding: 100px 24px 80px;
		flex: 1;
		display: flex;
		align-items: center;
	}

	.hero-glow {
		position: absolute;
		top: -200px;
		left: 50%;
		transform: translateX(-50%);
		width: 600px;
		height: 600px;
		background: radial-gradient(circle, rgba(255, 255, 255, 0.02) 0%, transparent 60%);
		pointer-events: none;
	}

	.hero-content {
		position: relative;
		z-index: 1;
		opacity: 0;
		transform: translateY(30px);
		transition: opacity 0.7s cubic-bezier(0.16, 1, 0.3, 1), transform 0.7s cubic-bezier(0.16, 1, 0.3, 1);
	}

	.hero-content.visible {
		opacity: 1;
		transform: translateY(0);
	}

	h1 {
		font-size: 72px;
		font-weight: 700;
		line-height: 1.05;
		letter-spacing: -0.04em;
		margin-bottom: 24px;
	}

	.highlight {
		color: #a8a29e;
	}

	.hero-sub {
		font-size: 19px;
		color: #78716c;
		line-height: 1.65;
		max-width: 520px;
		margin: 0 auto 32px;
	}

	.hero-badge {
		display: inline-block;
		padding: 6px 18px;
		border: 1px solid #292524;
		color: #78716c;
		border-radius: 100px;
		font-size: 13px;
		font-weight: 600;
		letter-spacing: 0.03em;
	}

	.features {
		border-top: 1px solid #1c1917;
	}

	.features-inner {
		max-width: 800px;
		margin: 0 auto;
		padding: 64px 24px;
		display: grid;
		grid-template-columns: repeat(3, 1fr);
		gap: 48px;
	}

	.feature h3 {
		font-size: 16px;
		font-weight: 700;
		margin-bottom: 8px;
		letter-spacing: -0.01em;
	}

	.feature p {
		font-size: 14px;
		color: #78716c;
		line-height: 1.6;
	}

	.footer {
		text-align: center;
		padding: 24px;
		border-top: 1px solid #1c1917;
		position: relative;
	}

	.tomat-btn {
		background: none;
		border: none;
		cursor: pointer;
		padding: 8px;
		transition: transform 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
		display: inline-block;
		margin-bottom: 8px;
	}

	.tomat-btn:hover:not(.redirecting) {
		transform: scale(1.15) rotate(-5deg);
	}

	.tomat-btn.redirecting {
		cursor: default;
		animation: spin 0.5s ease;
	}

	.tomat-img {
		width: 36px;
		height: 36px;
		object-fit: contain;
		opacity: 0.3;
		transition: opacity 0.2s;
	}

	.tomat-btn:hover:not(.redirecting) .tomat-img {
		opacity: 0.6;
	}

	.click-hint {
		font-size: 11px;
		color: #44403c;
		margin-bottom: 4px;
		font-weight: 600;
		letter-spacing: 0.05em;
		transition: opacity 0.2s;
	}

	.redirect-hint {
		font-size: 11px;
		color: #ef4444;
		margin-bottom: 4px;
		font-weight: 600;
		letter-spacing: 0.05em;
		animation: fadeIn 0.3s ease;
	}

	.footer-text {
		font-size: 12px;
		color: #44403c;
	}

	@keyframes spin {
		to { transform: rotate(360deg); }
	}

	@keyframes fadeIn {
		from { opacity: 0; }
		to { opacity: 1; }
	}

	@media (max-width: 768px) {
		h1 {
			font-size: 48px;
		}

		.hero {
			padding: 60px 24px 40px;
		}

		.features-inner {
			grid-template-columns: 1fr;
			gap: 32px;
			padding: 48px 24px;
		}
	}
</style>
