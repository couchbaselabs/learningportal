function (doc, meta) {
  if (doc.type){
    doc.authors.forEach(function(author){
      emit([author.name, meta.id], null)
    });
  }
}