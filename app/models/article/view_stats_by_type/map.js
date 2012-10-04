function (doc, meta) {
  emit(doc.type, doc.popularity || 0);
}