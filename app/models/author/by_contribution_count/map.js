function(doc) {
  doc.authors.forEach(function(author){
    emit(author.name, null);
  });
}