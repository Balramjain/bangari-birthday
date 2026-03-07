const starContainer = document.getElementById("emoji-stars")
const bubbleContainer = document.getElementById("emoji-bubbles")

/* ⭐ STAR SHOOTING */

function createStar(){

  const star = document.createElement("div")
  star.className = "emoji-star"
  star.textContent = "⭐"

  const startX = Math.random()*window.innerWidth
  const startY = Math.random()*window.innerHeight

  const dx = (Math.random()*600 - 300) + "px"
  const dy = (Math.random()*600 - 300) + "px"

  star.style.left = startX + "px"
  star.style.top = startY + "px"

  star.style.setProperty("--dx",dx)
  star.style.setProperty("--dy",dy)

  star.style.animationDuration = 3 + Math.random()*3 + "s"

  starContainer.appendChild(star)

  setTimeout(()=> star.remove(),6000)

}

setInterval(createStar,800)



/* 🫧 LIGHT SCROLL BUBBLES */

let bubbleCooldown=false

window.addEventListener("scroll",()=>{

  if(bubbleCooldown) return

  bubbleCooldown=true

  for(let i=0;i<2;i++){

    const bubble=document.createElement("div")
    bubble.className="emoji-bubble"
    bubble.textContent="🫧"

    bubble.style.left=Math.random()*100+"vw"

    bubbleContainer.appendChild(bubble)

    setTimeout(()=>bubble.remove(),5000)

  }

  setTimeout(()=>bubbleCooldown=false,1200)

})