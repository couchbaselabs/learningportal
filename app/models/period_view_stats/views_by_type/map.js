function (doc) {
  emit(doc.type, doc.count || 0);
}