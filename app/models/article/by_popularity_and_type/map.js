function (doc, meta) {
  if (doc.type) {
    emit([doc.type, doc.popularity || 0], null);
  }
}