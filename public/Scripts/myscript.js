window.onload = function(){
  (function(){
    var show = function(el){
      return function(msg){ el.innerHTML = msg + '<br />' + el.innerHTML; }
    }(document.getElementById('msgs'));
    var ws  = new WebSocket('ws://localhost:9292/miwebsoket');
    ws.onopen = () => {console.log('conectado');}
    ws.onerror = e => {console.log('error en la conexion', e);};
    ws.onclose = () => {console.log('desconectado');};
    ws.onmessage = function(m) {
      // show('websocket message: ' + m.data);
      var msgs = document.getElementById('msgs');
      };
      var sender = function(f){
        f.onsubmit = function(){
          ws.send(msgs);
          return true;
        }
        }(document.getElementById('form'));
      })();
    }
