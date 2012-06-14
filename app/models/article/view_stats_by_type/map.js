function (doc) {
  emit(doc.type, doc.views || 0);
}