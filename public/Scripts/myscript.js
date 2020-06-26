window.onload = function(){
  (function(){
    var show = function(el){
      return function(msg){ el.innerHTML = msg + '<br />' + el.innerHTML; }
    }(document.getElementById('msgs'));
    var ws  = new WebSocket('ws://localhost:9292/miwebsoket');
    ws.onopen = function() { show('websocket opened');};
    ws.onclose = function() { show('websocket closed'); }
    ws.onmessage = function(m) {
      show('websocket message: ' + m.data);
      var msgs = document.getElementById('msgs');
      msgs.innerHTML = '\
            <div class="spinner-grow text-success" role="status">\
              <span class="sr-only">Loading...</span>\
            </div>\
            <div class="alert alert-primary" role="alert">\
            <form class="col-6" action="/all_notifications" method="get">\
              <input type="hidden" name="theId" value="<%@userName.id%>"/>\
              <button id="buttonLogin" type="submit">Notificaciones</button>\
            </form>\
            </div>';
     };
          var sender = function(f){
      f.onsubmit = function(){
      ws.send(msgs);
      return true;
    }
    }(document.getElementById('form'));
    })();
  }
