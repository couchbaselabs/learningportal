function (doc) {
  emit(doc.type, doc.popularity || 0);
}