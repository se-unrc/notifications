window.onload = function(){
  (function(){
    var show = function(el){
      return function(msg){ el.innerHTML = msg + '<br />' + el.innerHTML; }
    }(document.getElementById('msgs'));
    var ws = new WebSocket('ws://' + window.location.host + window.location.pathname);
    ws.onopen = function() { show('websocket opened'); alert("Conexion Abierta");};
    ws.onclose = function() { show('websocket closed'); }
    ws.onmessage = function(m) { show('websocket message: ' + m.data); };

    var sender = function(f){
      f.onsubmit = function(){
        ws.send("documento");
        return true;
      }
    }(document.getElementById('form'));
  })();
}
