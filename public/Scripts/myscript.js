//Lo anterior, lo que andaba y mostraba un cartel que decía que se subió un documento

// window.onload = function(){
//   (function(){
//     var show = function(el){
//       return function(msg){ el.innerHTML = msg + '<br />' + el.innerHTML; }
//     }(document.getElementById('msgs'));
//     var ws = new WebSocket('ws://' + window.location.host + window.location.pathname);
//     ws.onopen = function() { show('websocket opened'); alert("Conexion Abierta");
//     };
//     ws.onclose = function() { show('websocket closed'); }
//     ws.onmessage = function(m) { show('websocket message: ' + m.data); };
//     var sender = function(f){
//       f.onsubmit = function(){
//         ws.send("documento");
//         return true;
//       }
//     }(document.getElementById('form'));
//   })();
// }



//Si pones esto en vez de lo anterior cuando mandas un mensaje se pone un botón que esta escrito en HTML


window.onload = function(){
  (function(){
    var show = function(el){
      return function(msg){ el.innerHTML = msg + '<br />' + el.innerHTML; }
    }(document.getElementById('msgs'));
    var ws = new WebSocket('ws://' + window.location.host + window.location.pathname);
    ws.onopen = function() { show('websocket opened'); alert("Conexion Abierta");
    };
    ws.onclose = function() { show('websocket closed'); }
    ws.onmessage = function(m) { show('websocket message: ' + m.data);
      var msgs = document.getElementById('msgs');
      msgs.innerHTML = '<button onclick=myFunction()> Click me </button>'; };
      var sender = function(f){
        f.onsubmit = function(){
        ws.send("documento");
        return true;
      }
    }(document.getElementById('form'));
  })();
}
