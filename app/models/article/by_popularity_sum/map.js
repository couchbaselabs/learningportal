function (doc, meta) {
  if (doc.type) {
    var popularity = doc.popularity || 0;
    emit(popularity, popularity);
  }
}