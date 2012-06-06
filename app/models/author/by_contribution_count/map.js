function(doc) {
  if (doc.type){
    doc.authors.forEach(function(author){
      emit(author.name, null);
    });
  }
}