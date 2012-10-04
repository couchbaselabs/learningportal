function(doc, meta) {
  if (doc.type){
    doc.authors.forEach(function(author){
      emit([author.name, doc.type], doc.type);
    });
  }
}