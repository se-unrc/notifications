// window.onload = function(){
//   (function(){
//     var show = function(el){
//       return function(msg){
//         el.innerHTML = msg + el.innerHTML;
//       }
//     }(document.getElementById('msgs'));
//     var reloadPage = function(){
//       return function(){
//           window.location.reload();
//       }
//     }(document.getElementById('reload'));
//       var ws       = new WebSocket('ws://localhost:9292/miwebsoket');
//       ws.onopen    = function()  {  };
//       ws.onclose   = function()  {  }
//       ws.onmessage = function(m) {
//
//         if (document.getElementById('reload') !== null) {
//           setTimeout(function () {
//             reloadPage();
//           }, 3000);
//         }
//         show(m.data);
//       };
//   })();
// }



window.onload = function(){
  (function(){
    var show = function(el){
      return function(msg){ el.innerHTML = msg + '<br />' + el.innerHTML; }
    }(document.getElementById('msgs'));
    const ws  = new WebSocket('ws://localhost:9292/miwebsoket');
    ws.onopen = () => {console.log('conectado');};
    ws.onerror = e => {console.log('error en la conexion', e);};
    ws.onclose = () => {console.log('desconectado');};
    ws.onmessage = function(m) {
      show('websocket message: ' + m.data);
      var msgs = document.getElementById('msgs');
      msgs.innerHTML = '\
      <div class="col-lg-4 col-md-4 col-sm-3 col-xs-2">\
      <a id="buttonNotf" href="/notificaciones">Notificaciones</a>\
      </div>';
      location.reload();
    };
  })();
}
