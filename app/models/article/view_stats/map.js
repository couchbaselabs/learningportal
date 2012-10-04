function (doc, meta) {
  if (doc.type){
    emit(meta.id, doc.popularity || 0);
  }
}