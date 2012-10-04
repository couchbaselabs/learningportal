function (doc, meta) {
  if (doc.type) {
    emit([doc.type, meta.id], null);
  }
}