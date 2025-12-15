<script>
    let count = $state(0);
    let isBlack = $state(false);
    function on_click(){
        count +=1;
        isBlack=!isBlack;
    }
</script>

<div id="body" class:black={isBlack}>
    <div id="cont">
    <h1 id="greet" >Hi, I am cliq!</h1>
    <button onclick={on_click} >Click Me!</button>
    <span>{count<1?"":`cliq count = ${count}`}</span>
    </div>
</div>

<style>
    #body{
        margin: 0;
        width: 100vw;
        height: 100vh;
    }
    #body{
        height: 100vh;
        width: 100vw;
        display: flex;
        align-items: center;
        justify-content: center;
    }
    .black{
        background-color: rgba(0, 0, 0, 1);
        color: rgba(255, 255, 255, 1);
    }
    #cont{
        width: 35%;
        height: 20%;
        display: grid;
        grid-template-rows: 1fr auto;
        place-items: center;
    }
    #cont button{
        width: 25%;
    }
    #cont span {
        height: 2rem;
        padding: 1rem;
        font-size: 1.25rem;
    }
    #greet{
        text-align: center;
    }
</style>
