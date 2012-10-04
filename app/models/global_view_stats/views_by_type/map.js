function (doc, meta) {
  emit(doc.type, doc.count || 0);
}