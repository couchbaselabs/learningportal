function (doc) {
  if (doc.type) {
    emit(doc.popularity || 0, null);
  }
}