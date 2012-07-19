function (doc) {
  if (doc.type) {
    var popularity = doc.popularity || 0;
    emit(popularity, popularity);
  }
}