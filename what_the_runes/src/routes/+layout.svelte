<script>
	let { children } = $props();
</script>

<svelte:head>
    <title>Rexdy's First Svelte App</title>
</svelte:head>

{@render children()}
