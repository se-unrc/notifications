var ws       = new WebSocket('ws://localhost:9292/');

ws.onopen = () => {
  console.log('conectado');
};
ws.onerror = e => {
  console.log('error en la conexion', e);
};
ws.onmessage = e => {
  const msg = JSON.parse(e.data)
  document.getElementById("unread").innerHTML=msg;
 // document.getElementById("unread").style= 'display: none;';
  //console.log(e.data);
};
ws.onclose = () => {
  console.log('desconectado');
};