function (doc) {
  if (doc.type){
    emit(doc._id, doc.popularity || 0);
  }
}