// Paste this into the Signal Deck browser console (F12 -> Console) and press Enter.
// Marks your 7 tasks as linked-to-calendar + daily recurring, matching the
// daily recurring Google Calendar events just created, without wiping anything else.
(function(){
  const raw = localStorage.getItem('signal-deck-data');
  if(!raw){ console.log('No saved Signal Deck data found in this browser.'); return; }
  const state = JSON.parse(raw);

  const matches = [
    /deploy.*railway/i,
    /update resume/i,
    /update portfolio/i,
    /freelance (profiles|sites)/i,
    /learn mcp/i,
    /building the game|build.*game/i,
    /reading/i,
  ];

  let changed = 0;
  state.todos.forEach(t=>{
    if(matches.some(m=>m.test(t.text))){
      t.cal = true;
      t.daily = true;
      t.due = null; // these are recurring daily, not one-off deadlines
      changed++;
    }
  });

  localStorage.setItem('signal-deck-data', JSON.stringify(state));
  console.log(`Updated ${changed} task(s). Reload the page to see it reflected.`);
})();
