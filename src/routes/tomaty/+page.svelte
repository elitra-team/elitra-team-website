<script lang="ts">
	import { createClient } from '$lib/supabase';
	import { resolve } from '$app/paths';
	import { onMount } from 'svelte';
	import { theme } from '$lib/theme';
	import tomatImg from '$lib/assets/tomat.png';

	const supabase = createClient();
	let isLoggedIn = $state(false);
	let visible = $state(false);

	onMount(async () => {
		const {
			data: { session }
		} = await supabase.auth.getSession();
		isLoggedIn = !!session;
		requestAnimationFrame(() => (visible = true));
	});

	function toggleTheme() {
		theme.toggle();
	}
</script>

<svelte:head>
	<title>Томатный форум — Стань томатом</title>
</svelte:head>

<div class="landing">
	<header class="header">
		<div class="header-inner">
			<span class="logo"><img src={tomatImg} alt="" class="logo-img" /> Томатный форум</span>
			<div class="header-actions">
				<button class="theme-toggle" onclick={toggleTheme} aria-label="Сменить тему">
					{#if $theme === 'dark'}☀️{:else}🌙{/if}
				</button>
				{#if isLoggedIn}
					<a href={resolve('/profile')} class="btn-ghost">Профиль</a>
				{:else}
					<a href={resolve('/login')} class="btn-primary">Войти</a>
				{/if}
			</div>
		</div>
	</header>

	<section class="hero">
		<div class="hero-glow"></div>
		<img src={tomatImg} alt="" class="hero-tomato-img hero-tomato-1" />
		<img src={tomatImg} alt="" class="hero-tomato-img hero-tomato-2" />
		<img src={tomatImg} alt="" class="hero-tomato-img hero-tomato-3" />
		<div class="hero-content" class:visible>
			<h1>Стань <span class="highlight">томатом</span></h1>
			<p class="hero-sub">
				Создайте уникальный профиль, выберите свой сорт и станьте частью дружного сообщества.
			</p>
			<div class="hero-actions">
				{#if isLoggedIn}
					<a href={resolve('/profile')} class="btn-primary-lg">Мой профиль</a>
				{:else}
					<a href={resolve('/login')} class="btn-primary-lg">Стать томатом</a>
				{/if}
				<a href="https://t.me/Tg_Free_Forum" class="btn-ghost-lg" target="_blank" rel="noopener">Форум</a>
				<a href="https://github.com" class="btn-ghost-lg" target="_blank" rel="noopener">GitHub</a>
			</div>
		</div>
	</section>

	<section class="why">
		<img src={tomatImg} alt="" class="why-tomato" />
		<div class="why-inner">
			<h2>Почему стоит стать томатом?</h2>

			<div class="why-list">
				<div class="why-item">
					<div>
						<h3>Это весело</h3>
						<p>Каждый томат уникален. Выберите свой сорт — от классического черри до экзотического зелёного.</p>
					</div>
				</div>
				<div class="why-item">
					<div>
						<h3>Открытая платформа</h3>
						<p>Весь код открыт на GitHub. Проверьте, как работает всё изнутри, или внесите свой вклад.</p>
					</div>
				</div>
				<div class="why-item">
					<div>
						<h3>Безопасно</h3>
						<p>Данные защищены на уровне базы данных. Никто не может прочитать чужие данные.</p>
					</div>
				</div>
				<div class="why-item">
					<div>
						<h3>Быстро</h3>
						<p>Одна кнопка — и вы вошли через Google. Никаких форм регистрации и паролей.</p>
					</div>
				</div>
			</div>
		</div>
	</section>

	<section class="facts">
		<img src={tomatImg} alt="" class="facts-tomato" />
		<div class="facts-inner">
			<h2>Томаты — это круто</h2>
			<div class="facts-row">
				<div class="fact">
					<div class="fact-number">4000+</div>
					<div class="fact-desc">сортов</div>
				</div>
				<div class="fact">
					<div class="fact-number">182</div>
					<div class="fact-desc">страны</div>
				</div>
				<div class="fact">
					<div class="fact-number">180 млн</div>
					<div class="fact-desc">тонн ежегодно</div>
				</div>
				<div class="fact">
					<div class="fact-number">95%</div>
					<div class="fact-desc">вода</div>
				</div>
			</div>
		</div>
	</section>

	<section class="how">
		<img src={tomatImg} alt="" class="how-tomato" />
		<div class="how-inner">
			<h2>Как это работает</h2>
			<div class="how-steps">
				<div class="how-step">
					<span class="how-num">01</span>
					<div>
						<h3>Войдите</h3>
						<p>Одним кликом через Google.</p>
					</div>
				</div>
				<div class="how-step">
					<span class="how-num">02</span>
					<div>
						<h3>Выберите сорт</h3>
						<p>Бычье сердце, черри, рома — какой вы томат?</p>
					</div>
				</div>
				<div class="how-step">
					<span class="how-num">03</span>
					<div>
						<h3>Настройте профиль</h3>
						<p>Имя, цвет, аватар. Сделайте уникальным.</p>
					</div>
				</div>
				<div class="how-step">
					<span class="how-num">04</span>
					<div>
						<h3>Будьте собой</h3>
						<p>Готово! Вы — томат.</p>
					</div>
				</div>
			</div>
		</div>
	</section>

	<section class="cta-section">
		<img src={tomatImg} alt="" class="cta-tomato" />
		<div class="cta-inner">
			<h2>Готовы стать томатом?</h2>
			<p>Присоединяйтесь. Это займёт 10 секунд.</p>
			{#if isLoggedIn}
				<a href={resolve('/profile')} class="btn-primary-lg">Мой профиль</a>
			{:else}
				<a href={resolve('/login')} class="btn-primary-lg">Стать томатом</a>
			{/if}
		</div>
	</section>

	<footer class="footer">
		<img src={tomatImg} alt="" class="footer-tomato" />
		<p>Томатный форум © 2026 · <a href="https://t.me/Tg_Free_Forum" target="_blank" rel="noopener" class="footer-link">Форум</a> · <a href="https://github.com" target="_blank" rel="noopener" class="footer-link">GitHub</a></p>
	</footer>
</div>

<style>
	.landing {
		min-height: 100vh;
		background: #0c0a09;
		color: #fafaf9;
		overflow: hidden;
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

	.header-actions {
		display: flex;
		align-items: center;
		gap: 10px;
	}

	.logo {
		font-size: 20px;
		font-weight: 700;
		color: #ef4444;
		letter-spacing: -0.02em;
		display: flex;
		align-items: center;
		gap: 8px;
	}

	.logo-img {
		width: 26px;
		height: 26px;
		object-fit: contain;
	}

	.btn-primary {
		padding: 10px 24px;
		background: #ef4444;
		color: white;
		border-radius: 8px;
		font-weight: 600;
		font-size: 14px;
		transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
	}

	.btn-primary:hover {
		background: #dc2626;
		transform: translateY(-1px);
	}

	.btn-ghost {
		padding: 10px 24px;
		background: transparent;
		color: #a8a29e;
		border-radius: 8px;
		font-weight: 600;
		font-size: 14px;
		transition: all 0.2s;
	}

	.btn-ghost:hover {
		color: #fafaf9;
		background: rgba(255, 255, 255, 0.05);
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
		max-width: 800px;
		margin: 0 auto;
		text-align: center;
		padding: 80px 24px 100px;
	}

	.hero-glow {
		position: absolute;
		top: -200px;
		left: 50%;
		transform: translateX(-50%);
		width: 700px;
		height: 700px;
		background: radial-gradient(circle, rgba(239, 68, 68, 0.08) 0%, transparent 60%);
		pointer-events: none;
	}

	.hero-tomato-img {
		position: absolute;
		object-fit: contain;
		pointer-events: none;
		opacity: 0;
		transition: opacity 1s ease 0.4s;
	}

	.hero-tomato-img.visible {
		opacity: 1;
	}

	.hero-tomato-1 {
		top: 30px;
		right: 2%;
		width: 120px;
		height: 120px;
		rotate: -12deg;
		animation: float 5s ease-in-out infinite;
		filter: drop-shadow(0 8px 24px rgba(239, 68, 68, 0.2));
	}

	.hero-tomato-2 {
		top: 140px;
		left: 0;
		width: 70px;
		height: 70px;
		rotate: 15deg;
		animation: float 6s ease-in-out infinite 1s;
		opacity: 0.4 !important;
		filter: drop-shadow(0 4px 12px rgba(239, 68, 68, 0.15));
	}

	.hero-tomato-2.visible {
		opacity: 0.4 !important;
	}

	.hero-tomato-3 {
		bottom: 20px;
		right: 12%;
		width: 50px;
		height: 50px;
		rotate: 25deg;
		animation: float 4s ease-in-out infinite 0.5s;
		opacity: 0.25 !important;
		filter: drop-shadow(0 4px 8px rgba(239, 68, 68, 0.1));
	}

	.hero-tomato-3.visible {
		opacity: 0.25 !important;
	}

	@keyframes float {
		0%, 100% { transform: translateY(0); }
		50% { transform: translateY(-12px); }
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
		font-size: 68px;
		font-weight: 700;
		line-height: 1.05;
		letter-spacing: -0.04em;
		margin-bottom: 24px;
	}

	.highlight {
		background: linear-gradient(135deg, #ef4444, #f97316);
		-webkit-background-clip: text;
		-webkit-text-fill-color: transparent;
		background-clip: text;
	}

	.hero-sub {
		font-size: 19px;
		color: #78716c;
		line-height: 1.65;
		max-width: 500px;
		margin: 0 auto 40px;
	}

	.hero-actions {
		display: flex;
		gap: 12px;
		justify-content: center;
		flex-wrap: wrap;
	}

	.btn-primary-lg {
		display: inline-flex;
		align-items: center;
		padding: 16px 36px;
		background: #ef4444;
		color: white;
		border-radius: 10px;
		font-size: 17px;
		font-weight: 700;
		transition: all 0.25s cubic-bezier(0.16, 1, 0.3, 1);
	}

	.btn-primary-lg:hover {
		background: #dc2626;
		transform: translateY(-2px);
	}

	.btn-ghost-lg {
		padding: 16px 36px;
		border: 1px solid #292524;
		color: #a8a29e;
		border-radius: 10px;
		font-size: 17px;
		font-weight: 600;
		transition: all 0.2s;
		background: transparent;
	}

	.btn-ghost-lg:hover {
		border-color: #44403c;
		color: #fafaf9;
		background: rgba(255, 255, 255, 0.03);
	}

	.why {
		border-top: 1px solid #1c1917;
		position: relative;
	}

	.why-tomato {
		position: absolute;
		top: 50%;
		right: 6%;
		transform: translateY(-50%) rotate(-15deg);
		width: 80px;
		height: 80px;
		object-fit: contain;
		opacity: 0.06;
		pointer-events: none;
		animation: float 6s ease-in-out infinite;
	}

	.why-inner {
		max-width: 640px;
		margin: 0 auto;
		padding: 96px 24px;
	}

	.why-inner h2 {
		font-size: 36px;
		font-weight: 700;
		letter-spacing: -0.03em;
		margin-bottom: 52px;
		text-align: center;
	}

	.why-list {
		display: flex;
		flex-direction: column;
	}

	.why-item {
		padding: 28px 0;
		border-bottom: 1px solid #1c1917;
	}

	.why-item:last-child {
		border-bottom: none;
	}

	.why-item h3 {
		font-size: 17px;
		font-weight: 700;
		margin-bottom: 6px;
		letter-spacing: -0.01em;
	}

	.why-item p {
		font-size: 15px;
		color: #78716c;
		line-height: 1.6;
	}

	.facts {
		background: #141211;
		position: relative;
		border-top: 1px solid #292524;
		border-bottom: 1px solid #292524;
	}

	.facts-tomato {
		position: absolute;
		top: 40px;
		right: 8%;
		width: 80px;
		height: 80px;
		object-fit: contain;
		opacity: 0.12;
		rotate: -15deg;
		pointer-events: none;
	}

	.facts-inner {
		max-width: 800px;
		margin: 0 auto;
		padding: 96px 24px;
		text-align: center;
	}

	.facts-inner h2 {
		font-size: 36px;
		font-weight: 700;
		letter-spacing: -0.03em;
		margin-bottom: 56px;
	}

	.facts-row {
		display: grid;
		grid-template-columns: repeat(4, 1fr);
		gap: 8px;
	}

	.fact {
		padding: 20px 0;
	}

	.fact-number {
		font-size: 40px;
		font-weight: 700;
		background: linear-gradient(135deg, #f87171, #fb923c);
		-webkit-background-clip: text;
		-webkit-text-fill-color: transparent;
		background-clip: text;
		margin-bottom: 6px;
		letter-spacing: -0.03em;
	}

	.fact-desc {
		font-size: 14px;
		color: #57534e;
		line-height: 1.5;
	}

	.how {
		border-top: 1px solid #1c1917;
		position: relative;
	}

	.how-tomato {
		position: absolute;
		top: 50%;
		left: 6%;
		transform: translateY(-50%) rotate(20deg);
		width: 70px;
		height: 70px;
		object-fit: contain;
		opacity: 0.05;
		pointer-events: none;
		animation: float 5s ease-in-out infinite 1s;
	}

	.how-inner {
		max-width: 640px;
		margin: 0 auto;
		padding: 96px 24px;
	}

	.how-inner h2 {
		font-size: 36px;
		font-weight: 700;
		letter-spacing: -0.03em;
		margin-bottom: 48px;
		text-align: center;
	}

	.how-steps {
		display: flex;
		flex-direction: column;
	}

	.how-step {
		display: flex;
		gap: 24px;
		align-items: flex-start;
		padding: 28px 0;
		border-bottom: 1px solid #1c1917;
	}

	.how-step:last-child {
		border-bottom: none;
	}

	.how-num {
		font-size: 14px;
		font-weight: 600;
		color: #ef4444;
		flex-shrink: 0;
		padding-top: 2px;
		letter-spacing: 0.02em;
	}

	.how-step h3 {
		font-size: 17px;
		font-weight: 700;
		margin-bottom: 6px;
		letter-spacing: -0.01em;
	}

	.how-step p {
		font-size: 15px;
		color: #78716c;
		line-height: 1.6;
	}

	.cta-section {
		text-align: center;
		position: relative;
		border-top: 1px solid #1c1917;
	}

	.cta-tomato {
		position: absolute;
		top: 50%;
		left: 10%;
		transform: translateY(-50%) rotate(-20deg);
		width: 100px;
		height: 100px;
		object-fit: contain;
		opacity: 0.08;
		pointer-events: none;
	}

	.cta-inner {
		max-width: 600px;
		margin: 0 auto;
		padding: 96px 24px;
		position: relative;
		z-index: 1;
	}

	.cta-inner h2 {
		font-size: 40px;
		font-weight: 700;
		letter-spacing: -0.03em;
		margin-bottom: 14px;
	}

	.cta-inner p {
		font-size: 18px;
		color: #78716c;
		margin-bottom: 36px;
	}

	.footer {
		text-align: center;
		padding: 40px 24px;
		border-top: 1px solid #1c1917;
		color: #44403c;
		font-size: 13px;
		position: relative;
	}

	.footer-tomato {
		width: 24px;
		height: 24px;
		object-fit: contain;
		opacity: 0.3;
		margin-bottom: 12px;
	}

	.footer-link {
		color: #57534e;
		transition: color 0.2s;
	}

	.footer-link:hover {
		color: #ef4444;
	}

	@media (max-width: 768px) {
		h1 {
			font-size: 42px;
		}

		.hero {
			padding: 60px 24px 80px;
		}

		.hero-tomato-1 {
			width: 80px;
			height: 80px;
			top: 20px;
			right: 2%;
		}

		.hero-tomato-2, .hero-tomato-3 {
			display: none;
		}

		.facts-row {
			grid-template-columns: repeat(2, 1fr);
			gap: 24px 16px;
		}

		.cta-inner h2 {
			font-size: 30px;
		}
	}
</style>
