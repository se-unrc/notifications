var nombre = document.getElementById('nombre');

function enviarFormulario(){
  if (revisarDocumento()) {
    enviar();
  }
  return false;
}

function revisarDocumento(){
  if (nombre.value === null || nombre.value === ""){
    M.toast({html: 'No ingresó un nombre!', classes: 'rounded'});
    return false;
  }
  if (nombre.value.length < 3){
    M.toast({html: 'Nombre demasiado corto!', classes: 'rounded'});
    return false;
  }
  if (nombre.value.length > 50){
    M.toast({html: 'Nombre demasiado largo!', classes: 'rounded'});
    return false;
  }
  return true;
}
