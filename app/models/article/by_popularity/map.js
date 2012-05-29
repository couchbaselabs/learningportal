function (doc) {
  if (doc.type) {
    emit(doc.views || 0, null);
  }
}