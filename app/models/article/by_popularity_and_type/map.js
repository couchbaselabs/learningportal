function (doc) {
  if (doc.type) {
    emit([doc.type, doc.views || 0], null);
  }
}